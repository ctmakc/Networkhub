"""Tests for template management and Jinja2 rendering."""

import uuid

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_create_template(client: AsyncClient, auth_headers: dict) -> None:
    payload = {
        "name": "Follow-up",
        "subject": "Great meeting you at {{ event_name }}",
        "body": "Hi {{ contact.first_name }},\n\nGreat meeting you!\n\nBest, {{ user.full_name }}",
        "is_default": True,
    }
    resp = await client.post("/api/v1/templates", json=payload, headers=auth_headers)
    assert resp.status_code == 201, resp.text
    data = resp.json()
    assert data["name"] == "Follow-up"
    assert "{{ event_name }}" in data["subject"]
    assert "id" in data
    assert "user_id" in data


@pytest.mark.asyncio
async def test_list_templates(client: AsyncClient, auth_headers: dict) -> None:
    # Create a template
    await client.post(
        "/api/v1/templates",
        json={"name": "ListTest", "subject": "Subject", "body": "Body text"},
        headers=auth_headers,
    )

    resp = await client.get("/api/v1/templates", headers=auth_headers)
    assert resp.status_code == 200, resp.text
    templates = resp.json()
    assert isinstance(templates, list)
    assert len(templates) >= 1


@pytest.mark.asyncio
async def test_set_default_template(client: AsyncClient, auth_headers: dict) -> None:
    # Create two templates
    r1 = await client.post(
        "/api/v1/templates",
        json={"name": "Template A", "subject": "Subj A", "body": "Body A", "is_default": True},
        headers=auth_headers,
    )
    r1.json()["id"]

    r2 = await client.post(
        "/api/v1/templates",
        json={"name": "Template B", "subject": "Subj B", "body": "Body B"},
        headers=auth_headers,
    )
    t2_id = r2.json()["id"]

    # Set template B as default
    set_resp = await client.post(
        f"/api/v1/templates/{t2_id}/set_default",
        headers=auth_headers,
    )
    assert set_resp.status_code == 200, set_resp.text
    assert set_resp.json()["is_default"] is True

    # Verify only one template is default
    all_templates = await client.get("/api/v1/templates", headers=auth_headers)
    defaults = [t for t in all_templates.json() if t["is_default"]]
    assert len(defaults) == 1
    assert defaults[0]["id"] == t2_id


@pytest.mark.asyncio
async def test_update_template(client: AsyncClient, auth_headers: dict) -> None:
    create_resp = await client.post(
        "/api/v1/templates",
        json={"name": "Old Name", "subject": "Old Subject", "body": "Original Body"},
        headers=auth_headers,
    )
    assert create_resp.status_code == 201, create_resp.text
    tid = create_resp.json()["id"]

    update_resp = await client.patch(
        f"/api/v1/templates/{tid}",
        json={"name": "New Name", "subject": "New Subject"},
        headers=auth_headers,
    )
    assert update_resp.status_code == 200, update_resp.text
    data = update_resp.json()
    assert data["name"] == "New Name"
    assert data["subject"] == "New Subject"
    # Body should remain unchanged
    assert data["body"] == "Original Body"


@pytest.mark.asyncio
async def test_template_not_found(client: AsyncClient, auth_headers: dict) -> None:
    fake_id = str(uuid.uuid4())
    resp = await client.patch(
        f"/api/v1/templates/{fake_id}",
        json={"name": "Ghost"},
        headers=auth_headers,
    )
    assert resp.status_code == 404, resp.text


def test_template_render_service() -> None:
    """Unit test for Jinja2 template rendering in TemplateService."""
    from unittest.mock import MagicMock

    from app.domain.services.template_service import TemplateService
    from app.models.template import Template

    # Build a mock template object
    template = MagicMock(spec=Template)
    template.subject = "Hi {{ contact.first_name }}!"
    template.body = "Hello {{ contact.first_name }} {{ contact.last_name }}, welcome to {{ company }}."

    service = TemplateService(template_repo=MagicMock())  # type: ignore[arg-type]

    contact = MagicMock()
    contact.first_name = "Alice"
    contact.last_name = "Smith"

    subject, body = service.render_template(
        template,
        context={"contact": contact, "company": "Acme Corp"},
    )
    assert subject == "Hi Alice!"
    assert "Alice Smith" in body
    assert "Acme Corp" in body


def test_template_render_raises_on_undefined_variable() -> None:
    """Rendering a template with a missing variable should raise ValueError."""
    from unittest.mock import MagicMock

    from app.domain.services.template_service import TemplateService
    from app.models.template import Template

    template = MagicMock(spec=Template)
    template.subject = "Hello {{ undefined_var }}!"
    template.body = "Body"

    service = TemplateService(template_repo=MagicMock())  # type: ignore[arg-type]

    with pytest.raises(ValueError, match="Template rendering failed"):
        service.render_template(template, context={})
