import sentry_sdk
from sentry_sdk.integrations.celery import CeleryIntegration
from sentry_sdk.integrations.fastapi import FastApiIntegration
from sentry_sdk.integrations.sqlalchemy import SqlalchemyIntegration

from app.config import settings


def init_sentry() -> None:
    """Initialize Sentry error tracking if DSN is configured."""
    if not settings.SENTRY_DSN:
        return

    sentry_sdk.init(
        dsn=settings.SENTRY_DSN,
        environment=settings.ENVIRONMENT,
        integrations=[
            FastApiIntegration(transaction_style="endpoint"),
            CeleryIntegration(),
            SqlalchemyIntegration(),
        ],
        traces_sample_rate=0.1 if settings.ENVIRONMENT == "production" else 1.0,
        profiles_sample_rate=0.05 if settings.ENVIRONMENT == "production" else 0.0,
        send_default_pii=False,
    )
