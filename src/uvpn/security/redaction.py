from __future__ import annotations

import re
from dataclasses import dataclass, field
from typing import Any

_IPV4_RE = re.compile(
    r"\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}"
    r"(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
)


def mask_ip(value: str, enabled: bool = True) -> str:
    if not enabled or not value:
        return value
    return _IPV4_RE.sub("x.x.x.x", value)


def _redact_probe(probe: dict[str, Any], mask_ips: bool) -> dict[str, Any]:
    target = str(probe.get("target", ""))
    return {
        "ok": probe.get("ok"),
        "latency_ms": probe.get("latency_ms"),
        "target": mask_ip(target, mask_ips) if target else "",
    }


def _redact_adapter(adapter: dict[str, Any]) -> dict[str, Any]:
    return {
        "adapter_id": adapter.get("adapter_id"),
        "vpn_type": adapter.get("vpn_type"),
        "supported": adapter.get("supported"),
        "connected": adapter.get("connected"),
        "detail": adapter.get("detail", ""),
    }


@dataclass
class PublicStatusDTO:
    present: bool
    schema_version: int | None = None
    timestamp: str | None = None
    vpn_type: str | None = None
    diagnosis: str | None = None
    traffic_light: str | None = None
    alert_state: str | None = None
    failure_count: int | None = None
    probes: dict[str, Any] = field(default_factory=dict)
    adapter: dict[str, Any] = field(default_factory=dict)
    message: str | None = None

    def to_dict(self) -> dict[str, Any]:
        out: dict[str, Any] = {"present": self.present}
        if not self.present:
            if self.message:
                out["message"] = self.message
            return out
        for key in (
            "schema_version",
            "timestamp",
            "vpn_type",
            "diagnosis",
            "traffic_light",
            "alert_state",
            "failure_count",
            "probes",
            "adapter",
        ):
            val = getattr(self, key)
            if val is not None:
                out[key] = val
        return out


@dataclass
class PublicDiagnosticsDTO:
    diagnosis: str
    traffic_light: str | None = None
    summary: str = ""
    steps: list[str] = field(default_factory=list)
    explain_text: str = ""

    def to_dict(self) -> dict[str, Any]:
        return {
            "diagnosis": self.diagnosis,
            "traffic_light": self.traffic_light,
            "summary": self.summary,
            "steps": self.steps,
            "explain_text": self.explain_text,
        }


def to_public_status(
    raw: dict[str, Any],
    *,
    mask_ips: bool = False,
) -> PublicStatusDTO:
    if not raw.get("present", True) and raw.get("message"):
        return PublicStatusDTO(present=False, message=str(raw.get("message", "")))
    if not raw:
        return PublicStatusDTO(present=False, message="No monitoring data.")

    probes_in = raw.get("probes") or {}
    probes_out = {
        k: _redact_probe(v, mask_ips) if isinstance(v, dict) else v
        for k, v in probes_in.items()
    }
    adapter_in = raw.get("adapter") or {}
    adapter_out = _redact_adapter(adapter_in) if isinstance(adapter_in, dict) else {}

    return PublicStatusDTO(
        present=True,
        schema_version=raw.get("schema_version"),
        timestamp=raw.get("timestamp"),
        vpn_type=raw.get("vpn_type"),
        diagnosis=raw.get("diagnosis"),
        traffic_light=raw.get("traffic_light"),
        alert_state=raw.get("alert_state"),
        failure_count=raw.get("failure_count"),
        probes=probes_out,
        adapter=adapter_out,
    )


def to_public_diagnostics(
    raw: dict[str, Any],
    *,
    mask_ips: bool = False,
) -> PublicDiagnosticsDTO:
    steps = [mask_ip(str(s), mask_ips) for s in (raw.get("steps") or [])]
    summary = mask_ip(str(raw.get("summary") or ""), mask_ips)
    explain = mask_ip(str(raw.get("explain_text") or ""), mask_ips)
    return PublicDiagnosticsDTO(
        diagnosis=str(raw.get("diagnosis") or "UNKNOWN"),
        traffic_light=raw.get("traffic_light"),
        summary=summary,
        steps=steps,
        explain_text=explain,
    )
