import uuid
from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, field_validator


class EventCreate(BaseModel):
    name: str
    location: Optional[str] = None
    event_date: date

    @field_validator("name")
    @classmethod
    def name_not_empty(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("name must not be empty")
        return v.strip()


class EventResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    user_id: uuid.UUID
    name: str
    location: Optional[str] = None
    event_date: date
    created_at: datetime
