import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.core.security import create_access_token, create_refresh_token
from unittest.mock import AsyncMock
import uuid

@pytest.mark.asyncio
async def test_profile_requires_auth():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/api/v1/profile")
        assert response.status_code == 401

@pytest.mark.asyncio
async def test_profile_rejects_refresh_token():
    user_id = uuid.uuid4()
    refresh_token = create_refresh_token({"sub": str(user_id)})
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get(
            "/api/v1/profile", 
            headers={"Authorization": f"Bearer {refresh_token}"}
        )
        assert response.status_code == 401

@pytest.mark.asyncio
async def test_profile_cnic_validation():
    # Test valid
    from app.schemas.profile import ProfileBase
    
    # valid
    p = ProfileBase(cnic="35202-1234567-1")
    assert p.cnic == "3520212345671"
    
    # invalid length
    with pytest.raises(ValueError):
        ProfileBase(cnic="35202-123456-1")
        
    # invalid chars
    with pytest.raises(ValueError):
        ProfileBase(cnic="35202-1234567-a")

@pytest.mark.asyncio
async def test_profile_username_validation():
    from app.schemas.profile import ProfileBase
    
    p = ProfileBase(username=" Jawad_Ahmed123 ")
    assert p.username == "jawad_ahmed123"
    
    with pytest.raises(ValueError):
        ProfileBase(username="a b")

@pytest.mark.asyncio
async def test_profile_dob_validation():
    from app.schemas.profile import ProfileBase
    from datetime import date, timedelta
    
    with pytest.raises(ValueError):
        ProfileBase(date_of_birth=date.today() + timedelta(days=1))
