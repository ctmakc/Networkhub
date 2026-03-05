import uuid
from typing import Any, Optional, Sequence

from jinja2 import Environment, StrictUndefined, TemplateError

from app.models.template import Template
from app.repositories.template_repository import TemplateRepository
from app.schemas.template import TemplateCreate, TemplateUpdate

# Shared Jinja2 environment – StrictUndefined surfaces typos in templates early
_jinja_env = Environment(undefined=StrictUndefined, autoescape=False)


class TemplateService:
    def __init__(self, template_repo: TemplateRepository) -> None:
        self.repo = template_repo

    async def list_for_user(self, user_id: uuid.UUID) -> Sequence[Template]:
        return await self.repo.list_for_user(user_id)

    async def create(self, user_id: uuid.UUID, data: TemplateCreate) -> Template:
        # If this should be the default, clear existing defaults first
        if data.is_default:
            await self.repo.clear_default_for_user(user_id)

        template = Template(
            user_id=user_id,
            name=data.name,
            subject=data.subject,
            body=data.body,
            is_default=data.is_default,
        )
        return await self.repo.create(template)

    async def update(
        self,
        user_id: uuid.UUID,
        template_id: uuid.UUID,
        data: TemplateUpdate,
    ) -> Optional[Template]:
        template = await self.repo.get(template_id)
        if template is None or template.user_id != user_id:
            return None

        update_fields: dict = {}
        if data.name is not None:
            update_fields["name"] = data.name
        if data.subject is not None:
            update_fields["subject"] = data.subject
        if data.body is not None:
            update_fields["body"] = data.body
        if data.is_default is not None:
            if data.is_default:
                await self.repo.clear_default_for_user(user_id)
            update_fields["is_default"] = data.is_default

        if update_fields:
            template = await self.repo.update(template, **update_fields)

        return template

    async def set_default(
        self, user_id: uuid.UUID, template_id: uuid.UUID
    ) -> Optional[Template]:
        template = await self.repo.get(template_id)
        if template is None or template.user_id != user_id:
            return None

        await self.repo.clear_default_for_user(user_id)
        return await self.repo.update(template, is_default=True)

    async def get_default(self, user_id: uuid.UUID) -> Optional[Template]:
        return await self.repo.get_default_for_user(user_id)

    def render_template(
        self,
        template: Template,
        context: dict[str, Any],
    ) -> tuple[str, str]:
        """
        Render the template subject and body using Jinja2.

        Args:
            template: The Template ORM object.
            context: Variables available inside the template (contact, user, event, …).

        Returns:
            (rendered_subject, rendered_body) tuple.

        Raises:
            TemplateError: If the template contains syntax errors or undefined variables.
        """
        try:
            subject = _jinja_env.from_string(template.subject).render(**context)
            body = _jinja_env.from_string(template.body).render(**context)
        except TemplateError as exc:
            raise ValueError(f"Template rendering failed: {exc}") from exc

        return subject, body

    def render_inline(
        self,
        subject_tpl: str,
        body_tpl: str,
        context: dict[str, Any],
    ) -> tuple[str, str]:
        """Render an ad-hoc subject/body pair without a persisted Template record."""
        try:
            subject = _jinja_env.from_string(subject_tpl).render(**context)
            body = _jinja_env.from_string(body_tpl).render(**context)
        except TemplateError as exc:
            raise ValueError(f"Template rendering failed: {exc}") from exc

        return subject, body
