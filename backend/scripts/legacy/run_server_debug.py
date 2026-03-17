"""Legacy helper to run uvicorn directly (not recommended on Windows).

Kept for reference; prefer `backend/start_hypercorn.py`.
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


def main() -> int:
    backend_root = Path(__file__).resolve().parents[2]
    os.chdir(str(backend_root))

    python_exe = str(backend_root / "venv" / "Scripts" / "python.exe")
    if not Path(python_exe).exists():
        print("backend/venv not found; run start_server.ps1 once to create it")
        return 1

    result = subprocess.run(
        [python_exe, "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8003"],
        capture_output=False,
        text=True,
    )
    return int(result.returncode)


if __name__ == "__main__":
    raise SystemExit(main())
