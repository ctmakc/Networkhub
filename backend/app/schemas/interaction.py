import uuid
from datetime import datetime
from typing import Any, Optional

from pydantic import BaseModel

from app.models.interaction import InteractionType


class InteractionResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    user_id: uuid.UUID
    contact_id: uuid.UUID
    event_id: Optional[uuid.UUID] = None
    type: InteractionType
    payload: Optional[dict[str, Any]] = None
    created_at: datetime
