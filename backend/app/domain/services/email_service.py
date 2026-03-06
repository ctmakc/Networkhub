import hashlib
import uuid
from datetime import date
from typing import Optional

from sqlalchemy.exc import IntegrityError

from app.config import settings
from app.models.contact import Contact
from app.models.email_job import EmailJob, EmailJobStatus
from app.models.user import User
from app.repositories.email_job_repository import EmailJobRepository
from app.repositories.interaction_repository import InteractionRepository
from app.repositories.template_repository import TemplateRepository


def _build_idempotency_key(
    user_id: uuid.UUID,
    contact_id: uuid.UUID,
    template_id: Optional[uuid.UUID],
    today: date,
) -> str:
    raw = f"{user_id}:{contact_id}:{template_id}:{today.isoformat()}"
    return hashlib.sha256(raw.encode()).hexdigest()


class EmailService:
    def __init__(
        self,
        email_job_repo: EmailJobRepository,
        template_repo: TemplateRepository,
        interaction_repo: InteractionRepository,
    ) -> None:
        self.email_job_repo = email_job_repo
        self.template_repo = template_repo
        self.interaction_repo = interaction_repo

    async def check_daily_limit(self, user_id: uuid.UUID) -> bool:
        """Return True if the user has NOT hit their daily email limit."""
        count = await self.email_job_repo.count_sent_today(user_id)
        return count < settings.EMAIL_DAILY_LIMIT

    async def queue_email(
        self,
        user: User,
        contact: Contact,
        template_id: Optional[uuid.UUID] = None,
        subject_override: Optional[str] = None,
        body_override: Optional[str] = None,
        recipient_email: Optional[str] = None,
    ) -> EmailJob:
        """
        Validate limits, build an idempotency key, create an EmailJob record,
        and dispatch the Celery task.

        Raises:
            ValueError: if the daily limit is exceeded, no recipient email found,
                        or template is missing when no override is provided.
        """
        if not await self.check_daily_limit(user.id):
            raise ValueError(
                f"Daily email limit of {settings.EMAIL_DAILY_LIMIT} reached. "
                "Try again tomorrow."
            )

        # Determine recipient
        to_email = recipient_email
        if not to_email and contact.emails:
            first = contact.emails[0]
            to_email = first.get("value") if isinstance(first, dict) else str(first)

        if not to_email:
            raise ValueError("Contact has no email address and no recipient_email was supplied.")

        # Validate content (treat empty/whitespace as missing)
        has_overrides = bool(subject_override and subject_override.strip()) and bool(
            body_override and body_override.strip()
        )
        if template_id is None and not has_overrides:
            raise ValueError(
                "Either template_id or both subject and body must be provided."
            )

        idempotency_key = _build_idempotency_key(
            user.id, contact.id, template_id, date.today()
        )

        # Optimistic create – let the DB unique constraint handle concurrent duplicates
        job = EmailJob(
            user_id=user.id,
            contact_id=contact.id,
            template_id=template_id,
            status=EmailJobStatus.queued,
            idempotency_key=idempotency_key,
            attempts=0,
        )
        try:
            job = await self.email_job_repo.create(job)
        except IntegrityError:
            # Concurrent request beat us to it – fetch the existing row
            await self.email_job_repo.db.rollback()
            existing = await self.email_job_repo.get_by_idempotency_key(idempotency_key)
            if existing is not None:
                return existing
            raise  # truly unexpected

        from app.tasks.email_tasks import send_followup_email

        send_followup_email.apply_async(
            args=[str(job.id)],
            kwargs={
                "to_email": to_email,
                "subject_override": subject_override,
                "body_override": body_override,
            },
        )

        return job
