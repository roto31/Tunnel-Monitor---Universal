from __future__ import annotations

import json
import os
from pathlib import Path
from unittest.mock import MagicMock

import pytest

fastapi = pytest.importorskip("fastapi")
from fastapi.testclient import TestClient  # noqa: E402

from uvpn.interfaces.statusd.app import create_app  # noqa: E402


@pytest.fixture
def token_env(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> str:
    token_file = tmp_path / "status-token"
    token_file.write_text("test-secret-token-value", encoding="utf-8")
    token_file.chmod(0o600)
    monkeypatch.setenv("UVPN_STATUS_TOKEN_FILE", str(token_file))
    monkeypatch.delenv("UVPN_STATUS_TOKEN", raising=False)
    return "test-secret-token-value"


@pytest.fixture
def mock_api() -> MagicMock:
    api = MagicMock()
    api.get_status.return_value = {
        "present": True,
        "schema_version": 1,
        "timestamp": "2026-05-30T12:00:00",
        "vpn_type": "generic",
        "diagnosis": "HEALTHY",
        "traffic_light": "green",
        "alert_state": "UP",
        "failure_count": 0,
        "probes": {},
        "adapter": {"adapter_id": "generic", "raw": {"hidden": True}},
    }
    api.get_diagnostics.return_value = {
        "diagnosis": "HEALTHY",
        "traffic_light": "green",
        "summary": "ok",
        "steps": ["No action"],
        "explain_text": "Diagnosis: HEALTHY",
    }
    return api


def test_health_no_auth(mock_api: MagicMock) -> None:
    client = TestClient(create_app(mock_api))
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_status_requires_auth(mock_api: MagicMock, token_env: str) -> None:
    client = TestClient(create_app(mock_api))
    assert client.get("/api/v1/status").status_code == 401
    r = client.get(
        "/api/v1/status",
        headers={"Authorization": f"Bearer {token_env}"},
    )
    assert r.status_code == 200
    body = r.json()
    assert body["present"] is True
    assert "raw" not in body.get("adapter", {})


def test_post_returns_405(mock_api: MagicMock, token_env: str) -> None:
    client = TestClient(create_app(mock_api))
    r = client.post(
        "/api/v1/status",
        headers={"Authorization": f"Bearer {token_env}"},
    )
    assert r.status_code == 405


def test_diagnostics_auth(mock_api: MagicMock, token_env: str) -> None:
    client = TestClient(create_app(mock_api))
    r = client.get(
        "/api/v1/diagnostics",
        headers={"Authorization": f"Bearer {token_env}"},
    )
    assert r.status_code == 200
    assert r.json()["diagnosis"] == "HEALTHY"


def test_no_token_configured_fails_closed(mock_api: MagicMock, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("UVPN_STATUS_TOKEN", raising=False)
    monkeypatch.delenv("UVPN_STATUS_TOKEN_FILE", raising=False)
    client = TestClient(create_app(mock_api))
    r = client.get(
        "/api/v1/status",
        headers={"Authorization": "Bearer anything"},
    )
    assert r.status_code == 401
