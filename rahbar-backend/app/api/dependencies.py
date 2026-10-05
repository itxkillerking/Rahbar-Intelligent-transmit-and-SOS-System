from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import AsyncSessionLocal
from app.core.config import settings
from app.infrastructure.sms.base import SmsService
from app.application.services.otp_service import OTPService
from app.core.exceptions import OtpDeliveryError
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import HTTPException, status
from app.core.security import verify_token
from jose import JWTError
from sqlalchemy.future import select
from app.domain.entities.user import User

security = HTTPBearer()

class UnconfiguredSmsService(SmsService):
    async def send_otp(self, phone_number: str, otp: str) -> bool:
        # Fails safely because no provider is configured
        raise OtpDeliveryError("SMS provider not configured")

    async def send_emergency_message(self, phone_number: str, message: str) -> bool:
        raise OtpDeliveryError("SMS provider not configured")

def get_sms_service() -> SmsService:
    if settings.APP_ENV.strip() in ["development", "staging"] and settings.SMS_PROVIDER.strip() == "dev":
        from app.infrastructure.sms.dev import LocalDevSmsService
        return LocalDevSmsService()
    return UnconfiguredSmsService()

def get_otp_service(sms_service: SmsService = Depends(get_sms_service)) -> OTPService:
    return OTPService(sms_service)

async def get_db() -> AsyncSession:
    session = AsyncSessionLocal()
    try:
        yield session
    except Exception:
        await session.rollback()
        raise
    finally:
        await session.close()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> User:
    try:
        payload = verify_token(credentials.credentials)
        if payload.get("type") != "access":
            raise HTTPException(status_code=401, detail="Invalid token type")
        
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token payload")
            
        stmt = select(User).where(User.id == user_id)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()
        
        if user is None:
            raise HTTPException(status_code=401, detail="User not found")
            
        if user.account_status != "active":
            raise HTTPException(status_code=403, detail="Account is unavailable")
            
        return user
        
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
