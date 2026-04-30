from __future__ import annotations

import uuid
from typing import Optional, Sequence


from app.models.contact import Contact
from app.models.interaction import InteractionType
from app.models.tag import Tag
from app.repositories.contact_repository import ContactRepository
from app.repositories.interaction_repository import InteractionRepository
from app.schemas.contact import ContactCreate, ContactUpdate


class ContactService:
    def __init__(
        self,
        contact_repo: ContactRepository,
        interaction_repo: InteractionRepository,
    ) -> None:
        self.contact_repo = contact_repo
        self.interaction_repo = interaction_repo

    async def create(self, user_id: uuid.UUID, data: ContactCreate) -> Contact:
        """Create a new contact and log a 'met' interaction."""
        contact = Contact(
            user_id=user_id,
            first_name=data.first_name,
            last_name=data.last_name,
            company=data.company,
            title=data.title,
            emails=[e.model_dump() for e in data.emails],
            phones=[p.model_dump() for p in data.phones],
            website=data.website,
            address=data.address.model_dump() if data.address else None,
            notes=data.notes,
            device_contact_id=data.device_contact_id,
            source=data.source,
        )

        # Resolve / create tags
        if data.tags:
            contact.tags = await self._resolve_tags(user_id, data.tags)

        contact = await self.contact_repo.create(contact)

        # Log the initial interaction
        await self.interaction_repo.log(
            user_id=user_id,
            contact_id=contact.id,
            interaction_type=InteractionType.met,
            payload={"source": data.source.value},
        )

        # Re-fetch with tags eagerly loaded so serialization doesn't trigger lazy IO
        contact = await self.contact_repo.get_with_tags(contact.id)
        return contact

    async def get(self, user_id: uuid.UUID, contact_id: uuid.UUID) -> Optional[Contact]:
        """Return a contact only if it belongs to the given user."""
        contact = await self.contact_repo.get_with_tags(contact_id)
        if contact is None or contact.user_id != user_id:
            return None
        return contact

    async def list(
        self,
        user_id: uuid.UUID,
        *,
        search: Optional[str] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> tuple[Sequence[Contact], int]:
        return await self.contact_repo.list_for_user(
            user_id, search=search, page=page, page_size=page_size
        )

    async def update(
        self, user_id: uuid.UUID, contact_id: uuid.UUID, data: ContactUpdate
    ) -> Optional[Contact]:
        contact = await self.contact_repo.get_with_tags(contact_id)
        if contact is None or contact.user_id != user_id:
            return None

        update_fields: dict = {}
        if data.first_name is not None:
            update_fields["first_name"] = data.first_name
        if data.last_name is not None:
            update_fields["last_name"] = data.last_name
        if data.company is not None:
            update_fields["company"] = data.company
        if data.title is not None:
            update_fields["title"] = data.title
        if data.emails is not None:
            update_fields["emails"] = [e.model_dump() for e in data.emails]
        if data.phones is not None:
            update_fields["phones"] = [p.model_dump() for p in data.phones]
        if data.website is not None:
            update_fields["website"] = data.website
        if data.address is not None:
            update_fields["address"] = data.address.model_dump()
        if data.notes is not None:
            update_fields["notes"] = data.notes

        if data.tags is not None:
            contact.tags = await self._resolve_tags(user_id, data.tags)

        if update_fields:
            contact = await self.contact_repo.update(contact, **update_fields)
        else:
            # Still need to flush for potential tag updates
            await self.contact_repo.db.flush()
            await self.contact_repo.db.refresh(contact)

        return contact

    async def dedupe_check(
        self, user_id: uuid.UUID, data: ContactCreate
    ) -> list[Contact]:
        """Return existing contacts that match by email or phone (potential duplicates)."""
        dupes: list[Contact] = []
        seen_ids: set[uuid.UUID] = set()

        for email_entry in data.emails:
            matches = await self.contact_repo.find_duplicates_by_email(
                user_id, email_entry.value
            )
            for m in matches:
                if m.id not in seen_ids:
                    dupes.append(m)
                    seen_ids.add(m.id)

        for phone_entry in data.phones:
            matches = await self.contact_repo.find_duplicates_by_phone(
                user_id, phone_entry.value
            )
            for m in matches:
                if m.id not in seen_ids:
                    dupes.append(m)
                    seen_ids.add(m.id)

        return dupes

    async def _resolve_tags(self, user_id: uuid.UUID, tag_names: list[str]) -> list[Tag]:
        """Find or create Tag objects for the given names under user_id."""
        from sqlalchemy import select

        tags: list[Tag] = []
        for name in tag_names:
            name = name.strip()
            if not name:
                continue
            result = await self.contact_repo.db.execute(
                select(Tag).where(Tag.user_id == user_id).where(Tag.name == name)
            )
            tag = result.scalar_one_or_none()
            if tag is None:
                tag = Tag(user_id=user_id, name=name)
                self.contact_repo.db.add(tag)
                await self.contact_repo.db.flush()
                await self.contact_repo.db.refresh(tag)
            tags.append(tag)
        return tags
