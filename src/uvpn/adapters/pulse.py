from __future__ import annotations

import shutil
import subprocess
from pathlib import Path
from typing import Any

from uvpn.adapters.base import VpnAdapter
from uvpn.core.models import AdapterStatus


class PulseAdapter(VpnAdapter):
    """
    Pulse Secure / Ivanti Secure Access client.

    **Research gap:** No stable cross-platform CLI documented for all Pulse/Ivanti releases.
    This adapter attempts `pulselauncher` / `ivanti` status heuristics when present.

    Official docs: https://docs.pulsesecure.net/ (product-specific)
    """

    adapter_id = "pulse"
    vpn_type = "pulse"

    _BINARIES = ("pulselauncher", "ivanti", "/usr/local/pulse/PulseClient.sh")

    def _run(self, config: dict[str, Any], args: list[str]) -> tuple[str, int]:
        configured = config.get("pulse_binary")
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
        out, code = self._run(config, ["status"])
        if code == 127:
            return AdapterStatus(
                adapter_id=self.adapter_id,
                vpn_type=self.vpn_type,
                supported=False,
                connected=None,
                detail="Pulse/Ivanti CLI not found — use generic adapter",
            )
        connected = "connected" in out.lower()
        return AdapterStatus(
            adapter_id=self.adapter_id,
            vpn_type=self.vpn_type,
            supported=True,
            connected=connected,
            detail="pulse status (heuristic — verify against your client version)",
            raw={"exit_code": code, "snippet": out[:500]},
        )

    def capabilities(self) -> dict[str, bool]:
        return {
            "connection_status": True,
            "statistics": False,
            "logs": False,
            "diagnostics": True,
            "daemon_status": True,
        }
