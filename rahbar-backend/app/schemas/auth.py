from pydantic import BaseModel
from app.schemas.validators import PhoneMixin

from pydantic import BaseModel, Field

class OtpRequest(PhoneMixin): pass

class OtpVerifyRequest(PhoneMixin):
    otp: str = Field(pattern=r"^\d{6}$", description="Exactly 6 digits")

class OtpRequestResponse(BaseModel):
    message: str
    expires_in: int
    resend_after: int

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    is_new_user: bool = False
    profile_completed: bool = False
    next_step: str = "home"

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class TokenRefreshResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class LogoutRequest(BaseModel):
    refresh_token: str

class LogoutResponse(BaseModel):
    message: str
