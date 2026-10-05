import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from app.application.services.auth_service import AuthService
from app.domain.entities.user import User
from app.domain.entities.session import DeviceSession
from app.domain.events.user_events import PhoneVerified, UserCreated, UserRegistered, UserLoggedIn

@pytest.fixture
def mock_db():
    db = AsyncMock()
    # Mock nested transaction
    nested = MagicMock()
    nested.__aenter__ = AsyncMock()
    nested.__aexit__ = AsyncMock()
    db.begin_nested = MagicMock(return_value=nested)
    db.begin = MagicMock(return_value=nested)
    db.in_transaction = MagicMock(return_value=True)
    db.add = MagicMock()
    return db

@pytest.fixture
def mock_otp():
    otp = AsyncMock()
    otp.verify_otp.return_value = True
    return otp

@pytest.fixture
def auth_service(mock_db, mock_otp):
    return AuthService(mock_db, mock_otp)

@pytest.mark.asyncio
@patch("app.application.services.auth_service.dispatcher.dispatch", new_callable=AsyncMock)
async def test_verify_and_login_new_user(mock_dispatch, mock_db, mock_otp, auth_service):
    # Mock DB query to return None (new user)
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = None
    mock_db.execute.return_value = mock_result
    
    # Needs to set ID when flushed
    def fake_flush():
        for obj in mock_db.add.call_args_list:
            model = obj.args[0]
            if isinstance(model, User):
                import uuid
                model.id = uuid.uuid4()
    mock_db.flush = AsyncMock(side_effect=fake_flush)

    result = await auth_service.verify_and_login("+923001234567", "123456")
    
    # Assertions
    assert "access_token" in result
    assert "refresh_token" in result
    assert result["is_new_user"] is True
    assert result["profile_completed"] is False
    assert result["next_step"] == "complete_profile"
    
    # Check DB
    assert mock_db.commit.call_count == 1
    assert mock_db.add.call_count == 2 # User and DeviceSession
    
    # Check Events
    assert mock_dispatch.call_count == 4
    event_types = [type(call.args[0]) for call in mock_dispatch.call_args_list]
    assert PhoneVerified in event_types
    assert UserCreated in event_types
    assert UserRegistered in event_types
    assert UserLoggedIn in event_types


@pytest.mark.asyncio
@patch("app.application.services.auth_service.dispatcher.dispatch", new_callable=AsyncMock)
async def test_verify_and_login_existing_completed_user(mock_dispatch, mock_db, mock_otp, auth_service):
    import uuid
    existing_user = User(
        id=uuid.uuid4(),
        phone_number="+923001234567",
        phone_verified=True,
        profile_completed=True,
        account_status="active"
    )
    
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = existing_user
    mock_db.execute.return_value = mock_result

    result = await auth_service.verify_and_login("+923001234567", "123456")
    
    assert result["is_new_user"] is False
    assert result["profile_completed"] is True
    assert result["next_step"] == "home"
    
    assert mock_db.commit.call_count == 1
    assert mock_db.add.call_count == 1 # Only DeviceSession
    
    # Check Events (Should NOT have UserCreated/Registered)
    assert mock_dispatch.call_count == 2
    event_types = [type(call.args[0]) for call in mock_dispatch.call_args_list]
    assert PhoneVerified in event_types
    assert UserLoggedIn in event_types
    assert UserCreated not in event_types


@pytest.mark.asyncio
async def test_verify_and_login_inactive_user(mock_db, mock_otp, auth_service):
    existing_user = User(
        phone_number="+923001234567",
        account_status="suspended"
    )
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = existing_user
    mock_db.execute.return_value = mock_result

    result = await auth_service.verify_and_login("+923001234567", "123456")
    
    assert result == {"error": "inactive_account"}
    assert mock_db.commit.call_count == 0
    assert mock_db.add.call_count == 0


@pytest.mark.asyncio
async def test_verify_and_login_invalid_otp(mock_db, mock_otp, auth_service):
    mock_otp.verify_otp.return_value = False
    
    result = await auth_service.verify_and_login("+923001234567", "000000")
    
    assert result == {"error": "invalid_otp"}
    assert mock_db.commit.call_count == 0


@pytest.mark.asyncio
@patch("app.application.services.auth_service.dispatcher.dispatch", new_callable=AsyncMock)
async def test_verify_and_login_db_failure_rolls_back(mock_dispatch, mock_db, mock_otp, auth_service):
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = None
    mock_db.execute.return_value = mock_result
    
    # Make commit raise an error to verify rollback
    mock_db.commit = AsyncMock(side_effect=Exception("Database error"))

    with pytest.raises(Exception):
        await auth_service.verify_and_login("+923001234567", "123456")
    
    assert mock_db.commit.call_count == 1
    assert mock_db.rollback.call_count == 1
    assert mock_dispatch.call_count == 0 # No events emitted

