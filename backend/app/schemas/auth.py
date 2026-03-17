from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional
from datetime import datetime


class UserSignup(BaseModel):
    email: EmailStr
    password: str

    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class GoogleAuth(BaseModel):
    id_token: str


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    email: Optional[str] = None
    user_id: Optional[str] = None


class UserResponse(BaseModel):
    id: int
    email: Optional[str] = None
    name: Optional[str] = None
    created_at: Optional[datetime] = None


class SignupResponse(BaseModel):
    message: str
    user_id: str


class MessageResponse(BaseModel):
    message: str
    detail: Optional[str] = None
