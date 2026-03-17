#!/usr/bin/env python
"""Legacy runner that forces uvicorn sync mode (kept for reference)."""

from __future__ import annotations

import asyncio
import os
import sys
from pathlib import Path

os.environ["PYTHONIOENCODING"] = "utf-8"
os.environ["UVICORN_LOOP"] = "none"

if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

BACKEND_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(BACKEND_ROOT))


def main() -> None:
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8003,
        log_level="info",
        reload=False,
        factory=False,
        lifespan="off",
    )


if __name__ == "__main__":
    main()
