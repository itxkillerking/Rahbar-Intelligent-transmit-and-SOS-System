import hmac
import hashlib
import secrets
from typing import Optional

from app.core.config import settings
from app.core.redis import redis_client
from app.core.rate_limit import RateLimiter
from app.core.security import generate_secure_otp
from app.infrastructure.sms.base import SmsService
from app.application.event_bus.dispatcher import dispatcher
from app.domain.events.user_events import PhoneOtpRequested, PhoneOtpSent

from app.core.exceptions import (
    RahbarException,
    OtpRateLimitError,
    OtpCooldownError,
    OtpDeliveryError,
)


class OTPService:
    def __init__(self, sms_service: SmsService):
        self.sms_service = sms_service
        self.rate_limiter = RateLimiter(requests=3, window=300)

    def _get_phone_key(self, phone_number: str) -> str:
        """Derives a stable, opaque key for Redis so raw phone numbers aren't stored in keys."""
        return hmac.new(
            settings.OTP_HMAC_SECRET.encode(),
            phone_number.encode(),
            hashlib.sha256,
        ).hexdigest()

    def _hash_otp(self, raw_otp: str) -> str:
        """Creates a constant-time secure hash of the raw OTP."""
        return hmac.new(
            settings.OTP_HMAC_SECRET.encode(),
            raw_otp.encode(),
            hashlib.sha256,
        ).hexdigest()

    async def request_otp(self, phone_number: str) -> None:
        """Generates, securely stores, and sends an OTP."""
        phone_key = self._get_phone_key(phone_number)
        
        # 1. Rate Limit Check (3 per 5 minutes)
        if not await self.rate_limiter.check(f"otp_req:{phone_key}"):
            raise OtpRateLimitError("Too many OTP requests. Please try again later.")

        # Dispatch requested event
        await dispatcher.dispatch(PhoneOtpRequested(phone_number=phone_number))

        # 2. Resend Cooldown Check
        cooldown_key = f"rahbar:otp:{phone_key}:cooldown"
        if await redis_client.exists(cooldown_key):
            raise OtpCooldownError("Please wait before requesting another OTP.")

        # 3. Generate & Hash
        raw_otp = generate_secure_otp(length=6)
        hashed_otp = self._hash_otp(raw_otp)

        hash_key = f"rahbar:otp:{phone_key}:hash"
        attempts_key = f"rahbar:otp:{phone_key}:attempts"

        # 4. Store in Redis
        # Use a transaction/pipeline to set everything safely
        pipeline = redis_client.pipeline()
        pipeline.set(hash_key, hashed_otp, ex=settings.OTP_EXPIRE_SECONDS)
        pipeline.set(cooldown_key, "1", ex=settings.OTP_RESEND_COOLDOWN_SECONDS)
        # Initialize attempts with the same TTL as the OTP, deleting previous attempts state
        pipeline.set(attempts_key, "0", ex=settings.OTP_EXPIRE_SECONDS)
        await pipeline.execute()

        # 5. Send SMS
        try:
            success = await self.sms_service.send_otp(phone_number, raw_otp)
            if not success:
                raise Exception("SMS provider returned failure.")
        except Exception:
            # 6. Failure Cleanup
            cleanup_pipeline = redis_client.pipeline()
            cleanup_pipeline.delete(hash_key)
            cleanup_pipeline.delete(attempts_key)
            cleanup_pipeline.delete(cooldown_key)
            await cleanup_pipeline.execute()
            
            # Safe application error
            raise OtpDeliveryError("Failed to send OTP. Please try again later.")

        # 7. Success Event
        await dispatcher.dispatch(PhoneOtpSent(phone_number=phone_number))

    async def verify_otp(self, phone_number: str, raw_otp: str) -> bool:
        """Verifies an OTP, blocks after too many wrong attempts, and guarantees single-use."""
        phone_key = self._get_phone_key(phone_number)
        hash_key = f"rahbar:otp:{phone_key}:hash"
        attempts_key = f"rahbar:otp:{phone_key}:attempts"

        stored_hash = await redis_client.get(hash_key)
        if not stored_hash:
            return False

        candidate_hash = self._hash_otp(raw_otp)

        # Constant time comparison
        if not secrets.compare_digest(stored_hash, candidate_hash):
            # WRONG ATTEMPT
            # Increment safely (maintaining existing TTL)
            attempts = await redis_client.incr(attempts_key)
            if attempts >= settings.OTP_MAX_ATTEMPTS:
                # Invalidate immediately
                pipeline = redis_client.pipeline()
                pipeline.delete(hash_key)
                pipeline.delete(attempts_key)
                await pipeline.execute()
            
            return False

        # CORRECT ATTEMPT - Atomic Consumption
        # Use Lua script to ensure atomic compare-and-delete
        # (This protects against race condition where the OTP was overwritten between GET and DEL)
        lua_script = """
        if redis.call("GET", KEYS[1]) == ARGV[1] then
            return redis.call("DEL", KEYS[1])
        else
            return 0
        end
        """
        deleted_count = await redis_client.eval(lua_script, 1, hash_key, stored_hash)
        
        if deleted_count == 1:
            # Successfully consumed!
            await redis_client.delete(attempts_key)
            return True
            
        return False
