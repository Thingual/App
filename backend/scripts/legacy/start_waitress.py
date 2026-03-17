#!/usr/bin/env python
"""Legacy Waitress runner (kept for reference)."""

from __future__ import annotations

import os
import sys
from pathlib import Path

os.environ["PYTHONIOENCODING"] = "utf-8"

BACKEND_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(BACKEND_ROOT))


def main() -> None:
    from waitress import serve
    from app.main import app

    print("Starting Thingual backend on http://0.0.0.0:8002...")
    serve(app, host="0.0.0.0", port=8002, threads=4)


if __name__ == "__main__":
    main()
