import uuid
from typing import Optional, Sequence

import sqlalchemy as sa
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.contact import Contact
from app.repositories.base import BaseRepository


class ContactRepository(BaseRepository[Contact]):
    model = Contact

    def __init__(self, db: AsyncSession) -> None:
        super().__init__(db)

    async def get_with_tags(self, contact_id: uuid.UUID) -> Optional[Contact]:
        """Fetch a contact and eagerly load its tags."""
        result = await self.db.execute(
            select(Contact)
            .options(selectinload(Contact.tags))
            .where(Contact.id == contact_id)
        )
        return result.scalar_one_or_none()

    async def list_for_user(
        self,
        user_id: uuid.UUID,
        *,
        search: Optional[str] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> tuple[Sequence[Contact], int]:
        """
        Return (contacts, total_count) for a user, with optional full-text search
        across first_name, last_name, company, and the emails JSONB array.
        """
        base_stmt = (
            select(Contact)
            .options(selectinload(Contact.tags))
            .where(Contact.user_id == user_id)
        )

        if search:
            term = f"%{search.lower()}%"
            base_stmt = base_stmt.where(
                or_(
                    func.lower(Contact.first_name).like(term),
                    func.lower(Contact.last_name).like(term),
                    func.lower(Contact.company).like(term),
                    Contact.emails.cast(sa.Text()).ilike(f"%{search}%"),
                )
            )

        count_stmt = select(func.count()).select_from(base_stmt.subquery())
        total_result = await self.db.execute(count_stmt)
        total: int = total_result.scalar_one()

        offset = (page - 1) * page_size
        paged_stmt = base_stmt.order_by(Contact.created_at.desc()).offset(offset).limit(page_size)
        result = await self.db.execute(paged_stmt)
        contacts = result.scalars().all()

        return contacts, total

    async def find_duplicates_by_email(
        self, user_id: uuid.UUID, email: str
    ) -> Sequence[Contact]:
        """Return contacts whose emails JSONB array contains the given value."""
        result = await self.db.execute(
            select(Contact)
            .options(selectinload(Contact.tags))
            .where(Contact.user_id == user_id)
            .where(Contact.emails.contains([{"value": email}]))
        )
        return result.scalars().all()

    async def find_duplicates_by_phone(
        self, user_id: uuid.UUID, phone: str
    ) -> Sequence[Contact]:
        """Return contacts whose phones JSONB array contains the given value."""
        result = await self.db.execute(
            select(Contact)
            .options(selectinload(Contact.tags))
            .where(Contact.user_id == user_id)
            .where(Contact.phones.contains([{"value": phone}]))
        )
        return result.scalars().all()
