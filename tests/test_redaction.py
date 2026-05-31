from __future__ import annotations

from uvpn.security.redaction import mask_ip, to_public_diagnostics, to_public_status


def test_mask_ip_replaces_ipv4() -> None:
    assert mask_ip("Reach 192.168.1.1 now", True) == "Reach x.x.x.x now"
    assert mask_ip("192.168.1.1", False) == "192.168.1.1"


def test_to_public_status_strips_raw_and_logs() -> None:
    raw = {
        "present": True,
        "schema_version": 1,
        "timestamp": "2026-01-01T00:00:00",
        "vpn_type": "generic",
        "diagnosis": "HEALTHY",
        "traffic_light": "green",
        "alert_state": "UP",
        "failure_count": 0,
        "probes": {"lan": {"target": "10.0.0.1", "ok": True, "latency_ms": 1.0}},
        "adapter": {
            "adapter_id": "generic",
            "vpn_type": "generic",
            "supported": True,
            "connected": True,
            "detail": "ok",
            "raw": {"secret": "cli_stdout"},
        },
        "logs": ["line with token"],
    }
    dto = to_public_status(raw, mask_ips=True)
    d = dto.to_dict()
    assert "raw" not in d["adapter"]
    assert "logs" not in d
    assert d["probes"]["lan"]["target"] == "x.x.x.x"


def test_to_public_status_absent() -> None:
    dto = to_public_status({"present": False, "message": "No state file."})
    assert dto.to_dict() == {"present": False, "message": "No state file."}


def test_to_public_diagnostics_masks_steps() -> None:
    raw = {
        "diagnosis": "TUNNEL_DOWN",
        "traffic_light": "red",
        "summary": "Probe 203.0.113.1 failed",
        "steps": ["Check 203.0.113.1"],
        "explain_text": "",
    }
    dto = to_public_diagnostics(raw, mask_ips=True)
    assert "203.0.113.1" not in dto.summary
    assert "203.0.113.1" not in dto.steps[0]
