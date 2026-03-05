"""
Celery task: enrich a contact with external profile data.
"""
from __future__ import annotations

import asyncio
import uuid

import structlog

from app.tasks.celery_app import celery_app

logger = structlog.get_logger(__name__)


@celery_app.task(
    bind=True,
    name="app.tasks.enrichment_tasks.enrich_contact",
    max_retries=3,
    default_retry_delay=30,
    acks_late=True,
)
def enrich_contact(self, contact_id: str) -> dict:
    """
    Attempt to enrich the contact identified by `contact_id`.
    Runs enrichment provider and updates the contact record if new data
    is returned.
    """
    return asyncio.get_event_loop().run_until_complete(
        _enrich_contact_async(self, contact_id)
    )


async def _enrich_contact_async(task, contact_id: str) -> dict:
    from app.database import AsyncSessionLocal
    from app.providers.enrichment_provider import get_default_provider
    from app.repositories.contact_repository import ContactRepository
    from app.schemas.enrichment import EnrichRequest

    log = logger.bind(contact_id=contact_id)

    async with AsyncSessionLocal() as db:
        repo = ContactRepository(db)
        contact = await repo.get_with_tags(uuid.UUID(contact_id))

        if contact is None:
            log.warning("Contact not found, skipping enrichment")
            return {"status": "not_found"}

        primary_email = None
        if contact.emails:
            first = contact.emails[0]
            primary_email = first.get("value") if isinstance(first, dict) else str(first)

        request = EnrichRequest(
            email=primary_email,
            full_name=f"{contact.first_name} {contact.last_name or ''}".strip() or None,
            company=contact.company,
        )

        provider = get_default_provider()
        try:
            result = await provider.enrich(request)
        except Exception as exc:
            log.error("Enrichment provider failed", error=str(exc))
            raise task.retry(exc=exc, countdown=30)

        # Merge returned data only for fields that are currently empty
        update_fields: dict = {}
        if result.company and not contact.company:
            update_fields["company"] = result.company
        if result.title and not contact.title:
            update_fields["title"] = result.title

        if update_fields:
            await repo.update(contact, **update_fields)
            await db.commit()
            log.info("Contact enriched", fields=list(update_fields.keys()))
        else:
            log.info("No new enrichment data")

        return {"status": "ok", "updated_fields": list(update_fields.keys()), "provider": result.provider}
