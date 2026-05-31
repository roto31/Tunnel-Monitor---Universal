from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from uvpn.adapters.registry import get_adapter, list_adapters
from uvpn.core.config import DEFAULT_CONFIG_PATH, MonitorConfig
from uvpn.core.engine import MonitorEngine
from uvpn.core.models import CheckSnapshot


@dataclass
class MonitorView:
    """Normalized view consumed by CLI, TUI, and native GUIs."""

    status: dict[str, Any]
    statistics: dict[str, Any]
    logs: list[str]
    diagnostics: dict[str, Any]

    def to_dict(self) -> dict[str, Any]:
        return {
            "status": self.status,
            "statistics": self.statistics,
            "logs": self.logs,
            "diagnostics": self.diagnostics,
        }


class MonitorAPI:
    """
    Platform abstraction layer between the Python monitoring core and all frontends.

    Every interface (CLI, universal terminal, Linux GUI, macOS GUI) must call this
    API so capabilities remain equivalent.
    """

    def __init__(self, config: MonitorConfig | None = None) -> None:
        self._engine = MonitorEngine(config)

    @property
    def engine(self) -> MonitorEngine:
        return self._engine

    def run_check(self) -> CheckSnapshot:
        return self._engine.run_check()

    def get_status(self) -> dict[str, Any]:
        data = self._engine.store.read()
        if not data:
            return {"present": False, "message": "No state file. Run check first."}
        data["present"] = True
        return data

    def get_statistics(self) -> dict[str, Any]:
        data = self.get_status()
        if not data.get("present"):
            return {"available": False, "message": data.get("message", "")}
        stats = data.get("statistics") or {}
        adapter_raw = (data.get("adapter") or {}).get("raw") or {}
        return {
            "available": True,
            "timestamp": data.get("timestamp"),
            "vpn_type": data.get("vpn_type"),
            "probes": {
                k: {"ok": v.get("ok"), "latency_ms": v.get("latency_ms")}
                for k, v in (data.get("probes") or {}).items()
            },
            "adapter": stats if stats else adapter_raw,
            "failure_count": data.get("failure_count"),
            "alert_state": data.get("alert_state"),
        }

    def get_logs(self, limit: int = 50) -> list[str]:
        data = self.get_status()
        if not data.get("present"):
            return ["No state file. Run: uvpn check"]
        logs = data.get("logs") or []
        if isinstance(logs, list):
            return [str(line) for line in logs[:limit]]
        return []

    def get_diagnostics(self) -> dict[str, Any]:
        data = self.get_status()
        if not data.get("present"):
            return {
                "diagnosis": "UNKNOWN",
                "summary": "No monitoring data yet.",
                "steps": ["Run: uvpn check"],
                "issues": [],
            }
        return {
            "diagnosis": data.get("diagnosis"),
            "traffic_light": data.get("traffic_light"),
            "summary": (data.get("issues") or [""])[0],
            "steps": data.get("recommended_steps") or [],
            "issues": data.get("issues") or [],
            "explain_text": self._engine.explain(data.get("diagnosis")),
        }

    def explain(self, diagnosis_code: str | None = None) -> str:
        return self._engine.explain(diagnosis_code)

    def preflight(self) -> tuple[int, list[str]]:
        return self._engine.preflight()

    def list_adapters(self) -> list[str]:
        return list_adapters()

    def full_view(self) -> MonitorView:
        status = self.get_status()
        return MonitorView(
            status=status,
            statistics=self.get_statistics(),
            logs=self.get_logs(),
            diagnostics=self.get_diagnostics(),
        )

    @classmethod
    def from_config_path(cls, path: str | None = None) -> MonitorAPI:
        from pathlib import Path

        cfg = MonitorConfig.load(Path(path) if path else DEFAULT_CONFIG_PATH)
        return cls(cfg)
