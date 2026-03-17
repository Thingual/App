"""
Authentication service handling all auth logic
Supports email, phone, and Google OAuth
"""
import random
import bcrypt
from datetime import datetime, timedelta
from typing import Optional, Tuple, Dict, Any
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from ..config import get_settings
from ..models.user import User


settings = get_settings()


class AuthService:
    """Authentication service for user signup, login, and token management"""

    @staticmethod
    def hash_password(password: str) -> str:
        """Hash password using bcrypt"""
        salt = bcrypt.gensalt(rounds=12)
        return bcrypt.hashpw(password.encode(), salt).decode()

    @staticmethod
    def verify_password(password: str, password_hash: str) -> bool:
        """Verify password against hash"""
        try:
            return bcrypt.checkpw(password.encode(), password_hash.encode())
        except Exception:
            return False

    @staticmethod
    def generate_otp(length: int = 6) -> str:
        """Generate random OTP"""
        return str(random.randint(10**(length-1), 10**length - 1))

    @staticmethod
    def create_access_token(user_id: str, expires_delta: Optional[timedelta] = None) -> Tuple[str, datetime]:
        """Create JWT access token"""
        if expires_delta is None:
            expires_delta = timedelta(minutes=settings.access_token_expire_minutes)

        expire = datetime.utcnow() + expires_delta
        to_encode = {"sub": user_id, "exp": expire}
        encoded_jwt = jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)
        return encoded_jwt, expire

    @staticmethod
    def create_refresh_token(user_id: str) -> str:
        """Create JWT refresh token"""
        expires_delta = timedelta(days=settings.refresh_token_expire_days)
        expire = datetime.utcnow() + expires_delta
        to_encode = {"sub": user_id, "type": "refresh", "exp": expire}
        return jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)

    @staticmethod
    def verify_token(token: str) -> Optional[str]:
        """Verify and decode JWT token, returns user_id if valid"""
        try:
            payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
            user_id: str = payload.get("sub")
            if user_id is None:
                return None
            return user_id
        except JWTError:
            return None

    # ==================== Email Authentication ====================

    @staticmethod
    def email_signup(db: Session, email: str, password: str, name: Optional[str] = None) -> Tuple[bool, str, Optional[User]]:
        """
        Create new user with email and password
        Returns: (success, message, user)
        """
        # Check if email already exists
        existing_user = db.query(User).filter(User.email == email).first()
        if existing_user:
            return False, "Email already registered", None

        # Create new user
        try:
            user = User(
                email=email,
                password_hash=AuthService.hash_password(password),
                name=name,
            )
            db.add(user)
            db.commit()
            db.refresh(user)
            return True, "User registered successfully", user
        except Exception as e:
            db.rollback()
            return False, f"Registration failed: {str(e)}", None

    @staticmethod
    def email_login(db: Session, email: str, password: str) -> Tuple[bool, str, Optional[User]]:
        """
        Login with email and password
        Returns: (success, message, user)
        """
        user = db.query(User).filter(User.email == email).first()

        if not user:
            return False, "Email not found", None

        if not user.password_hash or not AuthService.verify_password(password, user.password_hash):
            return False, "Invalid password", None
        return True, "Login successful", user

    # ==================== Phone Authentication ====================

    @staticmethod
    def send_phone_otp(db: Session, phone: str, country_code: str) -> Tuple[bool, str, Optional[str]]:
        """
        Send OTP to phone number
        Returns: (success, message, otp)
        """
        return False, "Phone OTP auth is not supported by the current NeonDB users schema", None

    @staticmethod
    def verify_phone_otp(db: Session, phone: str, otp: str) -> Tuple[bool, str, Optional[User]]:
        """
        Verify phone OTP and register/login user
        Returns: (success, message, user)
        """
        return False, "Phone OTP auth is not supported by the current NeonDB users schema", None

    # ==================== Google OAuth ====================

    @staticmethod
    def _get_allowed_google_client_ids() -> list[str]:
        raw = (settings.google_client_id or "").strip()
        if not raw:
            return []
        return [cid.strip() for cid in raw.split(",") if cid.strip()]

    @staticmethod
    def _verify_google_id_token(id_token_str: str) -> Dict[str, Any]:
        """Verify a Google ID token and return its decoded claims.

        Requires GOOGLE_CLIENT_ID to be configured.
        """
        if not id_token_str:
            raise ValueError("Missing Google ID token")

        client_ids = AuthService._get_allowed_google_client_ids()
        if not client_ids:
            raise ValueError("Google sign-in is not configured (GOOGLE_CLIENT_ID is empty)")

        from google.oauth2 import id_token as google_id_token
        from google.auth.transport import requests as google_requests

        request = google_requests.Request()
        # Allow a small leeway for local clock skew (common on dev machines).
        clock_skew_in_seconds = 60
        last_error: Optional[Exception] = None

        for audience in client_ids:
            try:
                payload = google_id_token.verify_oauth2_token(
                    id_token_str,
                    request,
                    audience=audience,
                    clock_skew_in_seconds=clock_skew_in_seconds,
                )
                iss = payload.get("iss")
                if iss not in ("accounts.google.com", "https://accounts.google.com"):
                    raise ValueError("Invalid Google token issuer")
                return payload
            except Exception as e:
                last_error = e

        raise ValueError(f"Invalid Google ID token: {last_error}")

    @staticmethod
    def google_signup_login(
        db: Session,
        google_id_token_str: str,
        first_name: Optional[str] = None,
        last_name: Optional[str] = None,
    ) -> Tuple[bool, str, Optional[User]]:
        """Signup or login with Google OAuth.

        Verifies the provided Google ID token, then upserts/links a user:
        - Prefer matching by `google_id`.
        - If not found and email is present, link to existing account by email.
        - Otherwise create a new user with `google_id`.
        """
        try:
            payload = AuthService._verify_google_id_token(google_id_token_str)
        except Exception as e:
            return False, str(e), None

        google_sub = payload.get("sub")
        if not google_sub:
            return False, "Google token is missing subject (sub)", None

        email = payload.get("email")
        full_name = payload.get("name")
        if not full_name:
            given_name = payload.get("given_name") or first_name
            family_name = payload.get("family_name") or last_name
            parts = [p for p in [given_name, family_name] if p]
            full_name = " ".join(parts) if parts else None

        # 1) Login by google_id
        user = db.query(User).filter(User.google_id == google_sub).first()
        if user:
            # Lightly hydrate missing fields; avoid overwriting populated data.
            if email and not user.email:
                user.email = email
            if full_name and not user.name:
                user.name = full_name
            try:
                db.commit()
                db.refresh(user)
            except Exception:
                db.rollback()
            return True, "Google login successful", user

        # 2) Link to an existing account by email (if present)
        if email:
            user = db.query(User).filter(User.email == email).first()
            if user:
                if user.google_id and user.google_id != google_sub:
                    return False, "This email is already linked to a different Google account", None
                user.google_id = google_sub
                if full_name and not user.name:
                    user.name = full_name
                try:
                    db.commit()
                    db.refresh(user)
                    return True, "Google account linked", user
                except IntegrityError as e:
                    db.rollback()
                    return False, f"Unable to link Google account: {str(e)}", None
                except Exception as e:
                    db.rollback()
                    return False, f"Google auth failed: {str(e)}", None

        # 3) Create a new user
        try:
            user = User(
                google_id=google_sub,
                email=email,
                name=full_name,
                password_hash=None,
            )
            db.add(user)
            db.commit()
            db.refresh(user)
            return True, "Google signup successful", user
        except IntegrityError as e:
            db.rollback()
            return False, f"Google signup failed: {str(e)}", None
        except Exception as e:
            db.rollback()
            return False, f"Google signup failed: {str(e)}", None

    # ==================== Password Management ====================

    @staticmethod
    def change_password(db: Session, user_id: str, old_password: str, new_password: str) -> Tuple[bool, str]:
        """Change user password"""
        user = db.query(User).filter(User.id == user_id).first()

        if not user:
            return False, "User not found"

        if not user.password_hash or not AuthService.verify_password(old_password, user.password_hash):
            return False, "Current password is incorrect"

        user.password_hash = AuthService.hash_password(new_password)

        try:
            db.commit()
            return True, "Password changed successfully"
        except Exception as e:
            db.rollback()
            return False, f"Password change failed: {str(e)}"

    @staticmethod
    def request_password_reset(db: Session, email: str) -> Tuple[bool, str, Optional[str]]:
        """Request password reset.

        Not supported because the current NeonDB users schema does not have
        columns to store reset tokens.
        """
        return False, "Password reset is not supported by the current NeonDB users schema", None

    @staticmethod
    def reset_password(db: Session, token: str, new_password: str) -> Tuple[bool, str]:
        """Reset password with token.

        Not supported because the current NeonDB users schema does not have
        columns to store reset tokens.
        """
        return False, "Password reset is not supported by the current NeonDB users schema"

    # ==================== User Retrieval ====================

    @staticmethod
    def get_user_by_id(db: Session, user_id: str) -> Optional[User]:
        """Get user by ID"""
        try:
            user_id_int = int(user_id)
        except (TypeError, ValueError):
            return None
        return db.query(User).filter(User.id == user_id_int).first()

    @staticmethod
    def get_user_by_email(db: Session, email: str) -> Optional[User]:
        """Get user by email"""
        return db.query(User).filter(User.email == email).first()

    @staticmethod
    def get_user_by_phone(db: Session, phone: str) -> Optional[User]:
        """Get user by phone"""
        return None

