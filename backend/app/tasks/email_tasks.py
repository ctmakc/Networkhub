"""
Celery task: send a follow-up email.

Retry strategy: up to 5 attempts with exponential back-off
(60 s → 120 s → 240 s → 480 s → 960 s).
"""
from __future__ import annotations

import asyncio
import uuid
from typing import Optional

import structlog

from app.tasks.celery_app import celery_app

logger = structlog.get_logger(__name__)

MAX_RETRIES = 5
BASE_BACKOFF_SECONDS = 60


@celery_app.task(
    bind=True,
    name="app.tasks.email_tasks.send_followup_email",
    max_retries=MAX_RETRIES,
    default_retry_delay=BASE_BACKOFF_SECONDS,
    acks_late=True,
)
def send_followup_email(
    self,
    job_id: str,
    to_email: str,
    subject_override: Optional[str] = None,
    body_override: Optional[str] = None,
) -> dict:
    """
    Load the EmailJob, render the template (or use overrides), send via the
    configured EmailProvider, and update job status.

    Uses asyncio.run() because SQLAlchemy async sessions are needed inside
    a synchronous Celery worker.
    """
    return asyncio.run(
        _send_followup_email_async(
            self,
            job_id=job_id,
            to_email=to_email,
            subject_override=subject_override,
            body_override=body_override,
        )
    )


async def _send_followup_email_async(
    task,
    job_id: str,
    to_email: str,
    subject_override: Optional[str],
    body_override: Optional[str],
) -> dict:
    from app.database import AsyncSessionLocal
    from app.domain.services.template_service import TemplateService
    from app.models.email_job import EmailJobStatus
    from app.models.interaction import InteractionType
    from app.providers.email_provider import EmailMessage, get_default_provider
    from app.repositories.contact_repository import ContactRepository
    from app.repositories.email_job_repository import EmailJobRepository
    from app.repositories.interaction_repository import InteractionRepository
    from app.repositories.template_repository import TemplateRepository
    from app.repositories.user_repository import UserRepository

    log = logger.bind(job_id=job_id)

    async with AsyncSessionLocal() as db:
        job_repo = EmailJobRepository(db)
        job = await job_repo.get(uuid.UUID(job_id))

        if job is None:
            log.error("EmailJob not found, skipping")
            return {"status": "not_found"}

        if job.status == EmailJobStatus.sent:
            log.info("EmailJob already sent, skipping")
            return {"status": "already_sent"}

        # Increment attempt counter
        await job_repo.update(job, attempts=job.attempts + 1)

        # Build subject / body
        subject = subject_override
        body = body_override

        if job.template_id and (not subject or not body):
            template_repo = TemplateRepository(db)
            template_service = TemplateService(template_repo)
            template = await template_repo.get(job.template_id)

            if template:
                # Build context for template rendering
                user_repo = UserRepository(db)
                contact_repo = ContactRepository(db)
                user = await user_repo.get(job.user_id)
                contact = await contact_repo.get_with_tags(job.contact_id)

                context = {
                    "user": user,
                    "contact": contact,
                }
                rendered_subject, rendered_body = template_service.render_template(
                    template, context
                )
                subject = subject or rendered_subject
                body = body or rendered_body

        if not subject or not body:
            error_msg = "Cannot send email: no subject or body available"
            log.error(error_msg)
            await job_repo.update(job, status=EmailJobStatus.failed, last_error=error_msg)
            await db.commit()
            return {"status": "failed", "error": error_msg}

        from app.config import settings

        message = EmailMessage(
            to_email=to_email,
            to_name=None,
            from_email=settings.EMAIL_FROM,
            from_name=settings.EMAIL_FROM_NAME,
            subject=subject,
            body_html=body,
            body_text=None,
        )

        provider = get_default_provider()
        result = await provider.send(message)

        if result.success:
            await job_repo.update(
                job,
                status=EmailJobStatus.sent,
                provider_message_id=result.provider_message_id,
                last_error=None,
            )
            # Log interaction
            interaction_repo = InteractionRepository(db)
            await interaction_repo.log(
                user_id=job.user_id,
                contact_id=job.contact_id,
                interaction_type=InteractionType.email_sent,
                payload={"job_id": job_id, "to_email": to_email},
            )
            await db.commit()
            log.info("Email sent successfully", provider_message_id=result.provider_message_id)
            return {"status": "sent", "provider_message_id": result.provider_message_id}
        else:
            error_msg = result.error or "Unknown provider error"
            await job_repo.update(job, last_error=error_msg)
            await db.commit()

            log.warning("Email send failed, will retry", error=error_msg, attempt=job.attempts)

            # Exponential back-off: 60 * 2^(attempt-1) seconds
            backoff = BASE_BACKOFF_SECONDS * (2 ** (job.attempts - 1))
            raise task.retry(exc=RuntimeError(error_msg), countdown=backoff)
