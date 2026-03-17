#!/usr/bin/env python
"""Manual DB test: create an email user and delete it."""

from __future__ import annotations

import os
import sys
from pathlib import Path

BACKEND_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(BACKEND_ROOT))

from app.database import SessionLocal
from app.services.auth_service import AuthService


def main() -> int:
    email = f"test_{os.urandom(4).hex()}@example.com"
    print("Creating test user...", email)
    db = SessionLocal()
    try:
        ok, msg, user = AuthService.email_signup(db, email=email, password="password123", name="Test User")
        print("Result:", ok, msg)
        if not ok or user is None:
            return 1
        print(f"✓ User created: id={user.id} email={user.email}")
        db.delete(user)
        db.commit()
        return 0
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
