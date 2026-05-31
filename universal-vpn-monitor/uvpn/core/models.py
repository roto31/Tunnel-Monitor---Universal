from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Any


class Diagnosis(str, Enum):
    HEALTHY = "HEALTHY"
    OUR_INTERNET_DOWN = "OUR_INTERNET_DOWN"
    TUNNEL_DOWN = "TUNNEL_DOWN"
    REMOTE_INTERNET_DOWN = "REMOTE_INTERNET_DOWN"
    DDNS_DRIFT = "DDNS_DRIFT"
    VPN_DAEMON_DOWN = "VPN_DAEMON_DOWN"
    VPN_NEGOTIATION_FAILED = "VPN_NEGOTIATION_FAILED"
    UNSUPPORTED = "UNSUPPORTED"
    UNKNOWN = "UNKNOWN"


class TrafficLight(str, Enum):
    GREEN = "green"
    YELLOW = "yellow"
    RED = "red"
    GREY = "grey"


@dataclass
class ProbeResult:
    target: str
    ok: bool
    latency_ms: float | None = None
    detail: str = ""


@dataclass
class AdapterStatus:
    adapter_id: str
    vpn_type: str
    supported: bool
    connected: bool | None
    detail: str = ""
    raw: dict[str, Any] = field(default_factory=dict)


@dataclass
class CheckSnapshot:
    schema_version: int
    timestamp: str
    vpn_type: str
    diagnosis: Diagnosis
    traffic_light: TrafficLight
    alert_state: str
    failure_count: int
    probes: dict[str, ProbeResult]
    adapter: AdapterStatus
    issues: list[str] = field(default_factory=list)
    recommended_steps: list[str] = field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        return {
            "schema_version": self.schema_version,
            "timestamp": self.timestamp,
            "vpn_type": self.vpn_type,
            "diagnosis": self.diagnosis.value,
            "traffic_light": self.traffic_light.value,
            "alert_state": self.alert_state,
            "failure_count": self.failure_count,
            "probes": {
                k: {
                    "target": v.target,
                    "ok": v.ok,
                    "latency_ms": v.latency_ms,
                    "detail": v.detail,
                }
                for k, v in self.probes.items()
            },
            "adapter": {
                "adapter_id": self.adapter.adapter_id,
                "vpn_type": self.adapter.vpn_type,
                "supported": self.adapter.supported,
                "connected": self.adapter.connected,
                "detail": self.adapter.detail,
                "raw": self.adapter.raw,
            },
            "issues": self.issues,
            "recommended_steps": self.recommended_steps,
        }
