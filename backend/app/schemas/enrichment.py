from typing import Any, Optional

from pydantic import BaseModel


class EnrichRequest(BaseModel):
    # At least one of these should be provided
    email: Optional[str] = None
    linkedin_url: Optional[str] = None
    full_name: Optional[str] = None
    company: Optional[str] = None


class ProfileSuggestion(BaseModel):
    platform: str  # "linkedin", "twitter", "github", etc.
    url: str
    display_name: Optional[str] = None
    headline: Optional[str] = None
    avatar_url: Optional[str] = None
    confidence: float = 0.0


class EnrichResponse(BaseModel):
    # Normalized / enriched fields that can be merged into the contact
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    company: Optional[str] = None
    title: Optional[str] = None
    bio: Optional[str] = None
    location: Optional[str] = None
    website: Optional[str] = None
    profiles: list[ProfileSuggestion] = []
    # Raw provider data for debugging / future use
    raw: Optional[dict[str, Any]] = None
    # Provider name that returned this data
    provider: str = "unknown"
