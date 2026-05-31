from __future__ import annotations

import shutil
import subprocess
from typing import Any

from uvpn.adapters.base import VpnAdapter
from uvpn.core.models import AdapterStatus


class GenericReachabilityAdapter(VpnAdapter):
    adapter_id = "generic"
    vpn_type = "generic"

    def probe(self, config: dict[str, Any]) -> AdapterStatus:
        return AdapterStatus(
            adapter_id=self.adapter_id,
            vpn_type=self.vpn_type,
            supported=True,
            connected=None,
            detail="Reachability-only mode; no VPN daemon probe.",
        )
