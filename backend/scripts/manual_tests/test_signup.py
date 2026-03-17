#!/usr/bin/env python3
"""Manual API test: email signup via requests."""

from __future__ import annotations

import json
import os

import requests


def main() -> int:
    url = "http://localhost:8002/auth/email/signup"
    data = {
        "email": f"test_{os.urandom(4).hex()}@example.com",
        "password": "password123",
    }

    response = requests.post(url, json=data, timeout=10)
    print(f"Status: {response.status_code}")
    try:
        print(json.dumps(response.json(), indent=2))
    except Exception:
        print(response.text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
