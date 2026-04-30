import uuid
from typing import Annotated

import structlog
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.database import get_db
from app.models.user import User
from app.repositories.user_repository import UserRepository

logger = structlog.get_logger(__name__)

bearer_scheme = HTTPBearer()


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(bearer_scheme)],
    db: Annotated[AsyncSession, Depends(get_db)],
) -> User:
    """Decode JWT bearer token and return the authenticated user."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    token = credentials.credentials
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id_str: str | None = payload.get("sub")
        if user_id_str is None:
            logger.warning("JWT missing 'sub' claim")
            raise credentials_exception
        user_id = uuid.UUID(user_id_str)
    except JWTError as exc:
        logger.warning("JWT validation failed", error=str(exc))
        raise credentials_exception from exc
    except ValueError as exc:
        logger.warning("JWT 'sub' is not a valid UUID", error=str(exc))
        raise credentials_exception from exc

    repo = UserRepository(db)
    user = await repo.get(user_id)
    if user is None:
        raise credentials_exception
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is disabled",
        )
    return user


CurrentUser = Annotated[User, Depends(get_current_user)]
