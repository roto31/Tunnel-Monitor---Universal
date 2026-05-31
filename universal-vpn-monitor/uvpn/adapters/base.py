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

    def capabilities(self) -> dict[str, bool]:
        return {
            "daemon_status": True,
            "peer_count": False,
            "management_socket": False,
        }
