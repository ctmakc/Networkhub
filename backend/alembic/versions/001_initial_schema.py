"""Initial schema – create all tables matching current ORM models

Revision ID: 001
Revises:
Create Date: 2026-03-05 00:00:00.000000
"""
from __future__ import annotations

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

# Enum type definitions – created once via raw DDL so SQLAlchemy Enum columns
# reference existing types (create_constraint=False on each column).
_ENUM_DDL = [
    "CREATE TYPE contact_source_enum AS ENUM ('scan', 'manual', 'import')",
    "CREATE TYPE interaction_type_enum AS ENUM ('met', 'email_sent', 'email_failed', 'note_added')",
    "CREATE TYPE consent_type_enum AS ENUM ('email_marketing', 'data_processing', 'terms_of_service')",
    "CREATE TYPE consent_status_enum AS ENUM ('granted', 'revoked')",
    "CREATE TYPE email_job_status_enum AS ENUM ('queued', 'sent', 'failed')",
]

_DROP_ENUM_DDL = [
    "DROP TYPE IF EXISTS email_job_status_enum",
    "DROP TYPE IF EXISTS consent_status_enum",
    "DROP TYPE IF EXISTS consent_type_enum",
    "DROP TYPE IF EXISTS interaction_type_enum",
    "DROP TYPE IF EXISTS contact_source_enum",
]


def upgrade() -> None:
    # ── Enum types (created once, referenced by columns below) ───────────────
    for ddl in _ENUM_DDL:
        op.execute(ddl)

    # ── users ─────────────────────────────────────────────────────────────────
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("email", sa.String(255), nullable=False),
        sa.Column("full_name", sa.String(255), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        sa.Column("is_verified", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)

    # ── templates ─────────────────────────────────────────────────────────────
    op.create_table(
        "templates",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("subject", sa.String(500), nullable=False),
        sa.Column("body", sa.Text(), nullable=False),
        sa.Column("is_default", sa.Boolean(), nullable=False, server_default=sa.text("false")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
    )
    op.create_index("ix_templates_user_id", "templates", ["user_id"])

    # ── contacts ──────────────────────────────────────────────────────────────
    op.create_table(
        "contacts",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("first_name", sa.String(255), nullable=False),
        sa.Column("last_name", sa.String(255), nullable=True),
        sa.Column("company", sa.String(255), nullable=True),
        sa.Column("title", sa.String(255), nullable=True),
        sa.Column("emails", postgresql.JSONB(astext_type=sa.Text()), nullable=True, server_default="'[]'"),
        sa.Column("phones", postgresql.JSONB(astext_type=sa.Text()), nullable=True, server_default="'[]'"),
        sa.Column("website", sa.String(500), nullable=True),
        sa.Column("address", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("device_contact_id", sa.String(255), nullable=True),
        sa.Column(
            "source",
            sa.Enum("scan", "manual", "import", name="contact_source_enum", create_constraint=False),
            nullable=False,
            server_default="'manual'",
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
    )
    op.create_index("ix_contacts_user_id", "contacts", ["user_id"])

    # ── events ────────────────────────────────────────────────────────────────
    op.create_table(
        "events",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("location", sa.String(500), nullable=True),
        sa.Column("event_date", sa.Date(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
    )
    op.create_index("ix_events_user_id", "events", ["user_id"])

    # ── interactions ──────────────────────────────────────────────────────────
    op.create_table(
        "interactions",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("contact_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("contacts.id", ondelete="CASCADE"), nullable=False),
        sa.Column("event_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("events.id", ondelete="SET NULL"), nullable=True),
        sa.Column(
            "type",
            sa.Enum("met", "email_sent", "email_failed", "note_added", name="interaction_type_enum", create_constraint=False),
            nullable=False,
        ),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
    )
    op.create_index("ix_interactions_user_id", "interactions", ["user_id"])
    op.create_index("ix_interactions_contact_id", "interactions", ["contact_id"])

    # ── consents ──────────────────────────────────────────────────────────────
    op.create_table(
        "consents",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column(
            "type",
            sa.Enum("email_marketing", "data_processing", "terms_of_service", name="consent_type_enum", create_constraint=False),
            nullable=False,
        ),
        sa.Column(
            "status",
            sa.Enum("granted", "revoked", name="consent_status_enum", create_constraint=False),
            nullable=False,
            server_default="'granted'",
        ),
        sa.Column("version", sa.String(50), nullable=False, server_default="'1.0'"),
        sa.Column("ip_address", sa.String(45), nullable=True),
        sa.Column("user_agent", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
    )
    op.create_index("ix_consents_user_id", "consents", ["user_id"])

    # ── email_jobs ────────────────────────────────────────────────────────────
    op.create_table(
        "email_jobs",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("contact_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("contacts.id", ondelete="CASCADE"), nullable=False),
        sa.Column("template_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("templates.id", ondelete="SET NULL"), nullable=True),
        sa.Column(
            "status",
            sa.Enum("queued", "sent", "failed", name="email_job_status_enum", create_constraint=False),
            nullable=False,
            server_default="'queued'",
        ),
        sa.Column("idempotency_key", sa.String(64), nullable=False),
        sa.Column("provider_message_id", sa.String(255), nullable=True),
        sa.Column("last_error", sa.Text(), nullable=True),
        sa.Column("attempts", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
    )
    op.create_index("ix_email_jobs_user_id", "email_jobs", ["user_id"])
    op.create_index("ix_email_jobs_contact_id", "email_jobs", ["contact_id"])
    op.create_index("ix_email_jobs_status", "email_jobs", ["status"])
    op.create_index("uq_email_jobs_idempotency_key", "email_jobs", ["idempotency_key"], unique=True)

    # ── tags ──────────────────────────────────────────────────────────────────
    op.create_table(
        "tags",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("NOW()"), nullable=False),
        sa.UniqueConstraint("user_id", "name", name="uq_tags_user_name"),
    )
    op.create_index("ix_tags_user_id", "tags", ["user_id"])

    # ── contact_tags (many-to-many) ───────────────────────────────────────────
    op.create_table(
        "contact_tags",
        sa.Column("contact_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("contacts.id", ondelete="CASCADE"), nullable=False),
        sa.Column("tag_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("tags.id", ondelete="CASCADE"), nullable=False),
        sa.PrimaryKeyConstraint("contact_id", "tag_id"),
    )


def downgrade() -> None:
    op.drop_table("contact_tags")
    op.drop_table("tags")
    op.drop_table("email_jobs")
    op.drop_table("consents")
    op.drop_table("interactions")
    op.drop_table("events")
    op.drop_table("contacts")
    op.drop_table("templates")
    op.drop_table("users")

    for ddl in _DROP_ENUM_DDL:
        op.execute(ddl)
