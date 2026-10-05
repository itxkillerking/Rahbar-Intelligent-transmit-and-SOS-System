import pytest
from unittest.mock import AsyncMock, patch, MagicMock
from app.application.services.otp_service import OTPService
from app.core.exceptions import OtpDeliveryError
from app.core.config import settings
from app.domain.events.user_events import PhoneOtpRequested, PhoneOtpSent


class MockSmsService:
    async def send_otp(self, phone: str, otp: str) -> bool:
        return True
        
    async def send_emergency_message(self, phone: str, msg: str) -> bool:
        return True


@pytest.fixture
def sms_service():
    service = MockSmsService()
    service.send_otp = AsyncMock(return_value=True)
    return service


@pytest.fixture
def otp_service(sms_service):
    return OTPService(sms_service)


@pytest.mark.asyncio
@patch("app.application.services.otp_service.redis_client")
@patch("app.application.services.otp_service.dispatcher.dispatch", new_callable=AsyncMock)
async def test_otp_request_creates_state_and_sends_sms(mock_dispatch, mock_redis, otp_service):
    # Setup mocks
    mock_redis.exists.return_value = False
    
    mock_pipeline = MagicMock()
    mock_redis.pipeline = MagicMock(return_value=mock_pipeline)
    mock_pipeline.execute = AsyncMock()
    
    # Needs rate limit to pass
    with patch.object(otp_service.rate_limiter, 'check', new_callable=AsyncMock) as mock_rl_check:
        mock_rl_check.return_value = True
        
        await otp_service.request_otp("+923001234567")
        
        # Verify rate limit called
        mock_rl_check.assert_called_once()
        
        # Verify pipeline set hash, cooldown, and attempts
        assert mock_pipeline.set.call_count == 3
        
        # Verify SMS called
        otp_service.sms_service.send_otp.assert_called_once()
        
        # Verify events
        assert mock_dispatch.call_count == 2
        args1, _ = mock_dispatch.call_args_list[0]
        args2, _ = mock_dispatch.call_args_list[1]
        assert isinstance(args1[0], PhoneOtpRequested)
        assert isinstance(args2[0], PhoneOtpSent)


@pytest.mark.asyncio
@patch("app.application.services.otp_service.redis_client")
@patch("app.application.services.otp_service.dispatcher.dispatch", new_callable=AsyncMock)
async def test_otp_sms_failure_cleans_up_and_does_not_emit_sent(mock_dispatch, mock_redis, otp_service):
    mock_redis.exists.return_value = False
    mock_pipeline = MagicMock()
    mock_redis.pipeline = MagicMock(return_value=mock_pipeline)
    mock_pipeline.execute = AsyncMock()
    
    # Make SMS fail
    otp_service.sms_service.send_otp.return_value = False
    
    with patch.object(otp_service.rate_limiter, 'check', new_callable=AsyncMock) as mock_rl_check:
        mock_rl_check.return_value = True
        
        with pytest.raises(OtpDeliveryError) as exc:
            await otp_service.request_otp("+923001234567")
            
        assert "Failed to send OTP" in str(exc.value)
        
        # Pipeline 2 should be the cleanup pipeline deleting 3 keys
        assert mock_pipeline.delete.call_count == 3
        
        # Only requested event emitted, NOT sent
        assert mock_dispatch.call_count == 1
        assert isinstance(mock_dispatch.call_args[0][0], PhoneOtpRequested)


@pytest.mark.asyncio
async def test_phone_keys_are_opaque(otp_service):
    phone = "+923001234567"
    key = otp_service._get_phone_key(phone)
    assert phone not in key
    assert len(key) == 64  # sha256 hex


@pytest.mark.asyncio
@patch("app.application.services.otp_service.redis_client")
async def test_correct_otp_verifies_and_consumes_atomically(mock_redis, otp_service):
    raw_otp = "123456"
    hashed_otp = otp_service._hash_otp(raw_otp)
    
    mock_redis.get.return_value = hashed_otp
    mock_redis.eval = AsyncMock(return_value=1) # Lua success
    mock_redis.delete = AsyncMock()
    
    result = await otp_service.verify_otp("+923001234567", raw_otp)
    
    assert result is True
    mock_redis.eval.assert_called_once()
    # It should delete attempts state on success
    mock_redis.delete.assert_called_once()
    # incr (wrong attempt) should NOT be called
    mock_redis.incr.assert_not_called()


@pytest.mark.asyncio
@patch("app.application.services.otp_service.redis_client")
async def test_wrong_otp_increments_attempts(mock_redis, otp_service):
    mock_redis.get.return_value = "some_other_hash"
    mock_redis.incr = AsyncMock(return_value=1)
    
    result = await otp_service.verify_otp("+923001234567", "123456")
    
    assert result is False
    mock_redis.incr.assert_called_once()


@pytest.mark.asyncio
@patch("app.application.services.otp_service.redis_client")
async def test_five_wrong_attempts_invalidates(mock_redis, otp_service):
    mock_redis.get.return_value = "some_other_hash"
    mock_redis.incr = AsyncMock(return_value=5) # Max
    
    mock_pipeline = MagicMock()
    mock_redis.pipeline = MagicMock(return_value=mock_pipeline)
    mock_pipeline.execute = AsyncMock()
    
    result = await otp_service.verify_otp("+923001234567", "123456")
    
    assert result is False
    # Pipeline should delete hash and attempts immediately
    assert mock_pipeline.delete.call_count == 2
    mock_pipeline.execute.assert_called_once()


@pytest.mark.asyncio
@patch("app.application.services.otp_service.redis_client")
async def test_verify_race_condition_rejected(mock_redis, otp_service):
    raw_otp = "123456"
    hashed_otp = otp_service._hash_otp(raw_otp)
    
    mock_redis.get.return_value = hashed_otp
    # Lua script returns 0 (meaning key was already deleted by another request)
    mock_redis.eval = AsyncMock(return_value=0) 
    
    result = await otp_service.verify_otp("+923001234567", raw_otp)
    
    assert result is False


@pytest.mark.asyncio
async def test_rate_limiter_fourth_request_blocked():
    from app.core.rate_limit import RateLimiter
    from app.core.redis import redis_client
    
    with patch.object(redis_client, 'incr', new_callable=AsyncMock) as mock_incr:
        # Simulate incr returning 1, 2, 3, 4
        mock_incr.side_effect = [1, 2, 3, 4]
        with patch.object(redis_client, 'expire', new_callable=AsyncMock):
            limiter = RateLimiter(requests=3, window=300)
            
            assert await limiter.check("test") is True
            assert await limiter.check("test") is True
            assert await limiter.check("test") is True
            assert await limiter.check("test") is False
