import uuid
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.consent import Consent, ConsentStatus, ConsentType
from app.repositories.base import BaseRepository


class ConsentRepository(BaseRepository[Consent]):
    model = Consent


class ConsentService:
    def __init__(self, db: AsyncSession) -> None:
        self.repo = ConsentRepository(db)
        self.db = db

    async def record_consent(
        self,
        user_id: uuid.UUID,
        consent_type: ConsentType,
        status: ConsentStatus = ConsentStatus.granted,
        version: str = "1.0",
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Consent:
        """
        Record a consent event for a user.
        Creates a new Consent row every time (immutable audit log approach).
        """
        consent = Consent(
            user_id=user_id,
            type=consent_type,
            status=status,
            version=version,
            ip_address=ip_address,
            user_agent=user_agent,
        )
        return await self.repo.create(consent)

    async def check_consent(
        self,
        user_id: uuid.UUID,
        consent_type: ConsentType,
    ) -> bool:
        """
        Return True if the user's most recent consent record for the given
        type has status=granted.
        """
        result = await self.db.execute(
            select(Consent)
            .where(Consent.user_id == user_id)
            .where(Consent.type == consent_type)
            .order_by(Consent.created_at.desc())
            .limit(1)
        )
        latest: Optional[Consent] = result.scalar_one_or_none()
        if latest is None:
            return False
        return latest.status == ConsentStatus.granted

    async def get_latest(
        self, user_id: uuid.UUID, consent_type: ConsentType
    ) -> Optional[Consent]:
        result = await self.db.execute(
            select(Consent)
            .where(Consent.user_id == user_id)
            .where(Consent.type == consent_type)
            .order_by(Consent.created_at.desc())
            .limit(1)
        )
        return result.scalar_one_or_none()
