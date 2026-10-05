from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.application.services.otp_service import OTPService
from app.domain.entities.user import User
from app.domain.entities.session import DeviceSession
from app.application.event_bus.dispatcher import dispatcher
from app.domain.events.user_events import PhoneVerified, UserCreated, UserRegistered, UserLoggedIn
from app.core.security import create_access_token, create_refresh_token, hash_refresh_token

class AuthService:
    def __init__(self, db: AsyncSession, otp_service: OTPService):
        self.db = db
        self.otp_service = otp_service

    async def verify_and_login(self, phone_number: str, raw_otp: str, ip_address: str = None) -> dict:
        # 1. Verify OTP
        is_valid = await self.otp_service.verify_otp(phone_number, raw_otp)
        if not is_valid:
            # We return False if any of: expired, missing, max attempts, wrong OTP, or concurrent consumption
            return {"error": "invalid_otp"}

        # 2. Database Transaction
        try:
            # Look up user
            stmt = select(User).where(User.phone_number == phone_number)
            result = await self.db.execute(stmt)
            user = result.scalar_one_or_none()

            is_new_user = False

            if not user:
                is_new_user = True
                user = User(
                    phone_number=phone_number,
                    phone_verified=True,
                    profile_completed=False,
                )
                self.db.add(user)
                await self.db.flush() # flush to get user.id
            else:
                # Existing user logic
                if user.account_status != "active":
                    await self.db.rollback()
                    return {"error": "inactive_account"}
                # Ensure verified flag is true just in case
                user.phone_verified = True
                await self.db.flush()

            # 3. Create Session & Tokens
            access_token = create_access_token({"sub": str(user.id)})
            refresh_token = create_refresh_token({"sub": str(user.id)})
            refresh_token_hashed = hash_refresh_token(refresh_token)

            device_session = DeviceSession(
                user_id=user.id,
                refresh_token_hash=refresh_token_hashed,
                ip_address=ip_address,
                is_revoked=False
            )
            self.db.add(device_session)
                
            # Transaction commits automatically here
            await self.db.commit()
            
        except Exception as e:
            await self.db.rollback()
            raise e

        # 4. Dispatch Events (Only after commit is successful)
        await dispatcher.dispatch(PhoneVerified(user_id=user.id))
        if is_new_user:
            await dispatcher.dispatch(UserCreated(user_id=user.id, phone_number=phone_number))
            await dispatcher.dispatch(UserRegistered(user_id=user.id))
            
        await dispatcher.dispatch(UserLoggedIn(user_id=user.id))

        # 5. Determine Next Step
        if not user.profile_completed:
            next_step = "complete_profile"
        else:
            next_step = "home"

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "is_new_user": is_new_user,
            "profile_completed": user.profile_completed,
            "next_step": next_step
        }

    async def refresh_token(self, token: str) -> dict:
        try:
            from jose import JWTError
            from app.core.security import verify_token
            payload = verify_token(token)
            if payload.get("type") != "refresh":
                return {"error": "invalid_session"}
                
            user_id = payload.get("sub")
            if not user_id:
                return {"error": "invalid_session"}
                
            token_hash = hash_refresh_token(token)
            
            stmt = select(DeviceSession).where(
                DeviceSession.user_id == user_id,
                DeviceSession.refresh_token_hash == token_hash,
                DeviceSession.is_revoked == False
            )
            result = await self.db.execute(stmt)
            session = result.scalar_one_or_none()
            
            if not session:
                await self.db.rollback()
                return {"error": "invalid_session"}
                
            user_stmt = select(User).where(User.id == user_id)
            user_result = await self.db.execute(user_stmt)
            user = user_result.scalar_one_or_none()
            
            if not user or user.account_status != "active":
                await self.db.rollback()
                return {"error": "invalid_session"}
                
            # Rotate tokens
            new_access_token = create_access_token({"sub": str(user.id)})
            new_refresh_token = create_refresh_token({"sub": str(user.id)})
            new_token_hash = hash_refresh_token(new_refresh_token)
            
            session.refresh_token_hash = new_token_hash
            from datetime import datetime, timezone
            session.last_used_at = datetime.now(timezone.utc)
            
            await self.db.commit()
            
            return {
                "access_token": new_access_token,
                "refresh_token": new_refresh_token,
                "token_type": "bearer"
            }
            
        except Exception as e:
            await self.db.rollback()
            return {"error": "invalid_session"}

    async def logout(self, token: str) -> dict:
        try:
            token_hash = hash_refresh_token(token)
            stmt = select(DeviceSession).where(DeviceSession.refresh_token_hash == token_hash)
            result = await self.db.execute(stmt)
            session = result.scalar_one_or_none()
            
            if session and not session.is_revoked:
                session.is_revoked = True
                await self.db.commit()
            else:
                await self.db.rollback()
                
            return {"message": "Logged out successfully"}
        except Exception:
            await self.db.rollback()
            return {"message": "Logged out successfully"}

