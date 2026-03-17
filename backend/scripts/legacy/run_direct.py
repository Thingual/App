#!/usr/bin/env python
"""Legacy direct server test (kept for reference)."""

from __future__ import annotations

import os
import sys
from pathlib import Path

os.environ["PYTHONIOENCODING"] = "utf-8"

BACKEND_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(BACKEND_ROOT))


def main() -> int:
    try:
        print("Loading app...")
        from app.main import app

        print("[OK] App loaded")
        print("Starting uvicorn on :9000...")
        import uvicorn

        uvicorn.run(app, host="0.0.0.0", port=9000, log_level="debug", loop="auto", use_colors=True)
        return 0
    except Exception as e:
        print(f"[ERROR] {e}")
        import traceback

        traceback.print_exc()
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
