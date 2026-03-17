#!/usr/bin/env python3
"""Manual API test with httpx."""

from __future__ import annotations

import asyncio
import os

import httpx


async def test() -> None:
    async with httpx.AsyncClient() as client:
        response = await client.post(
            "http://localhost:8002/auth/email/signup",
            json={
                "email": f"httpx_{os.urandom(4).hex()}@example.com",
                "password": "testpass123",
            },
            timeout=10,
        )
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")


if __name__ == "__main__":
    asyncio.run(test())
