import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, field_validator


class TemplateCreate(BaseModel):
    name: str
    subject: str
    body: str
    is_default: bool = False

    @field_validator("name", "subject", "body")
    @classmethod
    def not_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("Field must not be empty")
        return v


class TemplateUpdate(BaseModel):
    name: Optional[str] = None
    subject: Optional[str] = None
    body: Optional[str] = None
    is_default: Optional[bool] = None

    @field_validator("name", "subject", "body", mode="before")
    @classmethod
    def not_empty_if_provided(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and not v.strip():
            raise ValueError("Field must not be empty if provided")
        return v


class TemplateResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    user_id: uuid.UUID
    name: str
    subject: str
    body: str
    is_default: bool
    created_at: datetime
    updated_at: datetime
