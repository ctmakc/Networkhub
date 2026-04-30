# Celery task modules – imported here so Celery auto-discovers tasks.
from app.tasks.celery_app import celery_app
from app.tasks.dedupe_tasks import dedupe_suggest
from app.tasks.email_tasks import send_followup_email
from app.tasks.enrichment_tasks import enrich_contact

__all__ = [
    "celery_app",
    "send_followup_email",
    "enrich_contact",
    "dedupe_suggest",
]
