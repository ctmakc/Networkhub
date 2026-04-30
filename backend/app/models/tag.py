import uuid
from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, String, Table, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

# Association table (many-to-many: contacts <-> tags)
# Must use Column (core) not mapped_column (ORM) in a plain Table definition.
ContactTag = Table(
    "contact_tags",
    Base.metadata,
    Column("contact_id", UUID(as_uuid=True), ForeignKey("contacts.id", ondelete="CASCADE"), primary_key=True),
    Column("tag_id", UUID(as_uuid=True), ForeignKey("tags.id", ondelete="CASCADE"), primary_key=True),
)


class Tag(Base):
    __tablename__ = "tags"
    __table_args__ = (UniqueConstraint("user_id", "name", name="uq_tags_user_name"),)

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    # Relationships
    contacts: Mapped[list["Contact"]] = relationship(  # noqa: F821
        "Contact", secondary="contact_tags", back_populates="tags"
    )

    def __repr__(self) -> str:
        return f"<Tag id={self.id} name={self.name}>"
