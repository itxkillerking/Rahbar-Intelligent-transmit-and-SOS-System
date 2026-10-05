import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.api.dependencies import get_db, get_current_user
from app.application.services.profile_service import ProfileService
from app.schemas.profile import ProfileResponse, ProfilePatchRequest, ProfileUpdateResponse
from app.domain.entities.user import User

logger = logging.getLogger(__name__)
router = APIRouter()

def get_profile_service(db: AsyncSession = Depends(get_db)) -> ProfileService:
    return ProfileService(db)

@router.get("", response_model=ProfileResponse)
async def get_profile(
    user: User = Depends(get_current_user),
    profile_service: ProfileService = Depends(get_profile_service)
):
    try:
        return await profile_service.get_profile(user)
    except Exception as e:
        logger.error(f"Error fetching profile: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred."
        )

@router.patch("", response_model=ProfileUpdateResponse)
async def update_profile(
    payload: ProfilePatchRequest,
    user: User = Depends(get_current_user),
    profile_service: ProfileService = Depends(get_profile_service)
):
    try:
        result = await profile_service.update_profile(user, payload)
        if "error" in result:
            if result["error"] == "duplicate_username":
                raise HTTPException(status_code=409, detail="Username already in use")
            if result["error"] == "duplicate_cnic":
                raise HTTPException(status_code=409, detail="CNIC already in use")
        return result
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating profile: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred."
        )
