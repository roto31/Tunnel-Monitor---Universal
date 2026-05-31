from __future__ import annotations

import socket
import shutil
import subprocess
from pathlib import Path
from typing import Any

from uvpn.adapters.base import VpnAdapter
from uvpn.core.models import AdapterStatus


class OpenVpnAdapter(VpnAdapter):
    adapter_id = "openvpn"
    vpn_type = "openvpn"

    def probe(self, config: dict[str, Any]) -> AdapterStatus:
        mgmt = config.get("openvpn_management", "127.0.0.1:7505")
        host, _, port_s = mgmt.partition(":")
        port = int(port_s or "7505")
        connected = False
        detail = ""
        try:
            with socket.create_connection((host, port), timeout=2):
                connected = True
                detail = f"management socket open at {mgmt}"
        except OSError:
            # Fallback: status file or process check
            status_file = Path(config.get("openvpn_status_file", "/var/log/openvpn/status.log"))
            if status_file.is_file():
                text = status_file.read_text(encoding="utf-8", errors="replace")[:500]
                connected = "CONNECTED" in text.upper() or "ROUTING" in text.upper()
                detail = f"status file heuristic: connected={connected}"
            elif shutil.which("pgrep"):
                proc = subprocess.run(
                    ["pgrep", "-x", "openvpn"],
                    capture_output=True,
                    text=True,
                )
                connected = proc.returncode == 0
                detail = "openvpn process running" if connected else "openvpn process not found"
            else:
                detail = "management socket closed; no fallback"
        return AdapterStatus(
            adapter_id=self.adapter_id,
            vpn_type=self.vpn_type,
            supported=True,
            connected=connected,
            detail=detail,
            raw={"management": mgmt},
        )

    def capabilities(self) -> dict[str, bool]:
        return {"daemon_status": True, "management_socket": True, "peer_count": True}
