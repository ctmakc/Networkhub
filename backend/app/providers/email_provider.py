"""
Email provider abstraction.

All providers implement the EmailProvider ABC.  The active provider is chosen
at runtime based on configuration so the rest of the codebase stays decoupled
from any particular vendor.
"""
from __future__ import annotations

import abc
import dataclasses
from typing import Optional


@dataclasses.dataclass
class EmailMessage:
    to_email: str
    to_name: Optional[str]
    from_email: str
    from_name: str
    subject: str
    body_html: str
    body_text: Optional[str] = None
    reply_to: Optional[str] = None


@dataclasses.dataclass
class SendResult:
    success: bool
    provider_message_id: Optional[str] = None
    error: Optional[str] = None


class EmailProvider(abc.ABC):
    """Abstract base class for all email providers."""

    @abc.abstractmethod
    async def send(self, message: EmailMessage) -> SendResult:
        """Send a single transactional email and return a SendResult."""
        raise NotImplementedError


class SendGridProvider(EmailProvider):
    """Production email provider backed by Twilio SendGrid."""

    def __init__(self, api_key: str) -> None:
        self._api_key = api_key

    async def send(self, message: EmailMessage) -> SendResult:
        try:
            from sendgrid import SendGridAPIClient
            from sendgrid.helpers.mail import Mail, To

            sg = SendGridAPIClient(self._api_key)
            mail = Mail(
                from_email=(message.from_email, message.from_name),
                to_emails=To(message.to_email, message.to_name or ""),
                subject=message.subject,
                html_content=message.body_html,
                plain_text_content=message.body_text or "",
            )
            if message.reply_to:
                mail.reply_to = message.reply_to

            response = sg.send(mail)
            message_id: Optional[str] = None
            if response.headers:
                message_id = response.headers.get("X-Message-Id")

            success = 200 <= response.status_code < 300
            return SendResult(
                success=success,
                provider_message_id=message_id,
                error=None if success else f"HTTP {response.status_code}",
            )
        except Exception as exc:
            return SendResult(success=False, error=str(exc))


class MailgunProvider(EmailProvider):
    """Stub Mailgun provider – swap in real implementation when needed."""

    def __init__(self, api_key: str, domain: str) -> None:
        self._api_key = api_key
        self._domain = domain

    async def send(self, message: EmailMessage) -> SendResult:
        # Placeholder: integrate with requests/httpx + Mailgun REST API
        return SendResult(
            success=False,
            error="MailgunProvider is not yet implemented. Use SendGridProvider.",
        )


class SESProvider(EmailProvider):
    """Stub AWS SES provider – swap in real implementation when needed."""

    def __init__(self, region: str = "us-east-1") -> None:
        self._region = region

    async def send(self, message: EmailMessage) -> SendResult:
        # Placeholder: integrate with boto3 SES client
        return SendResult(
            success=False,
            error="SESProvider is not yet implemented. Use SendGridProvider.",
        )


def get_default_provider() -> EmailProvider:
    """Factory: return the configured email provider instance."""
    from app.config import settings

    return SendGridProvider(api_key=settings.SENDGRID_API_KEY)
