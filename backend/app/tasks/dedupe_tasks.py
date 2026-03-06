"""
Celery task: generate de-duplication suggestions for a user's contacts.
"""
from __future__ import annotations

import asyncio
import uuid

import structlog

from app.tasks.celery_app import celery_app

logger = structlog.get_logger(__name__)


@celery_app.task(
    bind=True,
    name="app.tasks.dedupe_tasks.dedupe_suggest",
    max_retries=2,
    default_retry_delay=15,
    acks_late=True,
)
def dedupe_suggest(self, user_id: str) -> dict:
    """
    Scan all contacts belonging to `user_id` and return a list of probable
    duplicate pairs based on matching email addresses or phone numbers.

    In the MVP this result is stored in Redis / returned directly.  A
    production version would persist suggestions to a database table and
    surface them via the API.
    """
    return asyncio.run(
        _dedupe_suggest_async(self, user_id)
    )


async def _dedupe_suggest_async(task, user_id: str) -> dict:
    from app.database import AsyncSessionLocal
    from app.repositories.contact_repository import ContactRepository

    log = logger.bind(user_id=user_id)
    uid = uuid.UUID(user_id)

    async with AsyncSessionLocal() as db:
        repo = ContactRepository(db)
        # Fetch all contacts (paginate in batches of 500 for large datasets)
        contacts, total = await repo.list_for_user(uid, page=1, page_size=500)
        log.info("Running dedupe scan", total=total)

        # Build lookup maps
        email_map: dict[str, list[str]] = {}  # email_value -> [contact_id, ...]
        phone_map: dict[str, list[str]] = {}

        for c in contacts:
            cid = str(c.id)
            for entry in (c.emails or []):
                val = entry.get("value") if isinstance(entry, dict) else str(entry)
                if val:
                    email_map.setdefault(val.lower(), []).append(cid)
            for entry in (c.phones or []):
                val = entry.get("value") if isinstance(entry, dict) else str(entry)
                if val:
                    # Normalise digits only for comparison
                    digits = "".join(ch for ch in val if ch.isdigit())
                    if digits:
                        phone_map.setdefault(digits, []).append(cid)

        duplicate_pairs: list[dict] = []
        seen: set[frozenset] = set()

        for val, ids in {**email_map, **phone_map}.items():
            if len(ids) < 2:
                continue
            for i in range(len(ids)):
                for j in range(i + 1, len(ids)):
                    pair = frozenset([ids[i], ids[j]])
                    if pair not in seen:
                        seen.add(pair)
                        duplicate_pairs.append(
                            {"contact_a": ids[i], "contact_b": ids[j], "matched_on": val}
                        )

        log.info("Dedupe scan complete", pairs_found=len(duplicate_pairs))
        return {"user_id": user_id, "duplicate_pairs": duplicate_pairs}
