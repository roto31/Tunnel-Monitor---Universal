"""Parse vendor CLI stdout for enterprise adapters — testable without subprocess."""

from __future__ import annotations

import re
from dataclasses import dataclass


@dataclass(frozen=True)
class ParsedCliStatus:
    connected: bool | None
    detail: str
    state: str = ""


def parse_gpctl_status(stdout: str) -> ParsedCliStatus:
    """
    Parse `gpctl show status` output.

    Source: Palo Alto GlobalProtect admin documentation (status field patterns).
    """
    text = stdout.strip()
    lower = text.lower()
    if not text:
        return ParsedCliStatus(None, "empty gpctl output")
    if "not connected" in lower or "disconnected" in lower:
        return ParsedCliStatus(False, "gpctl: disconnected", "disconnected")
    if re.search(r"\bconnected\b", lower) and "not connected" not in lower:
        return ParsedCliStatus(True, "gpctl: connected", "connected")
    if "connecting" in lower:
        return ParsedCliStatus(False, "gpctl: connecting", "connecting")
    return ParsedCliStatus(None, "gpctl: unrecognized status format")


def parse_fortivpn_status(stdout: str) -> ParsedCliStatus:
    """
    Parse FortiClient VPN status CLI output.

    Source: FortiClient EMS/admin CLI references (vpn status / fortivpn status).
    """
    text = stdout.strip()
    lower = text.lower()
    if not text:
        return ParsedCliStatus(None, "empty fortivpn output")
    if "not connected" in lower or "disconnected" in lower:
        return ParsedCliStatus(False, "fortivpn: disconnected", "disconnected")
    if "connected" in lower:
        return ParsedCliStatus(True, "fortivpn: connected", "connected")
    if "connecting" in lower:
        return ParsedCliStatus(False, "fortivpn: connecting", "connecting")
    return ParsedCliStatus(None, "fortivpn: unrecognized status format")


def parse_pulse_status(stdout: str) -> ParsedCliStatus:
    """
    Parse Pulse/Ivanti Secure Access CLI status output.

    Contract: Ivanti Secure Access Client admin guide — `status` subcommand when
    exposed via pulselauncher or PulseClient.sh wrapper.
    """
    text = stdout.strip()
    lower = text.lower()
    if not text:
        return ParsedCliStatus(None, "empty pulse CLI output")
    if "not connected" in lower or "disconnected" in lower or "not running" in lower:
        return ParsedCliStatus(False, "pulse: disconnected", "disconnected")
    if re.search(r"\bconnected\b", lower) and "not connected" not in lower:
        return ParsedCliStatus(True, "pulse: connected", "connected")
    if "connecting" in lower or "in progress" in lower:
        return ParsedCliStatus(False, "pulse: connecting", "connecting")
    if "error" in lower or "failed" in lower:
        return ParsedCliStatus(False, "pulse: error", "error")
    return ParsedCliStatus(None, "pulse: unrecognized status format")
