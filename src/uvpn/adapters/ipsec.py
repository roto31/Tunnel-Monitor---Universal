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

    def collect_statistics(self, config: dict[str, Any], status: AdapterStatus) -> dict[str, Any]:
        if shutil.which("swanctl"):
            proc = subprocess.run(
                ["swanctl", "--list-sas"],
                capture_output=True,
                text=True,
                timeout=8,
            )
            return {"swanctl_list_sas": proc.stdout[:4000], "exit_code": proc.returncode}
        if shutil.which("ipsec"):
            proc = subprocess.run(["ipsec", "statusall"], capture_output=True, text=True, timeout=8)
            return {"ipsec_statusall": proc.stdout[:4000], "exit_code": proc.returncode}
        return status.raw

    def collect_logs(self, config: dict[str, Any], limit: int = 50) -> list[str]:
        if shutil.which("journalctl"):
            proc = subprocess.run(
                ["journalctl", "-u", "strongswan", "-n", str(limit), "--no-pager"],
                capture_output=True,
                text=True,
                timeout=8,
            )
            if proc.stdout.strip():
                return proc.stdout.splitlines()[-limit:]
        return []

    def capabilities(self) -> dict[str, bool]:
        return {
            "connection_status": True,
            "statistics": True,
            "logs": shutil.which("journalctl") is not None,
            "diagnostics": True,
            "daemon_status": True,
        }
