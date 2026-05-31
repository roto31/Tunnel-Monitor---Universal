from __future__ import annotations

import subprocess
from pathlib import Path
from typing import Any

from uvpn.adapters.base import VpnAdapter
from uvpn.core.models import AdapterStatus


class CiscoAnyConnectAdapter(VpnAdapter):
    adapter_id = "cisco_anyconnect"
    vpn_type = "cisco_anyconnect"

    _CANDIDATE_BINARIES = (
        "/opt/cisco/secureclient/bin/vpn",
        "/opt/cisco/anyconnect/bin/vpn",
        "/opt/cisco/vpn/bin/vpn",
    )

    def _resolve_binary(self, config: dict[str, Any]) -> Path | None:
        configured = config.get("cisco_vpn_binary")
        if configured and Path(configured).is_file():
            return Path(configured)
        for candidate in self._CANDIDATE_BINARIES:
            p = Path(candidate)
            if p.is_file():
                return p
        return None

    def probe(self, config: dict[str, Any]) -> AdapterStatus:
        binary = self._resolve_binary(config)
        if not binary:
            return AdapterStatus(
                adapter_id=self.adapter_id,
                vpn_type=self.vpn_type,
                supported=False,
                connected=None,
                detail="Cisco Secure Client vpn binary not found",
            )
        proc = subprocess.run([str(binary), "state"], capture_output=True, text=True, timeout=10)
        out = (proc.stdout + proc.stderr).lower()
        connected = "state: connected" in out or ("connected" in out and "disconnected" not in out)
        return AdapterStatus(
            adapter_id=self.adapter_id,
            vpn_type=self.vpn_type,
            supported=True,
            connected=connected,
            detail=f"{binary.name} state",
            raw={"binary": str(binary), "exit_code": proc.returncode},
        )

    def collect_statistics(self, config: dict[str, Any], status: AdapterStatus) -> dict[str, Any]:
        binary = self._resolve_binary(config)
        if not binary:
            return status.raw
        proc = subprocess.run([str(binary), "stats"], capture_output=True, text=True, timeout=10)
        return {
            "binary": str(binary),
            "stats_output": (proc.stdout + proc.stderr)[:4000],
            "exit_code": proc.returncode,
        }

    def capabilities(self) -> dict[str, bool]:
        return {
            "connection_status": True,
            "statistics": True,
            "logs": False,
            "diagnostics": True,
            "daemon_status": True,
        }
