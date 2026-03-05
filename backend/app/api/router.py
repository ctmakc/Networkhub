from fastapi import APIRouter

from app.api.routes.auth import router as auth_router
from app.api.routes.contacts import router as contacts_router
from app.api.routes.events import router as events_router
from app.api.routes.jobs import router as jobs_router
from app.api.routes.templates import router as templates_router

api_router = APIRouter()

api_router.include_router(auth_router)
api_router.include_router(contacts_router)
api_router.include_router(events_router)
api_router.include_router(templates_router)
api_router.include_router(jobs_router)
