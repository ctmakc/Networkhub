"""
Enrichment provider abstraction.

Enrichment providers take partial contact information and attempt to fill in
missing fields (title, company, social profiles, etc.).
"""
from __future__ import annotations

import abc

from app.schemas.enrichment import EnrichRequest, EnrichResponse, ProfileSuggestion


class EnrichmentProvider(abc.ABC):
    """Abstract base class for all enrichment providers."""

    @abc.abstractmethod
    async def enrich(self, request: EnrichRequest) -> EnrichResponse:
        """
        Attempt to enrich the supplied partial contact data.

        Returns an EnrichResponse; unknown / unavailable fields are None.
        """
        raise NotImplementedError


class PythonNormalizeProvider(EnrichmentProvider):
    """
    Local normalisation provider.

    Does not call any external API; instead it normalises and cleans the
    data that was already supplied.  This ensures the pipeline always has
    a usable baseline provider even without API keys.
    """

    async def enrich(self, request: EnrichRequest) -> EnrichResponse:
        first_name: str | None = None
        last_name: str | None = None

        if request.full_name:
            parts = request.full_name.strip().split(maxsplit=1)
            first_name = parts[0] if parts else None
            last_name = parts[1] if len(parts) > 1 else None

        # Attempt to derive a LinkedIn search URL as a "suggestion"
        profiles: list[ProfileSuggestion] = []
        if request.full_name or (first_name and last_name):
            name_query = (request.full_name or f"{first_name} {last_name}").strip()
            search_url = (
                f"https://www.linkedin.com/search/results/people/"
                f"?keywords={name_query.replace(' ', '+')}"
            )
            if request.company:
                search_url += f"+{request.company.replace(' ', '+')}"

            profiles.append(
                ProfileSuggestion(
                    platform="linkedin",
                    url=search_url,
                    display_name=name_query,
                    confidence=0.3,  # low confidence – it's only a search link
                )
            )

        return EnrichResponse(
            first_name=first_name,
            last_name=last_name,
            company=request.company,
            profiles=profiles,
            provider="python_normalize",
        )


def get_default_provider() -> EnrichmentProvider:
    """Factory: return the active enrichment provider."""
    return PythonNormalizeProvider()
