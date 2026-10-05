import uuid
from datetime import datetime, timezone
from pydantic import BaseModel, Field
class DomainEvent(BaseModel):
    event_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    occurred_on: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
