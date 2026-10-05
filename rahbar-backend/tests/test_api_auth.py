import pytest
from httpx import AsyncClient, ASGITransport
from unittest.mock import AsyncMock
from app.main import app
from app.api.dependencies import get_otp_service
from app.core.exceptions import OtpDeliveryError, OtpRateLimitError, OtpCooldownError

class MockSuccessOTPService:
    async def request_otp(self, phone: str) -> None:
        pass

class MockRateLimitOTPService:
    async def request_otp(self, phone: str) -> None:
        raise OtpRateLimitError("Too many OTP requests. Please try again later.")

class MockCooldownOTPService:
    async def request_otp(self, phone: str) -> None:
        raise OtpCooldownError("Please wait before requesting another OTP.")

class MockFailureOTPService:
    async def request_otp(self, phone: str) -> None:
        raise OtpDeliveryError("Mock failure")


@pytest.fixture
def mock_success_otp():
    return MockSuccessOTPService()

@pytest.fixture
def mock_failure_otp():
    return MockFailureOTPService()

@pytest.fixture
def mock_rate_limit_otp():
    return MockRateLimitOTPService()

@pytest.fixture
def mock_cooldown_otp():
    return MockCooldownOTPService()


@pytest.mark.asyncio
async def test_request_otp_success(mock_success_otp):
    # Override dependency
    app.dependency_overrides[get_otp_service] = lambda: mock_success_otp
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post(
            "/api/v1/auth/request-otp",
            json={"phone_number": "03001234567"}
        )
    
    # Restore dependency
    app.dependency_overrides.clear()
    
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "OTP sent successfully"
    assert "expires_in" in data
    assert "resend_after" in data
    assert "otp" not in data # Raw OTP must not be leaked

@pytest.mark.asyncio
async def test_request_otp_invalid_phone():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post(
            "/api/v1/auth/request-otp",
            json={"phone_number": "123"}
        )
        
    assert response.status_code == 422 # Pydantic validation

@pytest.mark.asyncio
async def test_request_otp_sms_failure_503(mock_failure_otp):
    app.dependency_overrides[get_otp_service] = lambda: mock_failure_otp
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post(
            "/api/v1/auth/request-otp",
            json={"phone_number": "03009999999"}
        )
        
    app.dependency_overrides.clear()
    
    assert response.status_code == 503
    assert "Mock failure" in response.json()["detail"]

@pytest.mark.asyncio
async def test_request_otp_cooldown_429(mock_cooldown_otp):
    app.dependency_overrides[get_otp_service] = lambda: mock_cooldown_otp
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post("/api/v1/auth/request-otp", json={"phone_number": "03008888888"})
        assert response.status_code == 429
        assert "Please wait" in response.json()["detail"]
        
    app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_request_otp_rate_limit_429(mock_rate_limit_otp):
    app.dependency_overrides[get_otp_service] = lambda: mock_rate_limit_otp
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post("/api/v1/auth/request-otp", json={"phone_number": "03001111111"})
        assert response.status_code == 429
        assert "Too many OTP requests" in response.json()["detail"]
        
    app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_request_otp_no_provider_503():
    # Do NOT mock get_otp_service for this one, so it uses the real provider logic.
    # However, to avoid real Redis failing on the Rate Limit due to closed loop,
    # we must mock the rate_limiter and redis inside the service, or mock redis globally.
    # Actually, we can just mock get_sms_service to return UnconfiguredSmsService, 
    # but that's what it does by default. To prevent Redis errors, we'll patch redis_client.
    with pytest.MonkeyPatch.context() as m:
        from unittest.mock import AsyncMock, MagicMock
        import app.application.services.otp_service as os
        redis_mock = AsyncMock()
        redis_mock.exists.return_value = False
        mock_pipeline = MagicMock()
        redis_mock.pipeline = MagicMock(return_value=mock_pipeline)
        mock_pipeline.execute = AsyncMock()
        m.setattr(os, "redis_client", redis_mock)
        m.setattr(os.RateLimiter, "check", AsyncMock(return_value=True))
        
        from app.api.dependencies import get_sms_service, UnconfiguredSmsService
        app.dependency_overrides[get_sms_service] = lambda: UnconfiguredSmsService()
        
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as ac:
            response = await ac.post(
                "/api/v1/auth/request-otp",
                json={"phone_number": "03007777777"}
            )
            
        app.dependency_overrides.clear()
        
        assert response.status_code == 503
        assert "Failed to send OTP" in response.json()["detail"]

@pytest.mark.asyncio
async def test_verify_otp_invalid_format():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post("/api/v1/auth/verify-otp", json={"phone_number": "03001234567", "otp": "123"})
        assert response.status_code == 422 # length
        
        response = await ac.post("/api/v1/auth/verify-otp", json={"phone_number": "03001234567", "otp": "12A456"})
        assert response.status_code == 422 # non-numeric

@pytest.mark.asyncio
async def test_verify_otp_invalid_logic():
    # Mock auth_service directly
    from app.application.services.auth_service import AuthService
    from app.api.v1.auth import get_auth_service
    
    class MockAuthService:
        async def verify_and_login(self, phone, otp, ip_address=None):
            return {"error": "invalid_otp"}
            
    app.dependency_overrides[get_auth_service] = lambda: MockAuthService()
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post("/api/v1/auth/verify-otp", json={"phone_number": "03001234567", "otp": "123456"})
        
    app.dependency_overrides.clear()
    assert response.status_code == 400
    assert "Invalid or expired OTP" in response.json()["detail"]


@pytest.mark.asyncio
async def test_verify_otp_inactive_account():
    from app.api.v1.auth import get_auth_service
    class MockAuthService:
        async def verify_and_login(self, phone, otp, ip_address=None):
            return {"error": "inactive_account"}
            
    app.dependency_overrides[get_auth_service] = lambda: MockAuthService()
    
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post("/api/v1/auth/verify-otp", json={"phone_number": "03001234567", "otp": "123456"})
        
    app.dependency_overrides.clear()
    assert response.status_code == 403
    assert "Account is currently unavailable" in response.json()["detail"]


@pytest.mark.asyncio
async def test_dev_otp_route_in_dev_mode():
    from app.core.config import settings
    
    with pytest.MonkeyPatch.context() as m:
        m.setattr(settings, "APP_ENV", "development")
        m.setattr(settings, "SMS_PROVIDER", "dev")
        
        # Need to reload the router to evaluate the `if` block
        import importlib
        import app.api.v1.auth as auth_router_module
        import app.api.v1.router as v1_router_module
        import app.main as main_module
        importlib.reload(auth_router_module)
        importlib.reload(v1_router_module)
        importlib.reload(main_module)
        
        # mock redis
        from unittest.mock import AsyncMock
        import app.core.redis as redis_module
        redis_mock = AsyncMock()
        redis_mock.get.return_value = "123456"
        redis_mock.ttl.return_value = 200
        m.setattr(redis_module, "redis_client", redis_mock)
        
        transport = ASGITransport(app=main_module.app)
        async with AsyncClient(transport=transport, base_url="http://test") as ac:
            response = await ac.get("/api/v1/auth/dev/otp/03001234567")
            
        assert response.status_code == 200
        assert response.json()["otp"] == "123456"
        assert response.json()["development_only"] is True


@pytest.mark.asyncio
async def test_dev_otp_route_forbidden_in_prod():
    from app.core.config import settings
    with pytest.MonkeyPatch.context() as m:
        m.setattr(settings, "APP_ENV", "production")
        m.setattr(settings, "SMS_PROVIDER", "twillio")
        
        import importlib
        import app.api.v1.auth as auth_router_module
        import app.api.v1.router as v1_router_module
        import app.main as main_module
        importlib.reload(auth_router_module)
        importlib.reload(v1_router_module)
        importlib.reload(main_module)
        
        transport = ASGITransport(app=main_module.app)
        async with AsyncClient(transport=transport, base_url="http://test") as ac:
            response = await ac.get("/api/v1/auth/dev/otp/03001234567")
            
        assert response.status_code == 404
