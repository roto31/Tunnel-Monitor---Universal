from __future__ import annotations

import shutil
import subprocess
from pathlib import Path
from typing import Any

from uvpn.adapters.base import VpnAdapter
from uvpn.core.models import AdapterStatus


class FortinetAdapter(VpnAdapter):
    """
    FortiClient VPN status via documented CLI where installed.

    **Research gap:** FortiClient CLI subcommands vary by OS and version. This adapter
    probes common binaries and parses output heuristically. Verify against your
    FortiClient version docs: https://docs.fortinet.com/product/forticlient
    """

    adapter_id = "fortinet"
    vpn_type = "fortinet"

    _BINARIES = ("forticlient", "fortivpn", "/opt/forticlient/fortivpn")

    def _run_cli(self, config: dict[str, Any], args: list[str]) -> tuple[str, int]:
        configured = config.get("fortinet_binary")
        candidates = [configured] if configured else list(self._BINARIES)
        for cand in candidates:
            if not cand:
                continue
            path = cand if Path(cand).is_file() else shutil.which(cand)
            if not path:
                continue
            proc = subprocess.run([path, *args], capture_output=True, text=True, timeout=12)
            return proc.stdout + proc.stderr, proc.returncode
        return "", 127

    def probe(self, config: dict[str, Any]) -> AdapterStatus:
        out, code = self._run_cli(config, ["vpn", "status"])
        if code == 127:
            return AdapterStatus(
                adapter_id=self.adapter_id,
                vpn_type=self.vpn_type,
                supported=False,
                connected=None,
                detail="FortiClient CLI not found — use generic adapter or verify binary path",
            )
        connected = "connected" in out.lower() and "not connected" not in out.lower()
        return AdapterStatus(
            adapter_id=self.adapter_id,
            vpn_type=self.vpn_type,
            supported=True,
            connected=connected,
            detail="forticlient vpn status (heuristic)",
            raw={"exit_code": code, "snippet": out[:500]},
        )

    def collect_statistics(self, config: dict[str, Any], status: AdapterStatus) -> dict[str, Any]:
        out, code = self._run_cli(config, ["vpn", "status"])
        return {"output": out[:4000], "exit_code": code}

    def capabilities(self) -> dict[str, bool]:
        return {
            "connection_status": True,
            "statistics": True,
            "logs": False,
            "diagnostics": True,
            "daemon_status": True,
        }
