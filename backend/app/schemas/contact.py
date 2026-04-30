import uuid
from datetime import datetime
from typing import Any, Optional

from pydantic import BaseModel, field_validator

from app.models.contact import ContactSource


class EmailEntry(BaseModel):
    value: str
    label: str = "work"

    @field_validator("label")
    @classmethod
    def validate_label(cls, v: str) -> str:
        allowed = {"work", "personal", "other"}
        if v not in allowed:
            raise ValueError(f"label must be one of {allowed}")
        return v


class PhoneEntry(BaseModel):
    value: str
    label: str = "work"

    @field_validator("label")
    @classmethod
    def validate_label(cls, v: str) -> str:
        allowed = {"work", "mobile", "home", "other"}
        if v not in allowed:
            raise ValueError(f"label must be one of {allowed}")
        return v


class AddressSchema(BaseModel):
    street: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    country: Optional[str] = None


class ContactCreate(BaseModel):
    first_name: str
    last_name: Optional[str] = None
    company: Optional[str] = None
    title: Optional[str] = None
    emails: list[EmailEntry] = []
    phones: list[PhoneEntry] = []
    website: Optional[str] = None
    address: Optional[AddressSchema] = None
    notes: Optional[str] = None
    device_contact_id: Optional[str] = None
    source: ContactSource = ContactSource.manual
    tags: list[str] = []

    @field_validator("first_name")
    @classmethod
    def first_name_not_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("first_name must not be empty")
        return v.strip()


class ContactUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    company: Optional[str] = None
    title: Optional[str] = None
    emails: Optional[list[EmailEntry]] = None
    phones: Optional[list[PhoneEntry]] = None
    website: Optional[str] = None
    address: Optional[AddressSchema] = None
    notes: Optional[str] = None
    tags: Optional[list[str]] = None


class TagResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    name: str


class ContactResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    user_id: uuid.UUID
    first_name: str
    last_name: Optional[str] = None
    company: Optional[str] = None
    title: Optional[str] = None
    emails: list[Any] = []
    phones: list[Any] = []
    website: Optional[str] = None
    address: Optional[Any] = None
    notes: Optional[str] = None
    device_contact_id: Optional[str] = None
    source: ContactSource
    tags: list[TagResponse] = []
    created_at: datetime
    updated_at: datetime


class ContactList(BaseModel):
    items: list[ContactResponse]
    total: int
    page: int
    page_size: int
    has_more: bool


# Used when OCR/import creates a draft that needs user confirmation
class DraftContact(BaseModel):
    first_name: str
    last_name: Optional[str] = None
    company: Optional[str] = None
    title: Optional[str] = None
    emails: list[EmailEntry] = []
    phones: list[PhoneEntry] = []
    website: Optional[str] = None
    notes: Optional[str] = None
    # Confidence score 0-1 from OCR
    confidence: float = 1.0
    raw_text: Optional[str] = None
