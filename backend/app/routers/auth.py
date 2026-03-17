"""
Authentication router with endpoints for:
- Email signup/login
- Phone OTP signup/login
- Google OAuth signup/login
- Password management
"""
from datetime import timedelta, datetime
from fastapi import APIRouter, Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from typing import Optional

from ..database import get_db
from ..config import get_settings
from ..schemas.auth_schema import (
    EmailSignupRequest,
    EmailLoginRequest,
    PhoneSignupRequest,
    PhoneOTPRequest,
    GoogleSignupRequest,
    GoogleLoginRequest,
    TokenResponse,
    OTPSentResponse,
    UserResponse,
    AuthMethodEnum,
    ChangePasswordRequest,
    ResetPasswordRequest,
    ResetPasswordConfirmRequest,
)
from ..services.auth_service import AuthService
from ..models.user import User

router = APIRouter(prefix="/auth", tags=["Authentication"])
settings = get_settings()


def _to_user_response(user: User, auth_method: AuthMethodEnum = AuthMethodEnum.EMAIL) -> UserResponse:
    return UserResponse(
        id=str(user.id),
        name=getattr(user, "name", None),
        email=getattr(user, "email", None),
        created_at=getattr(user, "created_at"),
        auth_method=auth_method,
    )


def get_current_user(authorization: Optional[str] = Header(None), db: Session = Depends(get_db)) -> User:
    """Dependency to get current authenticated user from JWT token"""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token format")
    
    token = authorization.replace("Bearer ", "")
    user_id = AuthService.verify_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    
    user = AuthService.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    
    return user


# ==================== EMAIL ENDPOINTS ====================

@router.post("/email/signup", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def email_signup(request: EmailSignupRequest, db: Session = Depends(get_db)):
    """Signup with email and password"""
    name = request.name
    if not name:
        parts = [p for p in [request.first_name, request.last_name] if p]
        name = " ".join(parts) if parts else None

    success, message, user = AuthService.email_signup(
        db=db,
        email=request.email,
        password=request.password,
        name=name,
    )
    
    if not success:
        raise HTTPException(status_code=400, detail=message)
    
    access_token, expires_at = AuthService.create_access_token(str(user.id))
    refresh_token = AuthService.create_refresh_token(str(user.id))
    
    expires_in = int((expires_at - datetime.utcnow()).total_seconds())
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=expires_in,
        user=_to_user_response(user)
    )


@router.post("/email/login", response_model=TokenResponse)
async def email_login(request: EmailLoginRequest, db: Session = Depends(get_db)):
    """Login with email and password"""
    success, message, user = AuthService.email_login(
        db=db,
        email=request.email,
        password=request.password
    )
    
    if not success:
        raise HTTPException(status_code=401, detail=message)
    
    access_token, expires_at = AuthService.create_access_token(str(user.id))
    refresh_token = AuthService.create_refresh_token(str(user.id))
    
    expires_in = int((expires_at - datetime.utcnow()).total_seconds())
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=expires_in,
        user=_to_user_response(user)
    )


# ==================== PHONE ENDPOINTS ====================

@router.post("/phone/request-otp", response_model=OTPSentResponse)
async def request_phone_otp(request: PhoneSignupRequest, db: Session = Depends(get_db)):
    """Request OTP for phone signup/login"""
    success, message, otp = AuthService.send_phone_otp(
        db=db,
        phone=request.phone,
        country_code=request.country_code
    )
    
    if not success:
        raise HTTPException(status_code=400, detail=message)
    
    return OTPSentResponse(
        success=True,
        message=message,
        phone=request.phone,
        expires_in_seconds=600
    )


@router.post("/phone/verify-otp", response_model=TokenResponse)
async def verify_phone_otp(request: PhoneOTPRequest, db: Session = Depends(get_db)):
    """Verify OTP and login/signup with phone"""
    success, message, user = AuthService.verify_phone_otp(
        db=db,
        phone=request.phone,
        otp=request.otp
    )
    
    if not success:
        raise HTTPException(status_code=401, detail=message)
    
    access_token, expires_at = AuthService.create_access_token(str(user.id))
    refresh_token = AuthService.create_refresh_token(str(user.id))
    
    expires_in = int((expires_at - datetime.utcnow()).total_seconds())
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=expires_in,
        user=_to_user_response(user)
    )


# ==================== GOOGLE OAUTH ENDPOINTS ====================

@router.post("/google/signup", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def google_signup(request: GoogleSignupRequest, db: Session = Depends(get_db)):
    """Signup with Google OAuth"""
    success, message, user = AuthService.google_signup_login(
        db=db,
        google_id_token_str=request.google_id_token,
        first_name=request.first_name,
        last_name=request.last_name
    )
    
    if not success:
        raise HTTPException(status_code=400, detail=message)
    
    access_token, expires_at = AuthService.create_access_token(str(user.id))
    refresh_token = AuthService.create_refresh_token(str(user.id))
    
    expires_in = int((expires_at - datetime.utcnow()).total_seconds())
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=expires_in,
        user=_to_user_response(user, auth_method=AuthMethodEnum.GOOGLE)
    )


@router.post("/google/login", response_model=TokenResponse)
async def google_login(request: GoogleLoginRequest, db: Session = Depends(get_db)):
    """Login with Google OAuth"""
    success, message, user = AuthService.google_signup_login(
        db=db,
        google_id_token_str=request.google_id_token,
    )
    
    if not success:
        raise HTTPException(status_code=401, detail=message)
    
    access_token, expires_at = AuthService.create_access_token(str(user.id))
    refresh_token = AuthService.create_refresh_token(str(user.id))
    
    expires_in = int((expires_at - datetime.utcnow()).total_seconds())
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=expires_in,
        user=_to_user_response(user, auth_method=AuthMethodEnum.GOOGLE)
    )


# ==================== PROFILE ENDPOINTS ====================

@router.get("/profile", response_model=UserResponse)
async def get_profile(current_user: User = Depends(get_current_user)):
    """Get current user profile"""
    return _to_user_response(current_user)


@router.post("/change-password")
async def change_password(
    request: ChangePasswordRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Change user password"""
    success, message = AuthService.change_password(
        db=db,
        user_id=current_user.id,
        old_password=request.old_password,
        new_password=request.new_password
    )
    
    if not success:
        raise HTTPException(status_code=400, detail=message)
    
    return {"success": True, "message": message}


# ==================== PASSWORD RESET ENDPOINTS ====================

@router.post("/forgot-password")
async def forgot_password(request: ResetPasswordRequest, db: Session = Depends(get_db)):
    """Request password reset"""
    success, message, token = AuthService.request_password_reset(
        db=db,
        email=request.email
    )
    
    return {"success": True, "message": message}


@router.post("/reset-password")
async def reset_password(request: ResetPasswordConfirmRequest, db: Session = Depends(get_db)):
    """Reset password with token"""
    success, message = AuthService.reset_password(
        db=db,
        token=request.token,
        new_password=request.new_password
    )
    
    if not success:
        raise HTTPException(status_code=400, detail=message)
    
    return {"success": True, "message": message}


# ==================== HEALTH CHECK ====================

@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}

