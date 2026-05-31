from __future__ import annotations

import re
import shutil
import subprocess
from typing import Any

from uvpn.adapters.base import VpnAdapter
from uvpn.core.models import AdapterStatus


class IpsecAdapter(VpnAdapter):
    adapter_id = "ipsec"
    vpn_type = "ipsec"

    def probe(self, config: dict[str, Any]) -> AdapterStatus:
        tool = (config.get("ipsec_tool") or "swanctl").lower()
        if tool == "swanctl" and shutil.which("swanctl"):
            proc = subprocess.run(
                ["swanctl", "--list-sas"],
                capture_output=True,
                text=True,
                timeout=8,
            )
            text = proc.stdout + proc.stderr
            established = "ESTABLISHED" in text
            installed = "INSTALLED" in text
            connected = established and installed
            return AdapterStatus(
                adapter_id=self.adapter_id,
                vpn_type=self.vpn_type,
                supported=True,
                connected=connected,
                detail="swanctl --list-sas",
                raw={"established": established, "installed": installed},
            )
        if shutil.which("ipsec"):
            proc = subprocess.run(
                ["ipsec", "statusall"],
                capture_output=True,
                text=True,
                timeout=8,
            )
            text = proc.stdout
            connected = bool(re.search(r"ESTABLISHED|INSTALLED", text))
            return AdapterStatus(
                adapter_id=self.adapter_id,
                vpn_type=self.vpn_type,
                supported=True,
                connected=connected,
                detail="ipsec statusall",
                raw={"snippet": text[:400]},
            )
        return AdapterStatus(
            adapter_id=self.adapter_id,
            vpn_type=self.vpn_type,
            supported=False,
            connected=None,
            detail="no swanctl or ipsec CLI found",
        )

    def capabilities(self) -> dict[str, bool]:
        return {"daemon_status": True, "peer_count": False}
