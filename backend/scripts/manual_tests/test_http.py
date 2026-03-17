#!/usr/bin/env python3
"""Manual in-process test with FastAPI TestClient."""

from __future__ import annotations

import os
import sys
from pathlib import Path

BACKEND_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(BACKEND_ROOT))


def main() -> int:
    from app.main import app
    from fastapi.testclient import TestClient

    client = TestClient(app)
    response = client.post(
        "/auth/email/signup",
        json={
            "email": f"newuser_{os.urandom(4).hex()}@example.com",
            "password": "testpass123",
        },
    )
    print("Status:", response.status_code)
    print("Body:", response.text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
