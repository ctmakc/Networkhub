import uuid
from typing import Sequence

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.event import Event
from app.repositories.base import BaseRepository


class EventRepository(BaseRepository[Event]):
    model = Event

    def __init__(self, db: AsyncSession) -> None:
        super().__init__(db)

    async def list_for_user(self, user_id: uuid.UUID) -> Sequence[Event]:
        result = await self.db.execute(
            select(Event)
            .where(Event.user_id == user_id)
            .order_by(Event.event_date.desc())
        )
        return result.scalars().all()
