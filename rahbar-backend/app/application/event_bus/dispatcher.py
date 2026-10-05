import asyncio
from typing import Callable, Dict, List, Type, Awaitable
from app.domain.events.base import DomainEvent
from app.core.logging import logger
EventHandler = Callable[[DomainEvent], Awaitable[None]]
class EventDispatcher:
    def __init__(self):
        self._handlers: Dict[Type[DomainEvent], List[EventHandler]] = {}
    def register(self, event_type: Type[DomainEvent], handler: EventHandler):
        if event_type not in self._handlers: self._handlers[event_type] = []
        self._handlers[event_type].append(handler)
        logger.info(f"Registered handler {handler.__name__} for event {event_type.__name__}")
    async def dispatch(self, event: DomainEvent):
        event_type = type(event)
        handlers = self._handlers.get(event_type, [])
        if not handlers: return
        tasks = [self._execute_handler(h, event) for h in handlers]
        await asyncio.gather(*tasks)
    async def _execute_handler(self, handler: EventHandler, event: DomainEvent):
        try: await handler(event)
        except Exception as e: logger.error(f"Error {e}")
dispatcher = EventDispatcher()
