import uuid
from datetime import datetime, timezone

from sqlalchemy import Column, String, Boolean, DateTime
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )

    phone_number = Column(
        String,
        unique=True,
        index=True,
        nullable=False,
    )

    phone_verified = Column(
        Boolean,
        nullable=False,
        default=False,
    )

    profile_completed = Column(
        Boolean,
        nullable=False,
        default=False,
    )

    preferred_language = Column(
        String,
        nullable=False,
        default="en",
    )

    account_status = Column(
        String,
        nullable=False,
        default="active",
    )

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
    )

    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )