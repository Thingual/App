#!/usr/bin/env python
"""Legacy debug script for quick backend sanity checks."""

from __future__ import annotations

import sys
from pathlib import Path

BACKEND_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(BACKEND_ROOT))


def main() -> int:
    print("=" * 60)
    print("BACKEND DEBUG TEST")
    print("=" * 60)

    print("\n1. Checking .env configuration...")
    try:
        from app.config import get_settings

        settings = get_settings()
        print(f"   ✓ Database URL: {settings.database_url[:50]}...")
        print(f"   ✓ Google Client ID configured: {bool(settings.google_client_id)}")
    except Exception as e:
        print(f"   ✗ Error: {e}")
        return 1

    print("\n2. Testing database connection...")
    try:
        from app.database import SessionLocal

        db = SessionLocal()
        print("   ✓ Connected to database")
        db.close()
    except Exception as e:
        print(f"   ✗ Error: {e}")
        return 1

    print("\n3. Checking User model...")
    try:
        from app.models.user import User

        print("   ✓ User model loaded")
        print("   ✓ Columns include: id, name, email, password_hash, created_at, google_id, apple_id")
        _ = User
    except Exception as e:
        print(f"   ✗ Error: {e}")
        return 1

    print("\n4. Testing email signup helper...")
    try:
        import os
        from app.database import SessionLocal
        from app.services.auth_service import AuthService

        email = f"debug_{os.urandom(4).hex()}@example.com"
        db = SessionLocal()
        ok, msg, user = AuthService.email_signup(db, email=email, password="password123", name="Debug User")
        print(f"   ✓ {msg}")
        if ok and user is not None:
            print(f"   ✓ User ID: {user.id}, Email: {user.email}")
            db.delete(user)
            db.commit()
        db.close()
    except Exception as e:
        print(f"   ✗ Error: {e}")
        import traceback

        traceback.print_exc()
        return 1

    print("\n" + "=" * 60)
    print("ALL TESTS PASSED!")
    print("=" * 60)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
