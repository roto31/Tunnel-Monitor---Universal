from __future__ import annotations

import re
import shutil
import subprocess
import time
from typing import Any

from uvpn.adapters.base import VpnAdapter
from uvpn.core.models import AdapterStatus


class WireGuardAdapter(VpnAdapter):
    adapter_id = "wireguard"
    vpn_type = "wireguard"

    def probe(self, config: dict[str, Any]) -> AdapterStatus:
        iface = config.get("wireguard_interface") or config.get("interface_name") or "wg0"
        if not shutil.which("wg"):
            return AdapterStatus(
                adapter_id=self.adapter_id,
                vpn_type=self.vpn_type,
                supported=False,
                connected=None,
                detail="wg command not installed",
            )
        proc = subprocess.run(
            ["wg", "show", iface, "dump"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if proc.returncode != 0:
            return AdapterStatus(
                adapter_id=self.adapter_id,
                vpn_type=self.vpn_type,
                supported=True,
                connected=False,
                detail=f"interface {iface} not found or down",
            )
        lines = [ln for ln in proc.stdout.strip().splitlines() if ln.strip()]
        peers = lines[1:] if len(lines) > 1 else []
        recent_handshake = False
        for peer_line in peers:
            parts = peer_line.split("\t")
            if len(parts) >= 5:
                try:
                    hs = int(parts[4])
                    if hs > 0 and (time.time() - hs) < 180:
                        recent_handshake = True
                except ValueError:
                    pass
        connected = bool(peers) and recent_handshake
        stats = {
            "interface": iface,
            "peer_count": len(peers),
            "recent_handshake": recent_handshake,
        }
        for peer_line in peers:
            parts = peer_line.split("\t")
            if len(parts) >= 7:
                stats.setdefault("peers", []).append(
                    {"pubkey_prefix": parts[0][:8], "rx_bytes": parts[5], "tx_bytes": parts[6]}
                )
        return AdapterStatus(
            adapter_id=self.adapter_id,
            vpn_type=self.vpn_type,
            supported=True,
            connected=connected,
            detail=f"peers={len(peers)} recent_handshake={recent_handshake}",
            raw=stats,
            statistics=stats,
        )

    def capabilities(self) -> dict[str, bool]:
        return {
            "connection_status": True,
            "statistics": True,
            "logs": False,
            "diagnostics": True,
            "daemon_status": True,
            "peer_count": True,
        }
