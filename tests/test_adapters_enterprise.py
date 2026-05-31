from __future__ import annotations

import subprocess
from typing import Any
from unittest.mock import patch

import pytest

from tests.conftest import load_fixture
from uvpn.adapters.cli_parse import (
    parse_fortivpn_status,
    parse_gpctl_status,
    parse_pulse_status,
)
from uvpn.adapters.fortinet import FortinetAdapter
from uvpn.adapters.globalprotect import GlobalProtectAdapter
from uvpn.adapters.pulse import PulseAdapter


class TestCliParsers:
    def test_gpctl_connected(self) -> None:
        out = load_fixture("globalprotect", "connected.txt")
        parsed = parse_gpctl_status(out)
        assert parsed.connected is True

    def test_gpctl_disconnected(self) -> None:
        out = load_fixture("globalprotect", "disconnected.txt")
        parsed = parse_gpctl_status(out)
        assert parsed.connected is False

    def test_gpctl_connecting(self) -> None:
        out = load_fixture("globalprotect", "connecting.txt")
        parsed = parse_gpctl_status(out)
        assert parsed.connected is False

    def test_fortivpn_connected(self) -> None:
        parsed = parse_fortivpn_status(load_fixture("fortinet", "connected.txt"))
        assert parsed.connected is True

    def test_fortivpn_disconnected(self) -> None:
        parsed = parse_fortivpn_status(load_fixture("fortinet", "disconnected.txt"))
        assert parsed.connected is False

    def test_pulse_connected(self) -> None:
        parsed = parse_pulse_status(load_fixture("pulse", "connected.txt"))
        assert parsed.connected is True

    def test_pulse_disconnected(self) -> None:
        parsed = parse_pulse_status(load_fixture("pulse", "disconnected.txt"))
        assert parsed.connected is False

    def test_pulse_error(self) -> None:
        parsed = parse_pulse_status(load_fixture("pulse", "error.txt"))
        assert parsed.connected is False
        assert parsed.state == "error"


class TestAdapterProbeWithFixtures:
    def test_globalprotect_probe_connected(self) -> None:
        adapter = GlobalProtectAdapter()
        out = load_fixture("globalprotect", "connected.txt")

        def fake_run(_config: dict[str, Any], _args: list[str]) -> tuple[str, int]:
            return out, 0

        with patch.object(adapter, "_run_gpctl", side_effect=fake_run):
            status = adapter.probe({})
        assert status.supported is True
        assert status.connected is True

    def test_globalprotect_missing_binary(self) -> None:
        adapter = GlobalProtectAdapter()
        with patch.object(adapter, "_run_gpctl", return_value=("", 127)):
            status = adapter.probe({})
        assert status.supported is False

    def test_fortinet_probe_connected(self) -> None:
        adapter = FortinetAdapter()
        out = load_fixture("fortinet", "connected.txt")

        with patch.object(adapter, "_run_cli", return_value=(out, 0)):
            status = adapter.probe({})
        assert status.connected is True

    def test_pulse_probe_connected(self) -> None:
        adapter = PulseAdapter()
        out = load_fixture("pulse", "connected.txt")

        with patch.object(adapter, "_run", return_value=(out, 0)):
            status = adapter.probe({})
        assert status.connected is True

    def test_pulse_probe_error(self) -> None:
        adapter = PulseAdapter()
        out = load_fixture("pulse", "error.txt")

        with patch.object(adapter, "_run", return_value=(out, 1)):
            status = adapter.probe({})
        assert status.connected is False
