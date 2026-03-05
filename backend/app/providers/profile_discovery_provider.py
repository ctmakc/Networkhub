"""
Profile discovery provider abstraction.

Profile discovery takes a contact and returns a list of probable social
profile URLs / suggestions from public sources.
"""
from __future__ import annotations

import abc
from typing import Optional

from app.schemas.enrichment import ProfileSuggestion


class ProfileDiscoveryProvider(abc.ABC):
    """Abstract base class for all profile discovery providers."""

    @abc.abstractmethod
    async def discover(
        self,
        full_name: Optional[str] = None,
        company: Optional[str] = None,
        email: Optional[str] = None,
    ) -> list[ProfileSuggestion]:
        """
        Attempt to find social / professional profiles for the given person.

        Returns a (possibly empty) list of ProfileSuggestion objects.
        """
        raise NotImplementedError


class StubProfileDiscoveryProvider(ProfileDiscoveryProvider):
    """
    No-op provider used in development / testing.
    Always returns an empty list so the pipeline completes without errors.
    """

    async def discover(
        self,
        full_name: Optional[str] = None,
        company: Optional[str] = None,
        email: Optional[str] = None,
    ) -> list[ProfileSuggestion]:
        return []


def get_default_provider() -> ProfileDiscoveryProvider:
    """Factory: return the active profile discovery provider."""
    return StubProfileDiscoveryProvider()
