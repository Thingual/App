"""
Database connection and session management using SQLAlchemy ORM
Optimized for Windows and NeonDB cloud PostgreSQL
"""
from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.pool import NullPool
from .config import get_settings

settings = get_settings()

# Create engine with connection pooling optimized for Windows and NeonDB
# NullPool avoids connection pool issues on Windows with async operations
engine = create_engine(
    settings.database_url,
    echo=settings.debug,
    poolclass=NullPool,  # Critical for avoiding Windows event loop issues
    connect_args={
        "connect_timeout": 10,
        "keepalives": 1,
        "keepalives_idle": 30,
    },
)

# Create session factory
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    expire_on_commit=False
)

# Base class for all models
Base = declarative_base()


def get_db():
    """
    Dependency injection for database sessions.
    Usage: db: Session = Depends(get_db)
    """
    db = SessionLocal()
    try:
        yield db
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def init_db():
    """Initialize database - create all tables"""
    try:
        Base.metadata.create_all(bind=engine)
    except Exception as e:
        print(f"Error initializing database: {e}")
        raise
