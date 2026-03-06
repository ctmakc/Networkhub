"""Pytest fixtures for backend tests."""

import uuid
from typing import AsyncGenerator

import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.pool import NullPool

from app.config import settings
from app.database import Base, get_db
from app.main import app

TEST_DATABASE_URL = settings.DATABASE_URL


@pytest_asyncio.fixture(scope="function")
async def engine():
    """Create test database engine and set up schema."""
    eng = create_async_engine(TEST_DATABASE_URL, echo=False, poolclass=NullPool)
    async with eng.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield eng
    async with eng.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await eng.dispose()


@pytest_asyncio.fixture
async def db_session(engine) -> AsyncGenerator[AsyncSession, None]:
    """Provide a test database session that rolls back after each test."""
    async with AsyncSession(engine, expire_on_commit=False) as session:
        await session.begin()
        yield session
        await session.rollback()


@pytest_asyncio.fixture
async def client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    """Provide an HTTPX test client with the database overridden."""

    async def override_get_db() -> AsyncGenerator[AsyncSession, None]:
        yield db_session

    app.dependency_overrides[get_db] = override_get_db

    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://testserver",
    ) as ac:
        yield ac

    app.dependency_overrides.clear()


@pytest_asyncio.fixture
async def test_user(db_session: AsyncSession):
    """Create and persist a test user."""
    from app.models.user import User

    user = User(
        id=uuid.uuid4(),
        email="test@example.com",
        full_name="Test User",
        is_active=True,
        is_verified=True,
    )
    db_session.add(user)
    await db_session.flush()
    await db_session.refresh(user)
    return user


@pytest_asyncio.fixture
async def auth_headers(test_user):
    """Return Bearer auth headers for the test user."""
    from app.domain.services.auth_service import AuthService

    class _MinimalRepo:
        pass

    service = AuthService(user_repo=_MinimalRepo())  # type: ignore[arg-type]
    token_data = service.create_access_token(test_user)
    return {"Authorization": f"Bearer {token_data['access_token']}"}
