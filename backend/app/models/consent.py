import enum
import uuid
from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, String, Text, func
from sqlalchemy.dialects.postgresql import INET, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class ConsentType(str, enum.Enum):
    email_marketing = "email_marketing"
    data_processing = "data_processing"
    terms_of_service = "terms_of_service"


class ConsentStatus(str, enum.Enum):
    granted = "granted"
    revoked = "revoked"


class Consent(Base):
    __tablename__ = "consents"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    type: Mapped[ConsentType] = mapped_column(
        Enum(ConsentType, name="consent_type_enum"),
        nullable=False,
    )
    status: Mapped[ConsentStatus] = mapped_column(
        Enum(ConsentStatus, name="consent_status_enum"),
        nullable=False,
        default=ConsentStatus.granted,
    )
    # Version of the privacy policy / ToS the user agreed to
    version: Mapped[str] = mapped_column(String(50), nullable=False, default="1.0")
    ip_address: Mapped[str | None] = mapped_column(String(45), nullable=True)
    user_agent: Mapped[str | None] = mapped_column(Text, nullable=True)
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
    user: Mapped["User"] = relationship("User", back_populates="consents")  # noqa: F821

    def __repr__(self) -> str:
        return f"<Consent id={self.id} user_id={self.user_id} type={self.type} status={self.status}>"
