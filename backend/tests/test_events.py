"""Tests for the events CRUD API endpoints."""

import uuid

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_create_event(client: AsyncClient, auth_headers: dict) -> None:
    payload = {
        "name": "Tech Conference 2025",
        "location": "San Francisco",
        "event_date": "2025-06-15",
    }
    response = await client.post("/api/v1/events", json=payload, headers=auth_headers)
    assert response.status_code == 201, response.text
    data = response.json()
    assert data["name"] == "Tech Conference 2025"
    assert data["location"] == "San Francisco"
    assert data["event_date"] == "2025-06-15"
    assert "id" in data


@pytest.mark.asyncio
async def test_list_events(client: AsyncClient, auth_headers: dict) -> None:
    # Create two events
    for name in ["Event A", "Event B"]:
        await client.post(
            "/api/v1/events",
            json={"name": name, "event_date": "2025-06-15"},
            headers=auth_headers,
        )

    response = await client.get("/api/v1/events", headers=auth_headers)
    assert response.status_code == 200, response.text
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 2


@pytest.mark.asyncio
async def test_get_event_by_id(client: AsyncClient, auth_headers: dict) -> None:
    create_resp = await client.post(
        "/api/v1/events",
        json={"name": "Meetup", "event_date": "2025-07-01"},
        headers=auth_headers,
    )
    assert create_resp.status_code == 201, create_resp.text
    event_id = create_resp.json()["id"]

    get_resp = await client.get(f"/api/v1/events/{event_id}", headers=auth_headers)
    assert get_resp.status_code == 200, get_resp.text
    assert get_resp.json()["id"] == event_id
    assert get_resp.json()["name"] == "Meetup"


@pytest.mark.asyncio
async def test_update_event(client: AsyncClient, auth_headers: dict) -> None:
    create_resp = await client.post(
        "/api/v1/events",
        json={"name": "Old Name", "event_date": "2025-08-01"},
        headers=auth_headers,
    )
    assert create_resp.status_code == 201, create_resp.text
    event_id = create_resp.json()["id"]

    update_resp = await client.patch(
        f"/api/v1/events/{event_id}",
        json={"name": "New Name", "location": "New York"},
        headers=auth_headers,
    )
    assert update_resp.status_code == 200, update_resp.text
    data = update_resp.json()
    assert data["name"] == "New Name"
    assert data["location"] == "New York"


@pytest.mark.asyncio
async def test_delete_event(client: AsyncClient, auth_headers: dict) -> None:
    create_resp = await client.post(
        "/api/v1/events",
        json={"name": "To Delete", "event_date": "2025-09-01"},
        headers=auth_headers,
    )
    assert create_resp.status_code == 201, create_resp.text
    event_id = create_resp.json()["id"]

    delete_resp = await client.delete(
        f"/api/v1/events/{event_id}", headers=auth_headers
    )
    assert delete_resp.status_code == 204, delete_resp.text

    # Verify it's gone
    get_resp = await client.get(f"/api/v1/events/{event_id}", headers=auth_headers)
    assert get_resp.status_code == 404


@pytest.mark.asyncio
async def test_event_not_found(client: AsyncClient, auth_headers: dict) -> None:
    fake_id = str(uuid.uuid4())
    resp = await client.get(f"/api/v1/events/{fake_id}", headers=auth_headers)
    assert resp.status_code == 404, resp.text


@pytest.mark.asyncio
async def test_unauthenticated_request_rejected(client: AsyncClient) -> None:
    resp = await client.get("/api/v1/events")
    assert resp.status_code == 403
