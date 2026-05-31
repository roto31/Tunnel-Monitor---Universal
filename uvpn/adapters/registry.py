from __future__ import annotations

from uvpn.adapters.base import VpnAdapter
from uvpn.adapters.cisco_anyconnect import CiscoAnyConnectAdapter
from uvpn.adapters.generic import GenericReachabilityAdapter
from uvpn.adapters.ipsec import IpsecAdapter
from uvpn.adapters.openvpn import OpenVpnAdapter
from uvpn.adapters.wireguard import WireGuardAdapter

ADAPTERS: dict[str, type[VpnAdapter]] = {
    "generic": GenericReachabilityAdapter,
    "openvpn": OpenVpnAdapter,
    "wireguard": WireGuardAdapter,
    "ipsec": IpsecAdapter,
    "ikev2": IpsecAdapter,
    "cisco_anyconnect": CiscoAnyConnectAdapter,
    "anyconnect": CiscoAnyConnectAdapter,
}


def get_adapter(vpn_type: str) -> VpnAdapter:
    key = (vpn_type or "generic").lower()
    cls = ADAPTERS.get(key, GenericReachabilityAdapter)
    return cls()


def list_adapters() -> list[str]:
    return sorted(ADAPTERS.keys())
