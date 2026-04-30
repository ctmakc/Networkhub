import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, field_validator

from app.models.email_job import EmailJobStatus


class SendEmailRequest(BaseModel):
    template_id: Optional[uuid.UUID] = None
    # If template_id is None, these are required
    subject: Optional[str] = None
    body: Optional[str] = None
    # Optional: override recipient email (defaults to contact's primary email)
    recipient_email: Optional[str] = None

    @field_validator("subject", "body", mode="before")
    @classmethod
    def not_empty_if_provided(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and not v.strip():
            raise ValueError("Field must not be empty if provided")
        return v


class EmailJobResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    user_id: uuid.UUID
    contact_id: uuid.UUID
    template_id: Optional[uuid.UUID] = None
    status: EmailJobStatus
    idempotency_key: str
    provider_message_id: Optional[str] = None
    last_error: Optional[str] = None
    attempts: int
    created_at: datetime
    updated_at: datetime
