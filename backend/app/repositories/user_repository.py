from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User
from app.repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    model = User

    def __init__(self, db: AsyncSession) -> None:
        super().__init__(db)

    async def get_by_email(self, email: str) -> Optional[User]:
        """Fetch a user by their email address."""
        result = await self.db.execute(
            select(User).where(User.email == email.lower().strip())
        )
        return result.scalar_one_or_none()

    async def get_or_create(self, email: str, full_name: Optional[str] = None) -> tuple[User, bool]:
        """
        Return (user, created) where `created` is True if a new record was inserted.
        """
        normalized = email.lower().strip()
        user = await self.get_by_email(normalized)
        if user is not None:
            return user, False

        new_user = User(email=normalized, full_name=full_name, is_verified=False)
        user = await self.create(new_user)
        return user, True

    async def mark_verified(self, user: User) -> User:
        """Mark a user as email-verified."""
        return await self.update(user, is_verified=True)
