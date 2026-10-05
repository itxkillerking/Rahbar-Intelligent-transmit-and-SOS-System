import logging
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.exc import IntegrityError
from app.domain.entities.profile import UserProfile
from app.domain.entities.user import User
from app.schemas.profile import ProfilePatchRequest
from app.application.event_bus.dispatcher import dispatcher
from app.domain.events.user_events import ProfileCompleted

logger = logging.getLogger(__name__)

class ProfileService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_profile(self, user: User) -> dict:
        stmt = select(UserProfile).where(UserProfile.user_id == user.id)
        result = await self.db.execute(stmt)
        profile = result.scalar_one_or_none()

        response = {
            "phone_number": user.phone_number,
            "phone_verified": user.phone_verified,
            "profile_completed": user.profile_completed,
        }

        if profile:
            for field in [
                "full_name", "username", "cnic", "email", "gender", "date_of_birth",
                "province", "city", "district", "address", "emergency_contact_number",
                "emergency_contact_relationship", "blood_group", "medical_conditions",
                "disability", "profession", "institute_organization", "profile_image_url"
            ]:
                response[field] = getattr(profile, field, None)
                
        return response

    async def update_profile(self, user: User, data: ProfilePatchRequest) -> dict:
        try:
            # Look up profile
            stmt = select(UserProfile).where(UserProfile.user_id == user.id)
            result = await self.db.execute(stmt)
            profile = result.scalar_one_or_none()

            if not profile:
                profile = UserProfile(user_id=user.id)
                self.db.add(profile)

            # Update fields
            update_data = data.dict(exclude_unset=True)
            for key, value in update_data.items():
                setattr(profile, key, value)

            await self.db.flush()

            # Check completion logic
            required_fields = ["full_name", "username", "cnic", "province", "city"]
            is_complete = all(getattr(profile, f) for f in required_fields)
            
            was_completed = user.profile_completed

            if is_complete and not was_completed:
                user.profile_completed = True
            elif not is_complete and was_completed:
                user.profile_completed = False

            await self.db.commit()

            # Dispatch events
            if is_complete and not was_completed:
                await dispatcher.dispatch(ProfileCompleted(user_id=user.id))

            next_step = "home" if user.profile_completed else "complete_profile"

            profile_data = await self.get_profile(user)

            return {
                "profile_completed": user.profile_completed,
                "next_step": next_step,
                "profile": profile_data
            }

        except IntegrityError as e:
            await self.db.rollback()
            error_msg = str(e.orig).lower() if e.orig else ""
            if "username" in error_msg:
                return {"error": "duplicate_username"}
            if "cnic" in error_msg:
                return {"error": "duplicate_cnic"}
            raise e
        except Exception as e:
            await self.db.rollback()
            raise e
