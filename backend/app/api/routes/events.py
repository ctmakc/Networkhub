from typing import Annotated

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import CurrentUser
from app.database import get_db
from app.repositories.event_repository import EventRepository
from app.schemas.event import EventCreate, EventResponse

router = APIRouter(prefix="/events", tags=["events"])


@router.post("", response_model=EventResponse, status_code=status.HTTP_201_CREATED)
async def create_event(
    payload: EventCreate,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> EventResponse:
    repo = EventRepository(db)
    from app.models.event import Event

    event = await repo.create(
        Event(
            user_id=current_user.id,
            name=payload.name,
            location=payload.location,
            event_date=payload.event_date,
        )
    )
    return EventResponse.model_validate(event)


@router.get("", response_model=list[EventResponse])
async def list_events(
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> list[EventResponse]:
    repo = EventRepository(db)
    events = await repo.list_for_user(current_user.id)
    return [EventResponse.model_validate(e) for e in events]
