import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.core.security import create_refresh_token, create_access_token
import uuid

@pytest.mark.asyncio
async def test_refresh_route_invalid_token():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post("/api/v1/auth/refresh", json={"refresh_token": "not.a.token"})
        assert response.status_code == 401
        assert response.json() == {"detail": "Invalid or expired session"}

@pytest.mark.asyncio
async def test_refresh_route_access_token():
    token = create_access_token({"sub": str(uuid.uuid4())})
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post("/api/v1/auth/refresh", json={"refresh_token": token})
        assert response.status_code == 401
        assert response.json() == {"detail": "Invalid or expired session"}

@pytest.mark.asyncio
async def test_logout_route_invalid_token():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post("/api/v1/auth/logout", json={"refresh_token": "not.a.token"})
        assert response.status_code == 200
        assert response.json() == {"message": "Logged out successfully"}
