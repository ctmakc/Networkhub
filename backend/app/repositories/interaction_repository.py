import uuid
from typing import Sequence

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.interaction import Interaction, InteractionType
from app.repositories.base import BaseRepository


class InteractionRepository(BaseRepository[Interaction]):
    model = Interaction

    def __init__(self, db: AsyncSession) -> None:
        super().__init__(db)

    async def list_for_contact(
        self,
        user_id: uuid.UUID,
        contact_id: uuid.UUID,
        *,
        limit: int = 50,
    ) -> Sequence[Interaction]:
        result = await self.db.execute(
            select(Interaction)
            .where(Interaction.user_id == user_id)
            .where(Interaction.contact_id == contact_id)
            .order_by(Interaction.created_at.desc())
            .limit(limit)
        )
        return result.scalars().all()

    async def log(
        self,
        user_id: uuid.UUID,
        contact_id: uuid.UUID,
        interaction_type: InteractionType,
        payload: dict | None = None,
        event_id: uuid.UUID | None = None,
    ) -> Interaction:
        """Create and persist a new interaction record."""
        interaction = Interaction(
            user_id=user_id,
            contact_id=contact_id,
            event_id=event_id,
            type=interaction_type,
            payload=payload or {},
        )
        return await self.create(interaction)
