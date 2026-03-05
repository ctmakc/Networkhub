from functools import lru_cache
from typing import Optional

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/networkhub"

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # Security
    SECRET_KEY: str = "change-me-in-production-use-32-chars-min"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    MAGIC_LINK_EXPIRE_MINUTES: int = 15

    # Email (SendGrid)
    SENDGRID_API_KEY: str = "SG.placeholder"
    EMAIL_FROM: str = "noreply@networkhub.app"
    EMAIL_FROM_NAME: str = "NetworkHub"

    # Observability
    SENTRY_DSN: Optional[str] = None
    ENVIRONMENT: str = "development"

    # Business rules
    EMAIL_DAILY_LIMIT: int = 20

    # Celery (derived from Redis by default)
    CELERY_BROKER_URL: Optional[str] = None
    CELERY_RESULT_BACKEND: Optional[str] = None

    @field_validator("CELERY_BROKER_URL", mode="before")
    @classmethod
    def set_celery_broker(cls, v: Optional[str], info) -> str:
        if v:
            return v
        # Fall back to REDIS_URL from the data dict if available
        return info.data.get("REDIS_URL", "redis://localhost:6379/0")

    @field_validator("CELERY_RESULT_BACKEND", mode="before")
    @classmethod
    def set_celery_result_backend(cls, v: Optional[str], info) -> str:
        if v:
            return v
        return info.data.get("REDIS_URL", "redis://localhost:6379/0")

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT == "production"

    @property
    def is_testing(self) -> bool:
        return self.ENVIRONMENT == "test"


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
