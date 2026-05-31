from __future__ import annotations

import json
import os
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


DEFAULT_CONFIG_DIR = Path(os.environ.get("UVPN_CONFIG_DIR", Path.home() / ".config" / "uvpn"))
DEFAULT_STATE_PATH = DEFAULT_CONFIG_DIR / "state.json"
DEFAULT_CONFIG_PATH = DEFAULT_CONFIG_DIR / "config.json"


@dataclass
class MonitorConfig:
    vpn_type: str = "auto"
    remote_lan_ip: str = ""
    remote_wan_ip: str = ""
    remote_ddns: str = ""
    failure_threshold: int = 3
    check_interval_sec: int = 300
    interface_name: str = ""
    openvpn_management: str = "127.0.0.1:7505"
    wireguard_interface: str = "wg0"
    ipsec_tool: str = "swanctl"
    cisco_vpn_binary: str = "/opt/cisco/secureclient/bin/vpn"
    extra: dict[str, Any] = field(default_factory=dict)

    @classmethod
    def load(cls, path: Path | None = None) -> MonitorConfig:
        cfg_path = path or DEFAULT_CONFIG_PATH
        if not cfg_path.is_file():
            return cls()
        data = json.loads(cfg_path.read_text(encoding="utf-8"))
        known = {f.name for f in cls.__dataclass_fields__.values()}  # type: ignore[attr-defined]
        kwargs = {k: v for k, v in data.items() if k in known and k != "extra"}
        extra = {k: v for k, v in data.items() if k not in known}
        return cls(**kwargs, extra=extra)

    def save(self, path: Path | None = None) -> None:
        cfg_path = path or DEFAULT_CONFIG_PATH
        cfg_path.parent.mkdir(parents=True, exist_ok=True)
        payload = {
            "vpn_type": self.vpn_type,
            "remote_lan_ip": self.remote_lan_ip,
            "remote_wan_ip": self.remote_wan_ip,
            "remote_ddns": self.remote_ddns,
            "failure_threshold": self.failure_threshold,
            "check_interval_sec": self.check_interval_sec,
            "interface_name": self.interface_name,
            "openvpn_management": self.openvpn_management,
            "wireguard_interface": self.wireguard_interface,
            "ipsec_tool": self.ipsec_tool,
            "cisco_vpn_binary": self.cisco_vpn_binary,
            **self.extra,
        }
        cfg_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
