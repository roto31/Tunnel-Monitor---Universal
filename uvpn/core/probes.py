from __future__ import annotations

import platform
import re
import shutil
import subprocess
from typing import Callable

from uvpn.core.models import ProbeResult


def _ping_once(target: str, timeout_sec: int = 3) -> ProbeResult:
    if not target:
        return ProbeResult(target=target, ok=False, detail="empty target")
    system = platform.system()
    cmd: list[str]
    if system == "Darwin":
        cmd = ["ping", "-c", "1", "-W", str(timeout_sec * 1000), target]
    else:
        cmd = ["ping", "-c", "1", "-W", str(timeout_sec), target]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout_sec + 2)
    except (subprocess.TimeoutExpired, FileNotFoundError) as exc:
        return ProbeResult(target=target, ok=False, detail=str(exc))
    if proc.returncode != 0:
        return ProbeResult(target=target, ok=False, detail="ping failed")
    latency_ms = None
    m = re.search(r"(?:round-trip|rtt).*?=\s*[\d.]+/([\d.]+)/", proc.stdout, re.I)
    if m:
        try:
            latency_ms = float(m.group(1))
        except ValueError:
            latency_ms = None
    return ProbeResult(target=target, ok=True, latency_ms=latency_ms)


def _resolve_ddns(host: str) -> ProbeResult:
    if not host:
        return ProbeResult(target=host, ok=False, detail="empty host")
    if not shutil.which("dig"):
        return ProbeResult(target=host, ok=False, detail="dig not found")
    proc = subprocess.run(
        ["dig", "+short", "+time=3", "+tries=1", host, "@1.1.1.1"],
        capture_output=True,
        text=True,
        timeout=8,
    )
    ip = ""
    for line in proc.stdout.splitlines():
        line = line.strip()
        if re.match(r"^\d+\.\d+\.\d+\.\d+$", line):
            ip = line
            break
    ok = bool(ip)
    return ProbeResult(target=host, ok=ok, detail=ip or "unresolved")


def run_universal_probes(
    remote_lan_ip: str,
    remote_wan_ip: str,
    remote_ddns: str,
    our_internet_target: str = "1.1.1.1",
) -> dict[str, ProbeResult]:
    return {
        "tunnel": _ping_once(remote_lan_ip),
        "remote_wan": _ping_once(remote_wan_ip),
        "our_internet": _ping_once(our_internet_target),
        "dns": _resolve_ddns(remote_ddns),
    }


def dns_matches_expected(dns_probe: ProbeResult, expected_wan: str) -> bool:
    if not expected_wan or not dns_probe.ok:
        return False
    return dns_probe.detail.strip() == expected_wan.strip()
