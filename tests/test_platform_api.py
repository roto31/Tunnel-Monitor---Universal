from __future__ import annotations

from uvpn.api.platform import MonitorAPI
from uvpn.core.models import Diagnosis


def test_full_view_without_state(tmp_path, monkeypatch) -> None:
    monkeypatch.setenv("UVPN_CONFIG_DIR", str(tmp_path))
    api = MonitorAPI()
    view = api.full_view()
    assert view.status.get("present") is False
    assert view.statistics.get("available") is False
    assert view.diagnostics["diagnosis"] == "UNKNOWN"


def test_run_check_writes_state(tmp_path, monkeypatch) -> None:
    monkeypatch.setenv("UVPN_CONFIG_DIR", str(tmp_path))
    from uvpn.core.config import MonitorConfig

    cfg = MonitorConfig(
        vpn_type="generic",
        remote_lan_ip="127.0.0.1",
        remote_wan_ip="127.0.0.1",
    )
    cfg.save(tmp_path / "config.json")
    api = MonitorAPI(cfg)
    snap = api.run_check()
    assert snap.schema_version >= 1
    assert snap.diagnosis in Diagnosis
    status = api.get_status()
    assert status.get("present") is True
    assert "statistics" in status or snap.statistics is not None
