#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Thingual Backend Server - Startup Script using Hypercorn
Uses Hypercorn instead of uvicorn to avoid Windows event loop issues

Usage:
    python start_hypercorn.py
"""
import os
import sys
import asyncio
import platform
from pathlib import Path

# Set UTF-8 encoding for Windows
if sys.platform == "win32":
    os.environ["PYTHONIOENCODING"] = "utf-8"

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

# Set event loop policy for Windows
if platform.system() == "Windows":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())


async def main():
    """Start the server using Hypercorn"""
    try:
        from hypercorn.asyncio import serve
        from hypercorn.config import Config
        from app.config import get_settings

        settings = get_settings()
        
        print("=" * 80)
        print("Thingual Backend API Server")
        print("=" * 80)
        print(f"Server: Hypercorn (Windows optimized)")
        print(f"Host: {settings.api_host}")
        print(f"Port: {settings.api_port}")
        print(f"Debug: {settings.debug}")
        print(f"Python: {sys.version.split()[0]}")
        print(f"Platform: {platform.system()}")
        print("=" * 80)
        print()
        print("API Documentation: http://localhost:8002/docs")
        print("ReDoc Documentation: http://localhost:8002/redoc")
        print()
        print("Press Ctrl+C to stop the server")
        print("=" * 80)
        print()
        
        # Configure Hypercorn
        config = Config()
        config.bind = [f"{settings.api_host}:{settings.api_port}"]
        config.workers = 1  # Single worker for Windows
        config.accesslog = "-"  # Log to stdout
        config.errorlog = "-"  # Log errors to stdout
        config.loglevel = "info"
        config.use_reloader = settings.debug
        config.keep_alive = 5
        
        # Import app
        from app.main import app
        
        print("Server is listening for connections...")
        print()
        
        # Run server
        try:
            await serve(app, config)
        except Exception as e:
            print(f"Server error: {e}")
            raise
        
    except KeyboardInterrupt:
        print("\n\nServer stopped by user")
        sys.exit(0)
    except Exception as e:
        print(f"\nError: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())
