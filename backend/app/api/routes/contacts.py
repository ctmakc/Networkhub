import uuid
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import CurrentUser
from app.database import get_db
from app.domain.services.contact_service import ContactService
from app.domain.services.email_service import EmailService
from app.repositories.contact_repository import ContactRepository
from app.repositories.email_job_repository import EmailJobRepository
from app.repositories.interaction_repository import InteractionRepository
from app.repositories.template_repository import TemplateRepository
from app.schemas.contact import ContactCreate, ContactList, ContactResponse, ContactUpdate
from app.schemas.email_job import EmailJobResponse, SendEmailRequest
from app.schemas.enrichment import EnrichRequest, EnrichResponse

router = APIRouter(prefix="/contacts", tags=["contacts"])


def _get_contact_service(db: AsyncSession) -> ContactService:
    return ContactService(
        contact_repo=ContactRepository(db),
        interaction_repo=InteractionRepository(db),
    )


@router.post("", response_model=ContactResponse, status_code=status.HTTP_201_CREATED)
async def create_contact(
    payload: ContactCreate,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> ContactResponse:
    service = _get_contact_service(db)
    contact = await service.create(user_id=current_user.id, data=payload)
    return ContactResponse.model_validate(contact)


@router.get("", response_model=ContactList)
async def list_contacts(
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
    q: Optional[str] = Query(None, description="Search term (name, email, company)"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
) -> ContactList:
    service = _get_contact_service(db)
    items, total = await service.list(
        user_id=current_user.id,
        search=q,
        page=page,
        page_size=page_size,
    )
    return ContactList(
        items=[ContactResponse.model_validate(c) for c in items],
        total=total,
        page=page,
        page_size=page_size,
        has_more=(page * page_size) < total,
    )


@router.get("/{contact_id}", response_model=ContactResponse)
async def get_contact(
    contact_id: uuid.UUID,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> ContactResponse:
    service = _get_contact_service(db)
    contact = await service.get(user_id=current_user.id, contact_id=contact_id)
    if contact is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Contact not found")
    return ContactResponse.model_validate(contact)


@router.patch("/{contact_id}", response_model=ContactResponse)
async def update_contact(
    contact_id: uuid.UUID,
    payload: ContactUpdate,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> ContactResponse:
    service = _get_contact_service(db)
    contact = await service.update(
        user_id=current_user.id, contact_id=contact_id, data=payload
    )
    if contact is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Contact not found")
    return ContactResponse.model_validate(contact)


@router.post("/{contact_id}/send_email", response_model=EmailJobResponse, status_code=status.HTTP_202_ACCEPTED)
async def send_email_to_contact(
    contact_id: uuid.UUID,
    payload: SendEmailRequest,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> EmailJobResponse:
    contact_service = _get_contact_service(db)
    contact = await contact_service.get(user_id=current_user.id, contact_id=contact_id)
    if contact is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Contact not found")

    email_service = EmailService(
        email_job_repo=EmailJobRepository(db),
        template_repo=TemplateRepository(db),
        interaction_repo=InteractionRepository(db),
    )

    try:
        job = await email_service.queue_email(
            user=current_user,
            contact=contact,
            template_id=payload.template_id,
            subject_override=payload.subject,
            body_override=payload.body,
            recipient_email=payload.recipient_email,
        )
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(exc))

    return EmailJobResponse.model_validate(job)


@router.post("/{contact_id}/discover_profiles", response_model=EnrichResponse)
async def discover_profiles(
    contact_id: uuid.UUID,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> EnrichResponse:
    from app.providers.enrichment_provider import PythonNormalizeProvider

    contact_service = _get_contact_service(db)
    contact = await contact_service.get(user_id=current_user.id, contact_id=contact_id)
    if contact is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Contact not found")

    provider = PythonNormalizeProvider()
    primary_email = None
    if contact.emails:
        primary_email = contact.emails[0].get("value") if isinstance(contact.emails[0], dict) else contact.emails[0]

    result = await provider.enrich(
        EnrichRequest(
            email=primary_email,
            full_name=f"{contact.first_name} {contact.last_name or ''}".strip(),
            company=contact.company,
        )
    )
    return result
