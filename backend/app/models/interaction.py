import enum
import uuid
from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class InteractionType(str, enum.Enum):
    met = "met"
    email_sent = "email_sent"
    email_failed = "email_failed"
    note_added = "note_added"


class Interaction(Base):
    __tablename__ = "interactions"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    contact_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("contacts.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    event_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("events.id", ondelete="SET NULL"),
        nullable=True,
    )
    type: Mapped[InteractionType] = mapped_column(
        Enum(InteractionType, name="interaction_type_enum"),
        nullable=False,
    )
    # Arbitrary JSON payload (e.g. email subject, error message, note text)
    payload: Mapped[dict | None] = mapped_column(JSONB, nullable=True, default=None)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    # Relationships
    contact: Mapped["Contact"] = relationship(  # noqa: F821
        "Contact", back_populates="interactions"
    )
    event: Mapped["Event | None"] = relationship(  # noqa: F821
        "Event", back_populates="interactions"
    )

    def __repr__(self) -> str:
        return f"<Interaction id={self.id} type={self.type}>"
