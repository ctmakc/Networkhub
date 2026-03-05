import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import CurrentUser
from app.database import get_db
from app.domain.services.template_service import TemplateService
from app.repositories.template_repository import TemplateRepository
from app.schemas.template import TemplateCreate, TemplateResponse, TemplateUpdate

router = APIRouter(prefix="/templates", tags=["templates"])


def _get_template_service(db: AsyncSession) -> TemplateService:
    return TemplateService(TemplateRepository(db))


@router.get("", response_model=list[TemplateResponse])
async def list_templates(
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> list[TemplateResponse]:
    service = _get_template_service(db)
    templates = await service.list_for_user(current_user.id)
    return [TemplateResponse.model_validate(t) for t in templates]


@router.post("", response_model=TemplateResponse, status_code=status.HTTP_201_CREATED)
async def create_template(
    payload: TemplateCreate,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> TemplateResponse:
    service = _get_template_service(db)
    template = await service.create(user_id=current_user.id, data=payload)
    return TemplateResponse.model_validate(template)


@router.patch("/{template_id}", response_model=TemplateResponse)
async def update_template(
    template_id: uuid.UUID,
    payload: TemplateUpdate,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> TemplateResponse:
    service = _get_template_service(db)
    template = await service.update(
        user_id=current_user.id, template_id=template_id, data=payload
    )
    if template is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Template not found")
    return TemplateResponse.model_validate(template)


@router.post("/{template_id}/set_default", response_model=TemplateResponse)
async def set_default_template(
    template_id: uuid.UUID,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> TemplateResponse:
    service = _get_template_service(db)
    template = await service.set_default(user_id=current_user.id, template_id=template_id)
    if template is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Template not found")
    return TemplateResponse.model_validate(template)
