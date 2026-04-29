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


class EventUpdate(BaseModel):
    name: Optional[str] = None
    location: Optional[str] = None
    event_date: Optional[date] = None

    @field_validator("name")
    @classmethod
    def name_not_empty(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and not v.strip():
            raise ValueError("name must not be empty")
        return v.strip() if v else v


class EventResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    user_id: uuid.UUID
    name: str
    location: Optional[str] = None
    event_date: date
    created_at: datetime
