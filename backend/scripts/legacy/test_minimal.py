#!/usr/bin/env python
"""Legacy minimal repro of uvicorn/engine behavior (kept for reference)."""

from __future__ import annotations

import asyncio
import sys
from pathlib import Path

BACKEND_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(BACKEND_ROOT))

print("1. Test engine creation...")
from app.config import get_settings

settings = get_settings()
print(f"   Database URL: {settings.database_url[:50]}...")

print("2. Import engine...")
from sqlalchemy import create_engine

engine = create_engine(settings.database_url, echo=False, pool_pre_ping=True, pool_size=10, max_overflow=20)
print("   Engine created OK")

print("3. Create SessionLocal...")
from sqlalchemy.orm import sessionmaker

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
print("   SessionLocal created OK")

print("4. Test session creation...")
session = SessionLocal()
print("   Session created OK")
session.close()

print("5. Run app with uvicorn...")
if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

try:
    import uvicorn  # type: ignore[import-not-found]
except Exception as e:
    print(f"uvicorn is not installed in this environment: {e}")
    print("Install it if you want to run this script: pip install uvicorn")
    raise SystemExit(1)

from app.main import app

uvicorn.run(app, host="0.0.0.0", port=9001, log_level="info")
