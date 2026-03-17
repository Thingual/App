"""Pydantic schemas for request/response validation."""

from pydantic import BaseModel, EmailStr, Field, field_validator, ConfigDict
from typing import Optional
from datetime import datetime
from enum import Enum


class AuthMethodEnum(str, Enum):
    """Auth method enum"""
    EMAIL = "email"
    PHONE = "phone"
    GOOGLE = "google"


# ==================== Signup Schemas ====================

class EmailSignupRequest(BaseModel):
    """Email signup request"""
    email: EmailStr
    password: str = Field(..., min_length=8, description="Password must be at least 8 characters")
    name: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None

    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "password": "SecurePass123!",
                "first_name": "John",
                "last_name": "Doe"
            }
        }


class PhoneSignupRequest(BaseModel):
    """Phone signup request - initial step"""
    phone: str = Field(..., description="Phone number with country code, e.g., +1234567890")
    country_code: str = Field(..., description="Country code like +1, +91, etc.")

    class Config:
        json_schema_extra = {
            "example": {
                "phone": "+11234567890",
                "country_code": "+1"
            }
        }


class PhoneOTPRequest(BaseModel):
    """Phone OTP submission"""
    phone: str
    otp: str = Field(..., min_length=6, max_length=6, description="6-digit OTP")

    class Config:
        json_schema_extra = {
            "example": {
                "phone": "+11234567890",
                "otp": "123456"
            }
        }


class GoogleSignupRequest(BaseModel):
    """Google OAuth signup request"""
    google_id_token: str = Field(..., description="Google ID token from frontend")
    first_name: Optional[str] = None
    last_name: Optional[str] = None

    class Config:
        json_schema_extra = {
            "example": {
                "google_id_token": "eyJhbGc...",
                "first_name": "John",
                "last_name": "Doe"
            }
        }


# ==================== Login Schemas ====================

class EmailLoginRequest(BaseModel):
    """Email login request"""
    email: EmailStr
    password: str

    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "password": "SecurePass123!"
            }
        }


class PhoneLoginRequest(BaseModel):
    """Phone login request - initial step"""
    phone: str = Field(..., description="Phone number with country code")
    country_code: str = Field(..., description="Country code")

    class Config:
        json_schema_extra = {
            "example": {
                "phone": "+11234567890",
                "country_code": "+1"
            }
        }


class GoogleLoginRequest(BaseModel):
    """Google OAuth login request"""
    google_id_token: str = Field(..., description="Google ID token from frontend")

    class Config:
        json_schema_extra = {
            "example": {
                "google_id_token": "eyJhbGc..."
            }
        }


# ==================== Response Schemas ====================

class UserResponse(BaseModel):
    """User profile response"""
    id: str
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    profile_picture_url: Optional[str] = None
    email_verified: bool = False
    phone_verified: bool = False
    auth_method: AuthMethodEnum = AuthMethodEnum.EMAIL
    created_at: datetime
    last_login: Optional[datetime] = None

    @field_validator("id", mode="before")
    @classmethod
    def _coerce_id_to_str(cls, v):
        return str(v) if v is not None else v

    model_config = ConfigDict(from_attributes=True)


class TokenResponse(BaseModel):
    """Token response for authentication"""
    access_token: str
    refresh_token: Optional[str] = None
    token_type: str = "bearer"
    expires_in: int  # seconds
    user: UserResponse

    class Config:
        json_schema_extra = {
            "example": {
                "access_token": "eyJhbGc...",
                "refresh_token": "eyJhbGc...",
                "token_type": "bearer",
                "expires_in": 1800,
                "user": {
                    "id": "uuid",
                    "email": "user@example.com",
                    "first_name": "John",
                    "email_verified": True,
                    "phone_verified": False,
                    "auth_method": "email"
                }
            }
        }


class OTPSentResponse(BaseModel):
    """OTP sent confirmation"""
    success: bool
    message: str
    phone: Optional[str] = None
    expires_in_seconds: int = 600  # 10 minutes

    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "message": "OTP sent successfully",
                "phone": "+11234567890",
                "expires_in_seconds": 600
            }
        }


class EmailSentResponse(BaseModel):
    """Email sent confirmation"""
    success: bool
    message: str
    email: Optional[str] = None
    expires_in_seconds: int = 1800  # 30 minutes

    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "message": "Verification email sent successfully",
                "email": "user@example.com",
                "expires_in_seconds": 1800
            }
        }


class RefreshTokenRequest(BaseModel):
    """Refresh token request"""
    refresh_token: str


class ChangePasswordRequest(BaseModel):
    """Change password request"""
    old_password: str
    new_password: str = Field(..., min_length=8)

    class Config:
        json_schema_extra = {
            "example": {
                "old_password": "OldPass123!",
                "new_password": "NewPass456!"
            }
        }


class ResetPasswordRequest(BaseModel):
    """Password reset request"""
    email: EmailStr


class ResetPasswordConfirmRequest(BaseModel):
    """Password reset confirmation"""
    token: str
    new_password: str = Field(..., min_length=8)


class ErrorResponse(BaseModel):
    """Error response"""
    success: bool = False
    error: str
    details: Optional[dict] = None

    class Config:
        json_schema_extra = {
            "example": {
                "success": False,
                "error": "Invalid credentials",
                "details": {"field": "email"}
            }
        }
