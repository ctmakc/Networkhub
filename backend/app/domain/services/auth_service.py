import secrets
import uuid
from datetime import datetime, timedelta, timezone
from typing import Any, Optional

import redis.asyncio as aioredis
from jose import jwt

from app.config import settings
from app.models.user import User
from app.repositories.user_repository import UserRepository

MAGIC_LINK_PREFIX = "magic_link:"


def _get_redis() -> aioredis.Redis:
    return aioredis.from_url(settings.REDIS_URL, decode_responses=True)


class AuthService:
    def __init__(self, user_repo: UserRepository) -> None:
        self.user_repo = user_repo

    async def create_magic_link(self, email: str) -> str:
        """
        Ensure the user exists, generate a secure token, store it in Redis
        with a TTL, and (in production) send it via email.

        Returns the raw token so callers (e.g. tests) can verify it directly.
        """
        user, _ = await self.user_repo.get_or_create(email)

        token = secrets.token_urlsafe(32)
        redis = _get_redis()
        try:
            key = f"{MAGIC_LINK_PREFIX}{token}"
            ttl_seconds = settings.MAGIC_LINK_EXPIRE_MINUTES * 60
            await redis.setex(key, ttl_seconds, str(user.id))
        finally:
            await redis.aclose()

        # In a real deployment this would trigger an email via SendGrid/Celery.
        # The email-sending side is handled by the email provider layer so that
        # this service stays infrastructure-agnostic.
        return token

    async def verify_magic_link(self, token: str) -> Optional[User]:
        """
        Validate the one-time token from Redis.
        On success marks the user as verified and deletes the token.
        Returns None if the token is invalid or expired.
        """
        redis = _get_redis()
        try:
            key = f"{MAGIC_LINK_PREFIX}{token}"
            user_id_str: Optional[str] = await redis.get(key)
            if user_id_str is None:
                return None

            user_id = uuid.UUID(user_id_str)
            user = await self.user_repo.get(user_id)
            if user is None:
                return None

            # Consume the token (one-time use)
            await redis.delete(key)

            # Mark user as verified on first successful magic-link login
            if not user.is_verified:
                user = await self.user_repo.mark_verified(user)

            return user
        except Exception:
            return None
        finally:
            await redis.aclose()

    def create_access_token(self, user: User) -> dict[str, Any]:
        """Create a signed JWT access token for the given user."""
        expire = datetime.now(tz=timezone.utc) + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )
        payload = {
            "sub": str(user.id),
            "email": user.email,
            "exp": expire,
            "iat": datetime.now(tz=timezone.utc),
        }
        token = jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
        return {
            "access_token": token,
            "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        }
