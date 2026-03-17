#!/usr/bin/env python
"""Legacy server runner (kept for reference).

Prefer `backend/start_hypercorn.py`.
"""

from __future__ import annotations

import sys
from pathlib import Path

BACKEND_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(BACKEND_ROOT))


def main() -> None:
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8002,
        log_level="error",
        access_log=False,
        workers=1,
    )


if __name__ == "__main__":
    main()
