from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any

from uvpn.core.models import AdapterStatus


class VpnAdapter(ABC):
    adapter_id: str
    vpn_type: str

    @abstractmethod
    def probe(self, config: dict[str, Any]) -> AdapterStatus:
        """Return protocol-specific VPN health. Must not raise."""

    def collect_statistics(self, config: dict[str, Any], status: AdapterStatus) -> dict[str, Any]:
        """Optional protocol statistics; default uses probe raw fields."""
        return dict(status.raw)

    def collect_logs(self, config: dict[str, Any], limit: int = 50) -> list[str]:
        """Optional recent log lines from documented CLI or log file paths."""
        return []

    def capabilities(self) -> dict[str, bool]:
        return {
            "connection_status": True,
            "statistics": False,
            "logs": False,
            "diagnostics": True,
            "daemon_status": True,
            "peer_count": False,
            "management_socket": False,
        }
