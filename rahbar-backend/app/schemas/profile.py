from datetime import date
from typing import Optional
from pydantic import BaseModel, EmailStr, Field, validator
import re

class ProfileBase(BaseModel):
    full_name: Optional[str] = Field(None, min_length=1, max_length=100)
    username: Optional[str] = Field(None, min_length=3, max_length=30)
    cnic: Optional[str] = None
    email: Optional[EmailStr] = None
    gender: Optional[str] = None
    date_of_birth: Optional[date] = None
    province: Optional[str] = Field(None, max_length=100)
    city: Optional[str] = Field(None, max_length=100)
    district: Optional[str] = Field(None, max_length=100)
    address: Optional[str] = Field(None, max_length=255)
    emergency_contact_number: Optional[str] = None
    emergency_contact_relationship: Optional[str] = Field(None, max_length=100)
    blood_group: Optional[str] = Field(None, max_length=10)
    medical_conditions: Optional[str] = None
    disability: Optional[str] = None
    profession: Optional[str] = Field(None, max_length=100)
    institute_organization: Optional[str] = Field(None, max_length=150)
    profile_image_url: Optional[str] = None

    @validator('full_name')
    def validate_full_name(cls, v):
        if v is not None:
            v = v.strip()
            if not v:
                raise ValueError("Full name cannot be empty")
        return v

    @validator('username')
    def validate_username(cls, v):
        if v is not None:
            v = v.lower().strip()
            if not re.match(r'^[a-z0-9_]+$', v):
                raise ValueError("Username can only contain letters, numbers, and underscores")
        return v

    @validator('cnic')
    def validate_cnic(cls, v):
        if v is not None:
            v = v.replace("-", "").replace(" ", "")
            if len(v) != 13 or not v.isdigit():
                raise ValueError("CNIC must be exactly 13 digits")
        return v

    @validator('date_of_birth')
    def validate_dob(cls, v):
        if v is not None:
            from datetime import date
            if v > date.today():
                raise ValueError("Date of birth cannot be in the future")
        return v

    @validator('emergency_contact_number')
    def validate_emergency_contact(cls, v):
        if v is not None:
            from app.schemas.validators import PhoneMixin
            class Dummy(PhoneMixin): pass
            return Dummy(phone_number=v).phone_number
        return v

    class Config:
        orm_mode = True

class ProfilePatchRequest(ProfileBase):
    pass

class ProfileResponse(BaseModel):
    phone_number: str
    phone_verified: bool
    profile_completed: bool

    full_name: Optional[str] = None
    username: Optional[str] = None
    cnic: Optional[str] = None
    email: Optional[EmailStr] = None
    gender: Optional[str] = None
    date_of_birth: Optional[date] = None
    province: Optional[str] = None
    city: Optional[str] = None
    district: Optional[str] = None
    address: Optional[str] = None
    emergency_contact_number: Optional[str] = None
    emergency_contact_relationship: Optional[str] = None
    blood_group: Optional[str] = None
    medical_conditions: Optional[str] = None
    disability: Optional[str] = None
    profession: Optional[str] = None
    institute_organization: Optional[str] = None
    profile_image_url: Optional[str] = None

    @validator('cnic')
    def mask_cnic(cls, v):
        if v and len(v) == 13:
            return f"{v[:5]}-*******-{v[-1]}"
        return v

class ProfileUpdateResponse(BaseModel):
    profile_completed: bool
    next_step: str
    profile: ProfileResponse
