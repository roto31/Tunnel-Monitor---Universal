from __future__ import annotations

from uvpn.core.models import AdapterStatus, Diagnosis, ProbeResult, TrafficLight


def compute_diagnosis(
    probes: dict[str, ProbeResult],
    adapter: AdapterStatus,
    dns_match: bool,
) -> Diagnosis:
    if not probes.get("our_internet", ProbeResult("", False)).ok:
        return Diagnosis.OUR_INTERNET_DOWN
    if adapter.supported and adapter.connected is False:
        return Diagnosis.VPN_DAEMON_DOWN
    if probes.get("tunnel", ProbeResult("", False)).ok:
        return Diagnosis.HEALTHY
    if adapter.supported and adapter.connected is True and not probes["tunnel"].ok:
        return Diagnosis.VPN_NEGOTIATION_FAILED
    if not dns_match and probes.get("dns", ProbeResult("", False)).target:
        return Diagnosis.DDNS_DRIFT
    if not probes.get("remote_wan", ProbeResult("", False)).ok:
        return Diagnosis.REMOTE_INTERNET_DOWN
    return Diagnosis.TUNNEL_DOWN


def traffic_light_for(diagnosis: Diagnosis, failure_count: int, threshold: int) -> TrafficLight:
    if diagnosis == Diagnosis.HEALTHY:
        return TrafficLight.GREEN
    if diagnosis == Diagnosis.OUR_INTERNET_DOWN:
        return TrafficLight.YELLOW
    if failure_count >= threshold:
        return TrafficLight.RED
    return TrafficLight.YELLOW


RUNBOOKS: dict[Diagnosis, tuple[str, list[str]]] = {
    Diagnosis.HEALTHY: (
        "Path looks good—the VPN client and your probe target agree.",
        [
            "No action required.",
            "Optional: uvpn preflight before your next change window.",
        ],
    ),
    Diagnosis.OUR_INTERNET_DOWN: (
        "Your machine could not reach the internet check—uvpn paused VPN failure counting.",
        [
            "Fix local Wi‑Fi, Ethernet, or ISP first.",
            "Run uvpn check again after connectivity returns.",
        ],
    ),
    Diagnosis.TUNNEL_DOWN: (
        "Remote WAN and DNS looked reachable, but the LAN probe failed.",
        [
            "Open docs/troubleshooting/ for your vpn_type—TUNNEL_DOWN flowchart.",
            "Inspect adapter status: uvpn check and state.json.",
            "Review VPN logs and firewall rules on the path you need.",
        ],
    ),
    Diagnosis.REMOTE_INTERNET_DOWN: (
        "The remote site's public side did not answer—often their ISP or gateway.",
        [
            "Confirm with whoever runs the remote site.",
            "ICMP may be blocked; cross-check vendor VPN status if installed.",
        ],
    ),
    Diagnosis.DDNS_DRIFT: (
        "DDNS does not match the WAN IP you configured—common after ISP changes.",
        [
            "dig your remote_ddns hostname and compare to remote_wan_ip.",
            "Update the DDNS record or config to match reality.",
        ],
    ),
    Diagnosis.VPN_DAEMON_DOWN: (
        "The VPN client is not connected (or the monitor cannot read it).",
        [
            "Reconnect in the VPN app or start the client service.",
            "Run uvpn preflight—confirm binary path and vpn_type.",
            "See platform troubleshooting—VPN_DAEMON_DOWN branch.",
        ],
    ),
    Diagnosis.VPN_NEGOTIATION_FAILED: (
        "Client says connected, but the host you need is unreachable—often split tunnel or routing.",
        [
            "Pick a remote_lan_ip inside subnets the VPN actually routes.",
            "Disconnect and reconnect the session.",
            "See platform troubleshooting—VPN_NEGOTIATION_FAILED flowchart.",
        ],
    ),
    Diagnosis.UNSUPPORTED: (
        "uvpn cannot read this VPN stack on this host yet.",
        [
            "Set vpn_type to match your installed client.",
            "Use generic for ICMP-only monitoring if no CLI is available.",
        ],
    ),
    Diagnosis.UNKNOWN: (
        "Not enough signal for a stable diagnosis.",
        [
            "Run uvpn preflight.",
            "Complete remote_lan_ip and remote_wan_ip in config.json.",
        ],
    ),
}
