"""
Thingual API - Authentication Backend
FastAPI with Hypercorn ASGI server for Windows compatibility

Runs without uvicorn to avoid Windows event loop issues.
Hypercorn handles async operations better on Windows.
"""
import asyncio
import sys
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

# Set UTF-8 encoding for Windows
if sys.platform == "win32":
    os.environ["PYTHONIOENCODING"] = "utf-8"

from .routers import auth_router
from .database import init_db
from .config import get_settings

settings = get_settings()


# Lifespan context manager for startup/shutdown
@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Startup and shutdown events
    """
    # Startup
    print("Initializing database...")
    try:
        init_db()
        print("Database initialized successfully")
    except Exception as e:
        print(f"Database initialization failed: {e}")
        raise
    
    yield
    
    # Shutdown
    print("Shutting down application...")


# Create FastAPI application with lifespan
app = FastAPI(
    title="Thingual API",
    description="Authentication API for Thingual application",
    version="2.0.0",
    lifespan=lifespan,
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.frontend_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router)


@app.get("/")
async def root():
    """Root endpoint - API health check."""
    return {
        "message": "Thingual API is running",
        "status": "healthy",
        "version": "2.0.0"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "database": "connected"
    }


@app.get("/api/info")
async def api_info():
    """API information endpoint."""
    return {
        "name": "Thingual Authentication API",
        "version": "2.0.0",
        "description": "Multi-method authentication (email, phone, Google OAuth)",
        "endpoints": {
            "email": "/auth/email/signup, /auth/email/login",
            "phone": "/auth/phone/request-otp, /auth/phone/verify-otp",
            "google": "/auth/google/signup, /auth/google/login",
            "profile": "/auth/profile",
            "security": "/auth/change-password, /auth/forgot-password, /auth/reset-password"
        }
    }

