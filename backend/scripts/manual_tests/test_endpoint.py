#!/usr/bin/env python3
"""Manual API test: call email signup endpoint."""

from __future__ import annotations

import os
import time

import requests


def main() -> int:
    print("Waiting for server...")
    time.sleep(1)

    response = requests.post(
        "http://localhost:8002/auth/email/signup",
        json={
            "email": f"manual_test_{os.urandom(4).hex()}@example.com",
            "password": "testpass123",
            "first_name": "Manual",
            "last_name": "Test",
        },
        timeout=10,
    )
    print(f"Status: {response.status_code}")
    print(f"Text: {response.text}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
