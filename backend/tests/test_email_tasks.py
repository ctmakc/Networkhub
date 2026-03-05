"""Tests for email task logic with mocked email provider."""

import uuid
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.models.email_job import EmailJobStatus
from app.providers.email_provider import EmailMessage, SendResult


@pytest.mark.asyncio
async def test_queue_email_creates_job(db_session, test_user) -> None:
    """EmailService.queue_email should create an EmailJob record."""
    from app.models.contact import Contact, ContactSource
    from app.domain.services.email_service import EmailService
    from app.repositories.contact_repository import ContactRepository
    from app.repositories.email_job_repository import EmailJobRepository
    from app.repositories.interaction_repository import InteractionRepository
    from app.repositories.template_repository import TemplateRepository

    # Create a contact with an email address
    contact = Contact(
        id=uuid.uuid4(),
        user_id=test_user.id,
        first_name="Email",
        last_name="Recipient",
        emails=[{"value": "recipient@example.com", "label": "work"}],
        source=ContactSource.manual,
    )
    db_session.add(contact)
    await db_session.flush()

    email_job_repo = EmailJobRepository(db_session)
    template_repo = TemplateRepository(db_session)
    interaction_repo = InteractionRepository(db_session)

    service = EmailService(
        email_job_repo=email_job_repo,
        template_repo=template_repo,
        interaction_repo=interaction_repo,
    )

    # Patch the Celery task dispatch so it doesn't actually run
    with patch("app.tasks.email_tasks.send_followup_email") as mock_task:
        mock_task.apply_async = MagicMock()
        job = await service.queue_email(
            user=test_user,
            contact=contact,
            subject_override="Test Subject",
            body_override="<p>Test Body</p>",
        )

    assert job is not None
    assert job.status == EmailJobStatus.queued
    assert job.user_id == test_user.id
    assert job.contact_id == contact.id


@pytest.mark.asyncio
async def test_queue_email_idempotency(db_session, test_user) -> None:
    """Calling queue_email twice with the same params should return the same job."""
    from app.models.contact import Contact, ContactSource
    from app.domain.services.email_service import EmailService
    from app.repositories.contact_repository import ContactRepository
    from app.repositories.email_job_repository import EmailJobRepository
    from app.repositories.interaction_repository import InteractionRepository
    from app.repositories.template_repository import TemplateRepository

    contact = Contact(
        id=uuid.uuid4(),
        user_id=test_user.id,
        first_name="Idem",
        emails=[{"value": "idem@example.com", "label": "work"}],
        source=ContactSource.manual,
    )
    db_session.add(contact)
    await db_session.flush()

    service = EmailService(
        email_job_repo=EmailJobRepository(db_session),
        template_repo=TemplateRepository(db_session),
        interaction_repo=InteractionRepository(db_session),
    )

    with patch("app.tasks.email_tasks.send_followup_email") as mock_task:
        mock_task.apply_async = MagicMock()
        job1 = await service.queue_email(
            user=test_user,
            contact=contact,
            subject_override="Hi",
            body_override="Body",
        )
        job2 = await service.queue_email(
            user=test_user,
            contact=contact,
            subject_override="Hi",
            body_override="Body",
        )

    assert job1.id == job2.id
    assert job1.idempotency_key == job2.idempotency_key


@pytest.mark.asyncio
async def test_queue_email_no_email_address_raises(db_session, test_user) -> None:
    """EmailService should raise ValueError when contact has no email."""
    from app.models.contact import Contact, ContactSource
    from app.domain.services.email_service import EmailService
    from app.repositories.email_job_repository import EmailJobRepository
    from app.repositories.interaction_repository import InteractionRepository
    from app.repositories.template_repository import TemplateRepository

    contact = Contact(
        id=uuid.uuid4(),
        user_id=test_user.id,
        first_name="NoEmail",
        emails=[],
        source=ContactSource.manual,
    )
    db_session.add(contact)
    await db_session.flush()

    service = EmailService(
        email_job_repo=EmailJobRepository(db_session),
        template_repo=TemplateRepository(db_session),
        interaction_repo=InteractionRepository(db_session),
    )

    with pytest.raises(ValueError, match="no email address"):
        await service.queue_email(
            user=test_user,
            contact=contact,
            subject_override="Hi",
            body_override="Body",
        )


def test_sendgrid_provider_handles_exception() -> None:
    """SendGridProvider.send should return a failed SendResult on exception."""
    import asyncio
    from app.providers.email_provider import EmailMessage, SendGridProvider

    provider = SendGridProvider(api_key="SG.fake")
    message = EmailMessage(
        to_email="test@example.com",
        to_name="Test",
        from_email="from@example.com",
        from_name="Sender",
        subject="Test",
        body_html="<p>Test</p>",
    )

    # sendgrid import will fail with a fake key; we just check it returns a result
    result = asyncio.get_event_loop().run_until_complete(provider.send(message))
    assert isinstance(result, SendResult)
    # Either success (unlikely in test) or failure with an error message
    if not result.success:
        assert result.error is not None


def test_stub_ocr_provider() -> None:
    """StubOCRProvider should return a zero-confidence result."""
    import asyncio
    from app.providers.ocr_provider import StubOCRProvider

    provider = StubOCRProvider()
    result = asyncio.get_event_loop().run_until_complete(
        provider.extract(b"fake image bytes")
    )
    assert result.confidence == 0.0
    assert result.raw_text == ""


def test_python_normalize_provider() -> None:
    """PythonNormalizeProvider should split full_name into first/last."""
    import asyncio
    from app.providers.enrichment_provider import PythonNormalizeProvider
    from app.schemas.enrichment import EnrichRequest

    provider = PythonNormalizeProvider()
    result = asyncio.get_event_loop().run_until_complete(
        provider.enrich(EnrichRequest(full_name="John Doe", company="Acme"))
    )
    assert result.first_name == "John"
    assert result.last_name == "Doe"
    assert result.company == "Acme"
    assert result.provider == "python_normalize"
    assert len(result.profiles) >= 1  # LinkedIn search suggestion
