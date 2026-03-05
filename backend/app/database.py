from collections.abc import AsyncGenerator
from typing import Any

from sqlalchemy import event, text
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase, MappedColumn
from sqlalchemy.pool import NullPool

from app.config import settings


class Base(DeclarativeBase):
    """Declarative base for all ORM models."""

    pass


def _create_engine(database_url: str, **kwargs: Any) -> AsyncEngine:
    """Create async SQLAlchemy engine."""
    connect_args: dict[str, Any] = {}

    # asyncpg-specific options
    if "asyncpg" in database_url:
        connect_args["server_settings"] = {"jit": "off"}

    return create_async_engine(
        database_url,
        echo=settings.ENVIRONMENT == "development",
        pool_pre_ping=True,
        connect_args=connect_args,
        **kwargs,
    )


# Main application engine
engine: AsyncEngine = _create_engine(settings.DATABASE_URL)

# Session factory
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """FastAPI dependency that yields an async database session."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def check_db_connection() -> bool:
    """Health-check: verify the database is reachable."""
    try:
        async with AsyncSessionLocal() as session:
            await session.execute(text("SELECT 1"))
        return True
    except Exception:
        return False
