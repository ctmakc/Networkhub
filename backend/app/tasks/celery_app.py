"""
Celery application factory.

Import `celery_app` wherever you need to define or dispatch tasks:

    from app.tasks.celery_app import celery_app
"""
from celery import Celery

from app.config import settings


def create_celery_app() -> Celery:
    app = Celery("networkhub")

    app.conf.update(
        broker_url=settings.CELERY_BROKER_URL,
        result_backend=settings.CELERY_RESULT_BACKEND,
        # Serialisation
        task_serializer="json",
        result_serializer="json",
        accept_content=["json"],
        # Timezone
        timezone="UTC",
        enable_utc=True,
        # Retry / reliability
        task_acks_late=True,
        task_reject_on_worker_lost=True,
        # Result TTL (keep results for 1 hour)
        result_expires=3600,
        # Auto-discover tasks from app.tasks.*
        include=[
            "app.tasks.email_tasks",
            "app.tasks.enrichment_tasks",
            "app.tasks.dedupe_tasks",
        ],
    )

    return app


celery_app: Celery = create_celery_app()
