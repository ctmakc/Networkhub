"""Tests for authentication flow (magic link + JWT)."""

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_request_magic_link_returns_202(client: AsyncClient) -> None:
    """Magic link endpoint always returns 202 to avoid email enumeration."""
    resp = await client.post(
        "/api/v1/auth/request_magic_link",
        json={"email": "anyemail@example.com"},
    )
    assert resp.status_code == 202, resp.text
    assert "detail" in resp.json()


@pytest.mark.asyncio
async def test_verify_invalid_token_returns_401(client: AsyncClient) -> None:
    """Submitting a bogus token should return 401 Unauthorized."""
    resp = await client.post(
        "/api/v1/auth/verify_magic_link",
        json={"token": "this_is_not_a_valid_token_xyz_abc"},
    )
    assert resp.status_code == 401, resp.text


@pytest.mark.asyncio
async def test_get_me_without_auth_returns_403(client: AsyncClient) -> None:
    """Accessing /me without a bearer token should return 403."""
    resp = await client.get("/api/v1/auth/me")
    assert resp.status_code == 403, resp.text


@pytest.mark.asyncio
async def test_get_me_with_valid_auth(client: AsyncClient, auth_headers: dict) -> None:
    """Accessing /me with a valid bearer token should return the user's profile."""
    resp = await client.get("/api/v1/auth/me", headers=auth_headers)
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["email"] == "test@example.com"
    assert "id" in data
    assert "is_active" in data


@pytest.mark.asyncio
async def test_health_check(client: AsyncClient) -> None:
    """Health check endpoint should return 200 without authentication."""
    resp = await client.get("/health")
    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "ok"
