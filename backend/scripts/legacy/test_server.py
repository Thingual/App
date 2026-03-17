#!/usr/bin/env python
"""Legacy direct test of importing and running the app."""

from __future__ import annotations

import asyncio
import sys
from pathlib import Path

BACKEND_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(BACKEND_ROOT))

if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

if __name__ == "__main__":
    print("Importing app...")
    from app.main import app

    print("App imported successfully")
    print("Starting with uvicorn on port 8002...")
    import uvicorn  # type: ignore[import-not-found]

    uvicorn.run(app, host="0.0.0.0", port=8002, log_level="info")
