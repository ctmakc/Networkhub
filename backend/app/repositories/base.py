import uuid
from typing import Any, Generic, Optional, Sequence, Type, TypeVar

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import Base

ModelT = TypeVar("ModelT", bound=Base)


class BaseRepository(Generic[ModelT]):
    """Generic async repository providing basic CRUD operations."""

    model: Type[ModelT]

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get(self, id: uuid.UUID) -> Optional[ModelT]:
        """Fetch a single record by primary key."""
        result = await self.db.execute(select(self.model).where(self.model.id == id))
        return result.scalar_one_or_none()

    async def list(
        self,
        *,
        limit: int = 100,
        offset: int = 0,
        **filters: Any,
    ) -> Sequence[ModelT]:
        """List records with optional equality filters."""
        stmt = select(self.model)
        for field, value in filters.items():
            stmt = stmt.where(getattr(self.model, field) == value)
        stmt = stmt.offset(offset).limit(limit)
        result = await self.db.execute(stmt)
        return result.scalars().all()

    async def create(self, instance: ModelT) -> ModelT:
        """Persist a new model instance."""
        self.db.add(instance)
        await self.db.flush()
        await self.db.refresh(instance)
        return instance

    async def update(self, instance: ModelT, **kwargs: Any) -> ModelT:
        """Update fields on an existing model instance."""
        for key, value in kwargs.items():
            setattr(instance, key, value)
        self.db.add(instance)
        await self.db.flush()
        await self.db.refresh(instance)
        return instance

    async def delete(self, instance: ModelT) -> None:
        """Delete a model instance."""
        self.db.delete(instance)  # sync – no await
        await self.db.flush()
