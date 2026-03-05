"""Tests for the contacts CRUD API endpoints."""

import uuid

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_create_contact(client: AsyncClient, auth_headers: dict) -> None:
    payload = {
        "first_name": "Jane",
        "last_name": "Doe",
        "company": "Acme Corp",
        "emails": [{"value": "jane@acme.com", "label": "work"}],
        "phones": [{"value": "+15551234567", "label": "work"}],
        "source": "scan",
    }
    response = await client.post("/api/v1/contacts", json=payload, headers=auth_headers)
    assert response.status_code == 201, response.text
    data = response.json()
    assert data["first_name"] == "Jane"
    assert data["last_name"] == "Doe"
    assert data["company"] == "Acme Corp"
    assert "id" in data


@pytest.mark.asyncio
async def test_list_contacts_returns_paginated_response(
    client: AsyncClient, auth_headers: dict
) -> None:
    response = await client.get("/api/v1/contacts", headers=auth_headers)
    assert response.status_code == 200, response.text
    data = response.json()
    assert "items" in data
    assert "total" in data
    assert "page" in data
    assert "page_size" in data
    assert "has_more" in data


@pytest.mark.asyncio
async def test_get_contact_by_id(client: AsyncClient, auth_headers: dict) -> None:
    create_resp = await client.post(
        "/api/v1/contacts",
        json={
            "first_name": "Alice",
            "emails": [{"value": "alice@example.com", "label": "work"}],
            "source": "manual",
        },
        headers=auth_headers,
    )
    assert create_resp.status_code == 201, create_resp.text
    contact_id = create_resp.json()["id"]

    get_resp = await client.get(f"/api/v1/contacts/{contact_id}", headers=auth_headers)
    assert get_resp.status_code == 200, get_resp.text
    assert get_resp.json()["id"] == contact_id
    assert get_resp.json()["first_name"] == "Alice"


@pytest.mark.asyncio
async def test_update_contact(client: AsyncClient, auth_headers: dict) -> None:
    create_resp = await client.post(
        "/api/v1/contacts",
        json={"first_name": "Bob", "source": "manual"},
        headers=auth_headers,
    )
    assert create_resp.status_code == 201, create_resp.text
    contact_id = create_resp.json()["id"]

    update_resp = await client.patch(
        f"/api/v1/contacts/{contact_id}",
        json={"company": "Updated Corp", "title": "Senior Engineer"},
        headers=auth_headers,
    )
    assert update_resp.status_code == 200, update_resp.text
    data = update_resp.json()
    assert data["company"] == "Updated Corp"
    assert data["title"] == "Senior Engineer"


@pytest.mark.asyncio
async def test_search_contacts(client: AsyncClient, auth_headers: dict) -> None:
    unique_name = f"Searchable{uuid.uuid4().hex[:6]}"
    await client.post(
        "/api/v1/contacts",
        json={"first_name": unique_name, "company": "SearchCorp", "source": "manual"},
        headers=auth_headers,
    )

    resp = await client.get(f"/api/v1/contacts?q={unique_name}", headers=auth_headers)
    assert resp.status_code == 200, resp.text
    items = resp.json()["items"]
    assert any(unique_name in c["first_name"] for c in items)


@pytest.mark.asyncio
async def test_send_email_no_email_address(
    client: AsyncClient, auth_headers: dict
) -> None:
    """Queuing email for a contact with no email address should return 422."""
    create_resp = await client.post(
        "/api/v1/contacts",
        json={"first_name": "NoEmail", "source": "manual"},
        headers=auth_headers,
    )
    assert create_resp.status_code == 201, create_resp.text
    contact_id = create_resp.json()["id"]

    resp = await client.post(
        f"/api/v1/contacts/{contact_id}/send_email",
        json={"subject": "Hello", "body": "World"},
        headers=auth_headers,
    )
    # No email address on contact → 422 Unprocessable Entity
    assert resp.status_code == 422, resp.text


@pytest.mark.asyncio
async def test_contact_not_found(client: AsyncClient, auth_headers: dict) -> None:
    fake_id = str(uuid.uuid4())
    resp = await client.get(f"/api/v1/contacts/{fake_id}", headers=auth_headers)
    assert resp.status_code == 404, resp.text


@pytest.mark.asyncio
async def test_unauthenticated_request_rejected(client: AsyncClient) -> None:
    resp = await client.get("/api/v1/contacts")
    assert resp.status_code == 403
