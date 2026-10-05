import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from app.application.services.auth_service import AuthService
from app.domain.entities.user import User
from app.domain.entities.session import DeviceSession
from app.core.security import create_refresh_token, create_access_token, hash_refresh_token
import uuid
from datetime import datetime, timezone

@pytest.fixture
def mock_db():
    db = AsyncMock()
    db.flush = AsyncMock()
    db.commit = AsyncMock()
    db.rollback = AsyncMock()
    db.add = MagicMock()
    return db

@pytest.fixture
def mock_otp():
    return AsyncMock()

@pytest.fixture
def auth_service(mock_db, mock_otp):
    return AuthService(mock_db, mock_otp)

def create_valid_user():
    return User(
        id=uuid.uuid4(),
        phone_number="+923001234567",
        account_status="active",
        profile_completed=True
    )

def create_valid_session(user_id, token_hash):
    return DeviceSession(
        id=uuid.uuid4(),
        user_id=user_id,
        refresh_token_hash=token_hash,
        is_revoked=False,
        created_at=datetime.now(timezone.utc),
        last_used_at=datetime.now(timezone.utc)
    )

@pytest.mark.asyncio
async def test_refresh_token_success(mock_db, auth_service):
    user = create_valid_user()
    old_refresh_token = create_refresh_token({"sub": str(user.id)})
    old_hash = hash_refresh_token(old_refresh_token)
    session = create_valid_session(user.id, old_hash)

    # Mock DB responses
    def side_effect_execute(*args, **kwargs):
        mock_result = MagicMock()
        # Look at the string representation of the statement or rely on order
        # First execute is session, second is user
        if mock_db.execute.call_count == 1:
            mock_result.scalar_one_or_none.return_value = session
        else:
            mock_result.scalar_one_or_none.return_value = user
        return mock_result

    mock_db.execute = AsyncMock(side_effect=side_effect_execute)

    result = await auth_service.refresh_token(old_refresh_token)
    
    assert "access_token" in result
    assert "refresh_token" in result
    assert result["refresh_token"] != old_refresh_token
    
    # Assert session was updated
    assert session.refresh_token_hash != old_hash
    assert mock_db.commit.call_count == 1
    assert mock_db.rollback.call_count == 0

@pytest.mark.asyncio
async def test_refresh_token_access_token_rejected(mock_db, auth_service):
    user = create_valid_user()
    access_token = create_access_token({"sub": str(user.id)})
    
    result = await auth_service.refresh_token(access_token)
    assert result == {"error": "invalid_session"}

@pytest.mark.asyncio
async def test_refresh_token_revoked_session(mock_db, auth_service):
    user = create_valid_user()
    old_refresh_token = create_refresh_token({"sub": str(user.id)})
    old_hash = hash_refresh_token(old_refresh_token)
    session = create_valid_session(user.id, old_hash)
    session.is_revoked = True

    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = None # Because where clause checks is_revoked == False
    mock_db.execute.return_value = mock_result

    result = await auth_service.refresh_token(old_refresh_token)
    assert result == {"error": "invalid_session"}
    assert mock_db.commit.call_count == 0

@pytest.mark.asyncio
async def test_refresh_token_inactive_user(mock_db, auth_service):
    user = create_valid_user()
    user.account_status = "suspended"
    old_refresh_token = create_refresh_token({"sub": str(user.id)})
    old_hash = hash_refresh_token(old_refresh_token)
    session = create_valid_session(user.id, old_hash)

    def side_effect_execute(*args, **kwargs):
        mock_result = MagicMock()
        if mock_db.execute.call_count == 1:
            mock_result.scalar_one_or_none.return_value = session
        else:
            mock_result.scalar_one_or_none.return_value = user
        return mock_result

    mock_db.execute = AsyncMock(side_effect=side_effect_execute)

    result = await auth_service.refresh_token(old_refresh_token)
    assert result == {"error": "invalid_session"}
    assert mock_db.commit.call_count == 0

@pytest.mark.asyncio
async def test_refresh_token_db_failure_rolls_back(mock_db, auth_service):
    user = create_valid_user()
    old_refresh_token = create_refresh_token({"sub": str(user.id)})
    old_hash = hash_refresh_token(old_refresh_token)
    session = create_valid_session(user.id, old_hash)

    def side_effect_execute(*args, **kwargs):
        mock_result = MagicMock()
        if mock_db.execute.call_count == 1:
            mock_result.scalar_one_or_none.return_value = session
        else:
            mock_result.scalar_one_or_none.return_value = user
        return mock_result

    mock_db.execute = AsyncMock(side_effect=side_effect_execute)
    mock_db.commit = AsyncMock(side_effect=Exception("DB Error"))

    result = await auth_service.refresh_token(old_refresh_token)
    assert result == {"error": "invalid_session"}
    assert mock_db.rollback.call_count == 1

@pytest.mark.asyncio
async def test_logout_success(mock_db, auth_service):
    token = create_refresh_token({"sub": str(uuid.uuid4())})
    session = create_valid_session(uuid.uuid4(), hash_refresh_token(token))
    
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = session
    mock_db.execute.return_value = mock_result
    
    result = await auth_service.logout(token)
    
    assert result == {"message": "Logged out successfully"}
    assert session.is_revoked is True
    assert mock_db.commit.call_count == 1

@pytest.mark.asyncio
async def test_logout_idempotent_already_revoked(mock_db, auth_service):
    token = create_refresh_token({"sub": str(uuid.uuid4())})
    session = create_valid_session(uuid.uuid4(), hash_refresh_token(token))
    session.is_revoked = True
    
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = session
    mock_db.execute.return_value = mock_result
    
    result = await auth_service.logout(token)
    
    assert result == {"message": "Logged out successfully"}
    assert mock_db.commit.call_count == 0 # No update needed

@pytest.mark.asyncio
async def test_logout_idempotent_not_found(mock_db, auth_service):
    token = create_refresh_token({"sub": str(uuid.uuid4())})
    
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = None
    mock_db.execute.return_value = mock_result
    
    result = await auth_service.logout(token)
    
    assert result == {"message": "Logged out successfully"}
    assert mock_db.commit.call_count == 0
