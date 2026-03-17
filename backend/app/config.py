from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field
from functools import lru_cache
from pathlib import Path


class Settings(BaseSettings):
    # Database - NeonDB cloud hosted PostgreSQL
    database_url: str = Field(
        # NOTE: Do not hard-code real cloud credentials in source control.
        # Provide your actual Neon/Postgres URL via environment variables or `backend/.env`.
        default="postgresql://postgres:password@localhost:5432/thingual",
        alias="DATABASE_URL",
    )
    
    # JWT Configuration
    secret_key: str = Field(
        default="your-super-secret-key-change-this-in-production",
        alias="SECRET_KEY",
    )
    algorithm: str = Field(default="HS256", alias="ALGORITHM")
    access_token_expire_minutes: int = Field(default=30, alias="ACCESS_TOKEN_EXPIRE_MINUTES")
    refresh_token_expire_days: int = Field(default=7, alias="REFRESH_TOKEN_EXPIRE_DAYS")
    
    # Google OAuth Configuration
    google_client_id: str = Field(default="", alias="GOOGLE_CLIENT_ID")
    google_client_secret: str = Field(default="", alias="GOOGLE_CLIENT_SECRET")
    
    # Email Configuration (for verification, optional)
    smtp_server: str = Field(default="smtp.gmail.com", alias="SMTP_SERVER")
    smtp_port: int = Field(default=587, alias="SMTP_PORT")
    smtp_user: str = Field(default="", alias="SMTP_USER")
    smtp_password: str = Field(default="", alias="SMTP_PASSWORD")
    
    # Backend settings
    api_host: str = Field(default="0.0.0.0", alias="API_HOST")
    api_port: int = Field(default=8002, alias="API_PORT")
    debug: bool = Field(default=False, alias="DEBUG")
    
    # Frontend origin for CORS
    frontend_origins: list = [
        "http://localhost:3000",
        "http://localhost:3001",
        "http://localhost:8000",
    ]
    
    model_config = SettingsConfigDict(
        env_file=Path(__file__).parent.parent / ".env",
        case_sensitive=False,
        extra="ignore",
        populate_by_name=True,
    )


@lru_cache()
def get_settings() -> Settings:
    return Settings()
