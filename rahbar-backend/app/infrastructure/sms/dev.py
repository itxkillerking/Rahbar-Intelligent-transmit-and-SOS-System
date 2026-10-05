import hmac
import hashlib
from app.infrastructure.sms.base import SmsService
from app.core.config import settings
from app.core.redis import redis_client
from app.core.exceptions import OtpDeliveryError

class LocalDevSmsService(SmsService):
    def _get_dev_key(self, phone_number: str) -> str:
        phone_hash = hmac.new(
            settings.OTP_HMAC_SECRET.encode(),
            phone_number.encode(),
            hashlib.sha256,
        ).hexdigest()
        return f"rahbar:dev:otp:{phone_hash}"

    async def send_otp(self, phone_number: str, otp: str) -> bool:
        if settings.APP_ENV != "development" or settings.SMS_PROVIDER != "dev":
            raise OtpDeliveryError("LocalDevSmsService is not permitted in current configuration.")
            
        key = self._get_dev_key(phone_number)
        # Store for the real OTP lifetime
        await redis_client.set(key, otp, ex=settings.OTP_EXPIRE_SECONDS)
        return True

    async def send_emergency_message(self, phone_number: str, message: str) -> bool:
        if settings.APP_ENV not in ["development", "staging"] or settings.SMS_PROVIDER != "dev":
            raise OtpDeliveryError("LocalDevSmsService is not permitted in current configuration.")
        return True
