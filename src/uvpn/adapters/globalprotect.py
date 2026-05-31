from __future__ import annotations

import shutil
import subprocess
from pathlib import Path
from typing import Any

from uvpn.adapters.base import VpnAdapter
from uvpn.adapters.cli_parse import parse_gpctl_status
from uvpn.core.models import AdapterStatus


class GlobalProtectAdapter(VpnAdapter):
    """
    Palo Alto GlobalProtect via gpctl.

    Source: https://docs.paloaltonetworks.com/globalprotect
    Version matrix: docs/architecture/adapter-version-matrix.md
    """

    adapter_id = "globalprotect"
    vpn_type = "globalprotect"
    PRODUCTION_VALIDATED = True

    _BINARIES = (
        "/Applications/GlobalProtect.app/Contents/Resources/gpctl",
        "/usr/local/bin/gpctl",
        "gpctl",
    )

    def _run_gpctl(self, config: dict[str, Any], args: list[str]) -> tuple[str, int]:
        configured = config.get("globalprotect_binary")
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
        out, code = self._run_gpctl(config, ["show", "status"])
        if code == 127:
            return AdapterStatus(
                adapter_id=self.adapter_id,
                vpn_type=self.vpn_type,
                supported=False,
                connected=None,
                detail="gpctl not found — set globalprotect_binary or use generic",
            )
        parsed = parse_gpctl_status(out)
        if parsed.connected is None:
            return AdapterStatus(
                adapter_id=self.adapter_id,
                vpn_type=self.vpn_type,
                supported=True,
                connected=None,
                detail=parsed.detail,
                raw={"exit_code": code, "snippet": out[:500], "state": parsed.state},
            )
        return AdapterStatus(
            adapter_id=self.adapter_id,
            vpn_type=self.vpn_type,
            supported=True,
            connected=parsed.connected,
            detail=parsed.detail,
            raw={"exit_code": code, "state": parsed.state, "snippet": out[:500]},
        )

    def collect_statistics(self, config: dict[str, Any], status: AdapterStatus) -> dict[str, Any]:
        out, code = self._run_gpctl(config, ["show", "status"])
        return {"gpctl_status": out[:4000], "exit_code": code}

    def capabilities(self) -> dict[str, bool]:
        return {
            "connection_status": True,
            "statistics": True,
            "logs": False,
            "diagnostics": True,
            "daemon_status": True,
            "production_validated": self.PRODUCTION_VALIDATED,
        }
