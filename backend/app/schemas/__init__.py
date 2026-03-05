from app.schemas.contact import ContactCreate, ContactList, ContactResponse, ContactUpdate, DraftContact
from app.schemas.email_job import EmailJobResponse, SendEmailRequest
from app.schemas.enrichment import EnrichRequest, EnrichResponse, ProfileSuggestion
from app.schemas.event import EventCreate, EventResponse
from app.schemas.interaction import InteractionResponse
from app.schemas.template import TemplateCreate, TemplateResponse, TemplateUpdate
from app.schemas.user import MagicLinkRequest, MagicLinkVerify, TokenResponse, UserCreate, UserResponse

__all__ = [
    "UserCreate",
    "UserResponse",
    "MagicLinkRequest",
    "MagicLinkVerify",
    "TokenResponse",
    "ContactCreate",
    "ContactUpdate",
    "ContactResponse",
    "ContactList",
    "DraftContact",
    "EventCreate",
    "EventResponse",
    "TemplateCreate",
    "TemplateUpdate",
    "TemplateResponse",
    "SendEmailRequest",
    "EmailJobResponse",
    "InteractionResponse",
    "EnrichRequest",
    "EnrichResponse",
    "ProfileSuggestion",
]
