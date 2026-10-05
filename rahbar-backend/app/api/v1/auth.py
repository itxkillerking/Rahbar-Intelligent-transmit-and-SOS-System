from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.auth import (
    OtpRequest, OtpRequestResponse, OtpVerifyRequest, TokenResponse,
    RefreshTokenRequest, TokenRefreshResponse, LogoutRequest, LogoutResponse
)
from app.api.dependencies import get_otp_service, get_db
from app.application.services.auth_service import AuthService
from app.application.services.otp_service import OTPService
from app.core.exceptions import (
    OtpRateLimitError,
    OtpCooldownError,
    OtpDeliveryError,
    RahbarException,
)
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/request-otp", response_model=OtpRequestResponse, status_code=status.HTTP_200_OK)
async def request_otp(
    payload: OtpRequest,
    otp_service: OTPService = Depends(get_otp_service),
):
    try:
        await otp_service.request_otp(payload.phone_number)
        
        return OtpRequestResponse(
            message="OTP sent successfully",
            expires_in=settings.OTP_EXPIRE_SECONDS,
            resend_after=settings.OTP_RESEND_COOLDOWN_SECONDS,
        )
    except (OtpRateLimitError, OtpCooldownError) as e:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=str(e),
        )
    except OtpDeliveryError as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(e),
        )
    except RahbarException as e:
        # Fallback for any other business logic exception
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )
    except Exception as e:
        logger.error(f"Unexpected error in request_otp: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred.",
        )

def get_auth_service(db: AsyncSession = Depends(get_db), otp_service: OTPService = Depends(get_otp_service)) -> AuthService:
    return AuthService(db, otp_service)

@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(
    payload: OtpVerifyRequest,
    request: Request,
    auth_service: AuthService = Depends(get_auth_service)
):
    try:
        ip = request.client.host if request.client else None
        result = await auth_service.verify_and_login(payload.phone_number, payload.otp, ip_address=ip)
        
        if "error" in result:
            if result["error"] == "invalid_otp":
                raise HTTPException(status_code=400, detail="Invalid or expired OTP")
            elif result["error"] == "inactive_account":
                raise HTTPException(status_code=403, detail="Account is currently unavailable")
                
        return result
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error in verify_otp: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred.",
        )

@router.post("/refresh", response_model=TokenRefreshResponse)
async def refresh_token(
    payload: RefreshTokenRequest,
    auth_service: AuthService = Depends(get_auth_service)
):
    try:
        result = await auth_service.refresh_token(payload.refresh_token)
        if "error" in result:
            raise HTTPException(status_code=401, detail="Invalid or expired session")
        return result
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error in refresh_token: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred.",
        )

@router.post("/logout", response_model=LogoutResponse)
async def logout(
    payload: LogoutRequest,
    auth_service: AuthService = Depends(get_auth_service)
):
    try:
        result = await auth_service.logout(payload.refresh_token)
        return result
    except Exception as e:
        logger.error(f"Unexpected error in logout: {e}", exc_info=True)
        # Idempotent/safe fallback
        return LogoutResponse(message="Logged out successfully")

if settings.APP_ENV.strip() in ["development", "staging"] and settings.SMS_PROVIDER.strip() == "dev":
    @router.get("/dev/otp/{phone_number}", include_in_schema=False)
    async def get_dev_otp(phone_number: str):
        """DEVELOPMENT ONLY — NEVER ENABLE IN PRODUCTION."""
        from app.schemas.validators import PhoneMixin
        # Quick normalization
        class PhoneNormalizer(PhoneMixin): pass
        try:
            normalized_phone = PhoneNormalizer(phone_number=phone_number).phone_number
        except Exception:
            raise HTTPException(status_code=422, detail="Invalid phone format")
            
        import hmac, hashlib
        from app.core.redis import redis_client
        
        phone_hash = hmac.new(
            settings.OTP_HMAC_SECRET.encode(),
            normalized_phone.encode(),
            hashlib.sha256,
        ).hexdigest()
        
        key = f"rahbar:dev:otp:{phone_hash}"
        otp = await redis_client.get(key)
        
        if not otp:
            raise HTTPException(status_code=404, detail="OTP not found or expired")
            
        ttl = await redis_client.ttl(key)
        
        return {
            "phone_number": normalized_phone,
            "otp": otp,
            "expires_in": ttl,
            "development_only": True
        }

