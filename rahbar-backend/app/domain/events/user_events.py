import uuid
from app.domain.events.base import DomainEvent
class UserCreated(DomainEvent): user_id: uuid.UUID; phone_number: str
class ProfileCompleted(DomainEvent): user_id: uuid.UUID
class PhoneOtpRequested(DomainEvent): phone_number: str
class PhoneOtpSent(DomainEvent): phone_number: str
class PhoneVerified(DomainEvent): user_id: uuid.UUID
class UserRegistered(DomainEvent): user_id: uuid.UUID
class UserLoggedIn(DomainEvent): user_id: uuid.UUID
