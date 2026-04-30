from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import CurrentUser
from app.database import get_db
from app.domain.services.auth_service import AuthService
from app.repositories.user_repository import UserRepository
from app.schemas.user import MagicLinkRequest, MagicLinkVerify, TokenResponse, UserResponse

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/request_magic_link", status_code=status.HTTP_202_ACCEPTED)
async def request_magic_link(
    payload: MagicLinkRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> dict:
    """
    Send a magic link to the given email address.
    Creates the user if they don't exist yet.
    Always returns 202 to avoid email enumeration.
    """
    user_repo = UserRepository(db)
    auth_service = AuthService(user_repo)
    await auth_service.create_magic_link(payload.email)
    return {"detail": "If that address is registered, a magic link has been sent."}


@router.post("/verify_magic_link", response_model=TokenResponse)
async def verify_magic_link(
    payload: MagicLinkVerify,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> TokenResponse:
    """
    Exchange a one-time magic-link token for a JWT access token.
    """
    user_repo = UserRepository(db)
    auth_service = AuthService(user_repo)

    user = await auth_service.verify_magic_link(payload.token)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired magic link token",
        )

    token_data = auth_service.create_access_token(user)
    return TokenResponse(
        access_token=token_data["access_token"],
        token_type="bearer",
        expires_in=token_data["expires_in"],
        user=UserResponse.model_validate(user),
    )


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: CurrentUser) -> UserResponse:
    """Return the currently authenticated user's profile."""
    return UserResponse.model_validate(current_user)
