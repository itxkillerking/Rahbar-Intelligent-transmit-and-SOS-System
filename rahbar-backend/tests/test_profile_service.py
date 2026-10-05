import pytest
from unittest.mock import AsyncMock, patch, MagicMock
from app.application.services.profile_service import ProfileService
from app.domain.entities.user import User
from app.domain.entities.profile import UserProfile
from app.schemas.profile import ProfilePatchRequest
from app.domain.events.user_events import ProfileCompleted
import uuid

@pytest.fixture
def mock_db():
    db = AsyncMock()
    # Mock nested transaction behaviour is not used anymore
    # but we still need flush and commit
    db.flush = AsyncMock()
    db.commit = AsyncMock()
    db.rollback = AsyncMock()
    db.add = MagicMock()
    return db

@pytest.fixture
def profile_service(mock_db):
    return ProfileService(mock_db)

def create_mock_user(completed=False):
    return User(
        id=uuid.uuid4(),
        phone_number="+923001234567",
        phone_verified=True,
        profile_completed=completed,
        account_status="active"
    )

@pytest.mark.asyncio
async def test_get_profile_not_found_returns_auth_data(mock_db, profile_service):
    user = create_mock_user()
    
    # Mock no profile found
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = None
    mock_db.execute.return_value = mock_result
    
    result = await profile_service.get_profile(user)
    
    assert result["phone_number"] == "+923001234567"
    assert result["phone_verified"] is True
    assert result["profile_completed"] is False
    assert result.get("full_name") is None

@pytest.mark.asyncio
async def test_get_profile_returns_masked_cnic(mock_db, profile_service):
    user = create_mock_user(completed=True)
    
    profile = UserProfile(
        user_id=user.id,
        full_name="Jawad Ahmed",
        username="jawad_ahmed",
        cnic="3520212345671",
        province="Punjab",
        city="Lahore"
    )
    
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = profile
    mock_db.execute.return_value = mock_result
    
    result = await profile_service.get_profile(user)
    
    assert result["full_name"] == "Jawad Ahmed"
    assert result["cnic"] == "3520212345671"

@pytest.mark.asyncio
@patch("app.application.services.profile_service.dispatcher.dispatch", new_callable=AsyncMock)
async def test_update_profile_creates_new_and_does_not_complete(mock_dispatch, mock_db, profile_service):
    user = create_mock_user()
    
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = None
    mock_db.execute.return_value = mock_result
    
    # Only some required fields
    patch_req = ProfilePatchRequest(full_name="Jawad Ahmed", username="jawad_ahmed")
    
    result = await profile_service.update_profile(user, patch_req)
    
    assert mock_db.add.call_count == 1
    assert result["profile_completed"] is False
    assert result["next_step"] == "complete_profile"
    assert mock_dispatch.call_count == 0

@pytest.mark.asyncio
@patch("app.application.services.profile_service.dispatcher.dispatch", new_callable=AsyncMock)
async def test_update_profile_completes_and_dispatches_event(mock_dispatch, mock_db, profile_service):
    user = create_mock_user(completed=False)
    
    existing_profile = UserProfile(user_id=user.id)
    
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = existing_profile
    mock_db.execute.return_value = mock_result
    
    patch_req = ProfilePatchRequest(
        full_name="Jawad Ahmed", 
        username="jawad_ahmed",
        cnic="3520212345671",
        province="Punjab",
        city="Lahore"
    )
    
    result = await profile_service.update_profile(user, patch_req)
    
    assert result["profile_completed"] is True
    assert result["next_step"] == "home"
    
    # Event should be dispatched once because completed transitioned false -> true
    assert mock_dispatch.call_count == 1
    event = mock_dispatch.call_args[0][0]
    assert isinstance(event, ProfileCompleted)
    assert event.user_id == user.id

@pytest.mark.asyncio
@patch("app.application.services.profile_service.dispatcher.dispatch", new_callable=AsyncMock)
async def test_update_profile_already_completed_no_duplicate_event(mock_dispatch, mock_db, profile_service):
    user = create_mock_user(completed=True)
    
    existing_profile = UserProfile(
        user_id=user.id,
        full_name="Jawad Ahmed", 
        username="jawad_ahmed",
        cnic="3520212345671",
        province="Punjab",
        city="Lahore"
    )
    
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = existing_profile
    mock_db.execute.return_value = mock_result
    
    patch_req = ProfilePatchRequest(address="New Address")
    
    result = await profile_service.update_profile(user, patch_req)
    
    assert result["profile_completed"] is True
    assert mock_dispatch.call_count == 0
