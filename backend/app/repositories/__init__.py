from app.repositories.base import BaseRepository
from app.repositories.contact_repository import ContactRepository
from app.repositories.email_job_repository import EmailJobRepository
from app.repositories.event_repository import EventRepository
from app.repositories.interaction_repository import InteractionRepository
from app.repositories.template_repository import TemplateRepository
from app.repositories.user_repository import UserRepository

__all__ = [
    "BaseRepository",
    "ContactRepository",
    "EmailJobRepository",
    "EventRepository",
    "InteractionRepository",
    "TemplateRepository",
    "UserRepository",
]
