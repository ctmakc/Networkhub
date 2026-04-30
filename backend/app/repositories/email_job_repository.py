import uuid
from datetime import date, datetime, timezone
from typing import Optional, Sequence

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.email_job import EmailJob, EmailJobStatus
from app.repositories.base import BaseRepository


class EmailJobRepository(BaseRepository[EmailJob]):
    model = EmailJob

    def __init__(self, db: AsyncSession) -> None:
        super().__init__(db)

    async def get_by_idempotency_key(self, key: str) -> Optional[EmailJob]:
        result = await self.db.execute(
            select(EmailJob).where(EmailJob.idempotency_key == key)
        )
        return result.scalar_one_or_none()

    async def count_sent_today(self, user_id: uuid.UUID) -> int:
        """Count emails successfully sent or queued today for the given user."""
        today_start = datetime.combine(date.today(), datetime.min.time()).replace(
            tzinfo=timezone.utc
        )
        result = await self.db.execute(
            select(func.count())
            .select_from(EmailJob)
            .where(EmailJob.user_id == user_id)
            .where(EmailJob.status.in_([EmailJobStatus.queued, EmailJobStatus.sent]))
            .where(EmailJob.created_at >= today_start)
        )
        return result.scalar_one()

    async def list_for_user(self, user_id: uuid.UUID, *, limit: int = 50) -> Sequence[EmailJob]:
        result = await self.db.execute(
            select(EmailJob)
            .where(EmailJob.user_id == user_id)
            .order_by(EmailJob.created_at.desc())
            .limit(limit)
        )
        return result.scalars().all()
