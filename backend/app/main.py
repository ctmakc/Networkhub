from contextlib import asynccontextmanager
from typing import Any

import structlog
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router
from app.config import settings
from app.database import check_db_connection, engine
from app.observability.logging import configure_logging
from app.observability.sentry import init_sentry

logger = structlog.get_logger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # ── Startup ────────────────────────────────────────────────────────────
    configure_logging()
    init_sentry()

    db_ok = await check_db_connection()
    if db_ok:
        logger.info("NetworkHub API starting", environment=settings.ENVIRONMENT, db="ok")
    else:
        logger.warning(
            "NetworkHub API starting with database connection issues",
            environment=settings.ENVIRONMENT,
        )

    yield

    # ── Shutdown ───────────────────────────────────────────────────────────
    await engine.dispose()
    logger.info("NetworkHub API stopped")


app = FastAPI(
    title="NetworkHub API",
    description="MVP API for the NetworkHub networking app",
    version="0.1.0",
    docs_url="/docs" if settings.ENVIRONMENT != "production" else None,
    redoc_url="/redoc" if settings.ENVIRONMENT != "production" else None,
    lifespan=lifespan,
)

# ── Middleware ─────────────────────────────────────────────────────────────────
_allowed_origins = (
    ["*"]
    if settings.ENVIRONMENT == "development"
    else [o.strip() for o in settings.ALLOWED_ORIGINS.split(",") if o.strip()]
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=_allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def security_headers(request: Request, call_next) -> Response:
    response: Response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    if settings.is_production:
        response.headers["Strict-Transport-Security"] = (
            "max-age=63072000; includeSubDomains"
        )
    return response


# ── Routers ────────────────────────────────────────────────────────────────────
app.include_router(api_router, prefix="/api/v1")


# ── System endpoints ───────────────────────────────────────────────────────────
@app.get("/health", tags=["system"], summary="Health check")
async def health_check() -> dict[str, Any]:
    """
    Returns service health.  Includes a DB liveness check so load-balancers
    can route traffic away from instances with broken DB connections.
    """
    db_healthy = await check_db_connection()
    return {
        "status": "ok" if db_healthy else "degraded",
        "environment": settings.ENVIRONMENT,
        "db": "ok" if db_healthy else "unavailable",
    }
