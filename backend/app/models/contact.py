import uuid
from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, String, Text, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

import enum


class ContactSource(str, enum.Enum):
    scan = "scan"
    manual = "manual"
    import_ = "import"


class Contact(Base):
    __tablename__ = "contacts"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    first_name: Mapped[str] = mapped_column(String(255), nullable=False)
    last_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    company: Mapped[str | None] = mapped_column(String(255), nullable=True)
    title: Mapped[str | None] = mapped_column(String(255), nullable=True)
    # JSON arrays: [{"value": "...", "label": "work"|"personal"|"other"}]
    emails: Mapped[list | None] = mapped_column(JSONB, nullable=True, default=list)
    phones: Mapped[list | None] = mapped_column(JSONB, nullable=True, default=list)
    website: Mapped[str | None] = mapped_column(String(500), nullable=True)
    address: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    device_contact_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    source: Mapped[ContactSource] = mapped_column(
        Enum(ContactSource, name="contact_source_enum"),
        nullable=False,
        default=ContactSource.manual,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="contacts")  # noqa: F821
    interactions: Mapped[list["Interaction"]] = relationship(  # noqa: F821
        "Interaction", back_populates="contact", cascade="all, delete-orphan"
    )
    email_jobs: Mapped[list["EmailJob"]] = relationship(  # noqa: F821
        "EmailJob", back_populates="contact", cascade="all, delete-orphan"
    )
    tags: Mapped[list["Tag"]] = relationship(  # noqa: F821
        "Tag", secondary="contact_tags", back_populates="contacts"
    )

    def __repr__(self) -> str:
        return f"<Contact id={self.id} name={self.first_name} {self.last_name}>"
