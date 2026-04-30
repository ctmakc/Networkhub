"""
OCR provider abstraction.

Used to extract structured contact data from business-card images.
"""
from __future__ import annotations

import abc
import dataclasses
from typing import Optional


@dataclasses.dataclass
class OCRResult:
    raw_text: str
    confidence: float  # 0.0 – 1.0
    # Parsed fields (best-effort; may be empty)
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    company: Optional[str] = None
    title: Optional[str] = None
    emails: list[str] = dataclasses.field(default_factory=list)
    phones: list[str] = dataclasses.field(default_factory=list)
    website: Optional[str] = None


class OCRProvider(abc.ABC):
    """Abstract base class for all OCR providers."""

    @abc.abstractmethod
    async def extract(self, image_bytes: bytes, mime_type: str = "image/jpeg") -> OCRResult:
        """
        Run OCR on the supplied image bytes and return structured data.

        Args:
            image_bytes: Raw image data.
            mime_type: MIME type hint (e.g. "image/png").

        Returns:
            OCRResult with whatever fields could be parsed.
        """
        raise NotImplementedError


class StubOCRProvider(OCRProvider):
    """
    No-op OCR provider used in development / testing.
    Returns an empty result so the rest of the pipeline still executes.
    """

    async def extract(self, image_bytes: bytes, mime_type: str = "image/jpeg") -> OCRResult:
        return OCRResult(
            raw_text="",
            confidence=0.0,
        )


def get_default_provider() -> OCRProvider:
    """Factory: return the active OCR provider."""
    # Replace StubOCRProvider with a real implementation (e.g. Google Vision)
    # when available.
    return StubOCRProvider()
