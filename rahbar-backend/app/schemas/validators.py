import re
from typing import Annotated
from pydantic import StringConstraints, field_validator, BaseModel, EmailStr

class PhoneMixin(BaseModel):
    phone_number: str

    @field_validator("phone_number")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        # Strip all whitespaces
        v = re.sub(r'\s+', '', v)
        # Normalize local Pakistani numbers (e.g., 03001234567 -> +923001234567)
        if v.startswith("03") and len(v) == 11:
            v = "+92" + v[1:]
        
        # Check basic E.164 format
        if not re.match(r'^\+[1-9]\d{1,14}$', v):
            raise ValueError("Phone number must be in valid E.164 format (e.g. +923001234567)")
        # If it's a Pakistan number, enforce exact length (13 chars: +92 plus 10 digits)
        if v.startswith("+92") and len(v) != 13:
            raise ValueError("Invalid Pakistan phone number length")
        return v

class UsernameMixin(BaseModel):
    username: Annotated[str, StringConstraints(strip_whitespace=True, min_length=3, max_length=30)]

    @field_validator("username")
    @classmethod
    def validate_username(cls, v: str) -> str:
        if not re.match(r'^[a-zA-Z0-9_]+$', v):
            raise ValueError("Username can only contain alphanumeric characters and underscores")
        return v.lower()

class FullNameMixin(BaseModel):
    full_name: Annotated[str, StringConstraints(strip_whitespace=True, min_length=2, max_length=100)]

    @field_validator("full_name")
    @classmethod
    def validate_full_name(cls, v: str) -> str:
        if not re.match(r'^[a-zA-Z\s\-]+$', v):
            raise ValueError("Full name contains invalid characters")
        return v.title()

class EmailMixin(BaseModel):
    # Only validates the format of the email, not ownership
    email: EmailStr
