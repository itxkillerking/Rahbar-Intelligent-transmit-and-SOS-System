import pytest
import asyncio
from app.application.event_bus.dispatcher import dispatcher
from app.domain.events.user_events import PhoneOtpRequested
@pytest.mark.asyncio
async def test_event_bus_dispatch():
    received = False
    async def mock_handler(event: PhoneOtpRequested):
        nonlocal received
        received = True
        assert event.phone_number == "+923001234567"
    dispatcher.register(PhoneOtpRequested, mock_handler)
    event = PhoneOtpRequested(phone_number="+923001234567")
    await dispatcher.dispatch(event)
    assert received is True
