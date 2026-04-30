import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import CurrentUser
from app.database import get_db
from app.repositories.email_job_repository import EmailJobRepository
from app.schemas.email_job import EmailJobResponse

router = APIRouter(prefix="/jobs", tags=["jobs"])


@router.get("/{job_id}", response_model=EmailJobResponse)
async def get_job(
    job_id: uuid.UUID,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> EmailJobResponse:
    repo = EmailJobRepository(db)
    job = await repo.get(job_id)
    if job is None or job.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job not found")
    return EmailJobResponse.model_validate(job)
