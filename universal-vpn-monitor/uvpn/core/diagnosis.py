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
        "Tunnel path reachable; VPN adapter reports healthy or not required.",
        ["No action required.", "Optional: uvpn preflight"],
    ),
    Diagnosis.OUR_INTERNET_DOWN: (
        "Local internet probe failed before tunnel evaluation.",
        ["Restore local connectivity.", "Re-run uvpn check after recovery."],
    ),
    Diagnosis.TUNNEL_DOWN: (
        "Remote WAN and DNS OK but tunnel LAN unreachable.",
        ["Inspect VPN adapter status.", "Verify routes and firewall.", "Review VPN logs."],
    ),
    Diagnosis.REMOTE_INTERNET_DOWN: (
        "Remote public IP unreachable from this host.",
        ["Confirm remote site ISP.", "ICMP may be filtered — interpret with caution."],
    ),
    Diagnosis.DDNS_DRIFT: (
        "DDNS resolution does not match configured remote WAN IP.",
        ["Update DDNS record or config remote_wan_ip."],
    ),
    Diagnosis.VPN_DAEMON_DOWN: (
        "VPN client/daemon not connected per adapter probe.",
        ["Start VPN service or client.", "Check adapter-specific logs."],
    ),
    Diagnosis.VPN_NEGOTIATION_FAILED: (
        "VPN reports connected but tunnel probe failed — routing or policy issue.",
        ["Compare routes with ping target.", "Bounce VPN session."],
    ),
    Diagnosis.UNSUPPORTED: (
        "VPN type unknown or adapter unavailable on this host.",
        ["Set vpn_type explicitly.", "Use generic reachability-only mode."],
    ),
    Diagnosis.UNKNOWN: (
        "Insufficient data for stable diagnosis.",
        ["Run uvpn preflight.", "Complete config.json."],
    ),
}
