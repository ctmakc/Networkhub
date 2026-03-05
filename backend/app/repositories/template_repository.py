import uuid
from typing import Optional, Sequence

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.template import Template
from app.repositories.base import BaseRepository


class TemplateRepository(BaseRepository[Template]):
    model = Template

    def __init__(self, db: AsyncSession) -> None:
        super().__init__(db)

    async def list_for_user(self, user_id: uuid.UUID) -> Sequence[Template]:
        result = await self.db.execute(
            select(Template)
            .where(Template.user_id == user_id)
            .order_by(Template.is_default.desc(), Template.name)
        )
        return result.scalars().all()

    async def get_default_for_user(self, user_id: uuid.UUID) -> Optional[Template]:
        result = await self.db.execute(
            select(Template)
            .where(Template.user_id == user_id)
            .where(Template.is_default.is_(True))
            .limit(1)
        )
        return result.scalar_one_or_none()

    async def clear_default_for_user(self, user_id: uuid.UUID) -> None:
        """Remove the is_default flag from all templates belonging to user."""
        await self.db.execute(
            update(Template)
            .where(Template.user_id == user_id)
            .values(is_default=False)
        )
        await self.db.flush()
