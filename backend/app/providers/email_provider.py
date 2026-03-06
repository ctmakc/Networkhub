"""
Email provider abstraction.

All providers implement the EmailProvider ABC.  The active provider is chosen
at runtime based on configuration so the rest of the codebase stays decoupled
from any particular vendor.
"""
from __future__ import annotations

import abc
import asyncio
import dataclasses
from functools import partial
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

    def _send_sync(self, message: EmailMessage) -> SendResult:
        """Blocking SendGrid call – run this in a thread-pool executor."""
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

    async def send(self, message: EmailMessage) -> SendResult:
        """Send via SendGrid; offload blocking I/O to the thread-pool executor."""
        try:
            loop = asyncio.get_running_loop()
            result = await loop.run_in_executor(None, partial(self._send_sync, message))
            return result
        except Exception as exc:
            return SendResult(success=False, error=str(exc))


class MailgunProvider(EmailProvider):
    """Mailgun provider using httpx async HTTP client."""

    def __init__(self, api_key: str, domain: str) -> None:
        self._api_key = api_key
        self._domain = domain

    async def send(self, message: EmailMessage) -> SendResult:
        try:
            import httpx

            url = f"https://api.mailgun.net/v3/{self._domain}/messages"
            data = {
                "from": f"{message.from_name} <{message.from_email}>",
                "to": message.to_email,
                "subject": message.subject,
                "html": message.body_html,
            }
            if message.body_text:
                data["text"] = message.body_text
            if message.reply_to:
                data["h:Reply-To"] = message.reply_to

            async with httpx.AsyncClient() as client:
                resp = await client.post(
                    url,
                    auth=("api", self._api_key),
                    data=data,
                    timeout=15.0,
                )

            success = 200 <= resp.status_code < 300
            body = resp.json() if resp.content else {}
            return SendResult(
                success=success,
                provider_message_id=body.get("id"),
                error=None if success else f"HTTP {resp.status_code}: {body.get('message')}",
            )
        except Exception as exc:
            return SendResult(success=False, error=str(exc))


class SESProvider(EmailProvider):
    """AWS SES provider using boto3 (run in executor to keep async-safe)."""

    def __init__(self, region: str = "us-east-1") -> None:
        self._region = region

    def _send_sync(self, message: EmailMessage) -> SendResult:
        import boto3

        client = boto3.client("ses", region_name=self._region)
        body: dict = {"Html": {"Data": message.body_html, "Charset": "UTF-8"}}
        if message.body_text:
            body["Text"] = {"Data": message.body_text, "Charset": "UTF-8"}

        response = client.send_email(
            Source=f"{message.from_name} <{message.from_email}>",
            Destination={"ToAddresses": [message.to_email]},
            Message={
                "Subject": {"Data": message.subject, "Charset": "UTF-8"},
                "Body": body,
            },
            ReplyToAddresses=[message.reply_to] if message.reply_to else [],
        )
        msg_id = response.get("MessageId")
        return SendResult(success=True, provider_message_id=msg_id)

    async def send(self, message: EmailMessage) -> SendResult:
        try:
            loop = asyncio.get_running_loop()
            return await loop.run_in_executor(None, partial(self._send_sync, message))
        except Exception as exc:
            return SendResult(success=False, error=str(exc))


def get_default_provider() -> EmailProvider:
    """Factory: return the configured email provider instance."""
    from app.config import settings

    return SendGridProvider(api_key=settings.SENDGRID_API_KEY)
