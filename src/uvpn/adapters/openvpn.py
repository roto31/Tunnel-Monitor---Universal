from __future__ import annotations

import socket
import shutil
import subprocess
from pathlib import Path
from typing import Any

from uvpn.adapters.base import VpnAdapter
from uvpn.core.models import AdapterStatus


def _mgmt_command(host: str, port: int, command: str, timeout: float = 2.0) -> str:
    with socket.create_connection((host, port), timeout=timeout) as sock:
        sock.settimeout(timeout)
        buf = b""
        while b"\n" not in buf:
            buf += sock.recv(4096)
        sock.sendall(f"{command}\n".encode())
        out = b""
        while True:
            chunk = sock.recv(4096)
            if not chunk:
                break
            out += chunk
            if b"END" in out or len(out) > 65536:
                break
        return out.decode("utf-8", errors="replace")


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
            state = _mgmt_command(host, port, "state")
            connected = "CONNECTED" in state.upper() or "ASSIGN" in state.upper()
            detail = f"management state: connected={connected}"
        except OSError:
            status_file = Path(config.get("openvpn_status_file", "/var/log/openvpn/status.log"))
            if status_file.is_file():
                text = status_file.read_text(encoding="utf-8", errors="replace")[:500]
                connected = "CONNECTED" in text.upper() or "ROUTING" in text.upper()
                detail = f"status file heuristic: connected={connected}"
            elif shutil.which("pgrep"):
                proc = subprocess.run(["pgrep", "-x", "openvpn"], capture_output=True, text=True)
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

    def collect_statistics(self, config: dict[str, Any], status: AdapterStatus) -> dict[str, Any]:
        mgmt = config.get("openvpn_management", "127.0.0.1:7505")
        host, _, port_s = mgmt.partition(":")
        port = int(port_s or "7505")
        stats: dict[str, Any] = {"management": mgmt}
        try:
            stats["status"] = _mgmt_command(host, port, "status")[:4000]
        except OSError as exc:
            stats["error"] = str(exc)
        return stats

    def collect_logs(self, config: dict[str, Any], limit: int = 50) -> list[str]:
        log_path = Path(config.get("openvpn_log_file", "/var/log/openvpn/openvpn.log"))
        if log_path.is_file():
            lines = log_path.read_text(encoding="utf-8", errors="replace").splitlines()
            return lines[-limit:]
        return []

    def capabilities(self) -> dict[str, bool]:
        return {
            "connection_status": True,
            "statistics": True,
            "logs": True,
            "diagnostics": True,
            "daemon_status": True,
            "management_socket": True,
            "peer_count": True,
        }
