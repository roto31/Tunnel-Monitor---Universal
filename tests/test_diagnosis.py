from uvpn.core.diagnosis import compute_diagnosis
from uvpn.core.models import AdapterStatus, Diagnosis, ProbeResult


def test_healthy_when_tunnel_ok() -> None:
    probes = {
        "our_internet": ProbeResult("1.1.1.1", True),
        "tunnel": ProbeResult("10.0.0.1", True),
        "remote_wan": ProbeResult("203.0.113.1", True),
        "dns": ProbeResult("host", True, detail="203.0.113.1"),
    }
    adapter = AdapterStatus("wireguard", "wireguard", True, True)
    assert compute_diagnosis(probes, adapter, True) == Diagnosis.HEALTHY


def test_tunnel_down_when_wan_ok() -> None:
    probes = {
        "our_internet": ProbeResult("1.1.1.1", True),
        "tunnel": ProbeResult("10.0.0.1", False),
        "remote_wan": ProbeResult("203.0.113.1", True),
        "dns": ProbeResult("host", True, detail="203.0.113.1"),
    }
    adapter = AdapterStatus("generic", "generic", True, None)
    assert compute_diagnosis(probes, adapter, True) == Diagnosis.TUNNEL_DOWN


def test_vpn_daemon_down() -> None:
    probes = {
        "our_internet": ProbeResult("1.1.1.1", True),
        "tunnel": ProbeResult("10.0.0.1", False),
        "remote_wan": ProbeResult("203.0.113.1", True),
        "dns": ProbeResult("host", True, detail="203.0.113.1"),
    }
    adapter = AdapterStatus("openvpn", "openvpn", True, False)
    assert compute_diagnosis(probes, adapter, True) == Diagnosis.VPN_DAEMON_DOWN
