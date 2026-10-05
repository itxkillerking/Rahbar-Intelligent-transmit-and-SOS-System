import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.mark.asyncio
async def test_health_check_basic():
    transport = ASGITransport(app=app)
    from unittest.mock import AsyncMock, MagicMock
    with pytest.MonkeyPatch.context() as m:
        mock_connection = AsyncMock()
        mock_connection.execute = AsyncMock()
        
        # We need an async context manager mock
        class AsyncContextManagerMock:
            async def __aenter__(self):
                return mock_connection
            async def __aexit__(self, exc_type, exc_val, exc_tb):
                pass
                
        mock_engine = MagicMock()
        mock_engine.connect.return_value = AsyncContextManagerMock()
        m.setattr("app.api.v1.health.engine", mock_engine)
        
        async with AsyncClient(
            transport=transport,
            base_url="http://test"
        ) as client:
            response = await client.get("/api/v1/health")

    assert response.status_code == 200
    data = response.json()
    assert data["database"] == "connected"