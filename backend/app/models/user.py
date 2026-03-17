"""User ORM model.

IMPORTANT: This model must match the existing NeonDB `users` table schema.
Current NeonDB schema columns (reflected):
id, name, email, password_hash, created_at, google_id, apple_id.
"""

from sqlalchemy import Column, DateTime, Index, Integer, String, text
from sqlalchemy.sql import func

from ..database import Base


class User(Base):
    __tablename__ = "users"

    # NeonDB schema uses an integer primary key
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=True)
    email = Column(String(255), unique=True, nullable=True, index=True)
    password_hash = Column(String(255), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=True)

    # OAuth provider subject identifiers (nullable, but must be unique when present)
    google_id = Column(String(255), nullable=True)
    apple_id = Column(String(255), nullable=True)

    __table_args__ = (
        # Match existing NeonDB index names to avoid duplicate indexes.
        Index("ix_users_email", "email", unique=True),
        Index("ix_users_id", "id"),
        Index("ix_users_name", "name"),
        Index("ux_users_google_id", "google_id", unique=True, postgresql_where=text("google_id IS NOT NULL")),
        Index("ux_users_apple_id", "apple_id", unique=True, postgresql_where=text("apple_id IS NOT NULL")),
    )

    def __repr__(self):
        return f"<User(id={self.id}, email={self.email})>"
