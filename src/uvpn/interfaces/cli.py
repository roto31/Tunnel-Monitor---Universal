from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from uvpn.adapters.registry import list_adapters
from uvpn.api.platform import MonitorAPI
from uvpn.core.config import DEFAULT_CONFIG_PATH, MonitorConfig


def _config_path(args: argparse.Namespace) -> Path:
    if args.config == str(DEFAULT_CONFIG_PATH):
        return DEFAULT_CONFIG_PATH
    return Path(args.config)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="uvpn",
        description="Universal VPN Monitor CLI — status, statistics, logs, diagnostics",
    )
    parser.add_argument("--config", type=str, default=str(DEFAULT_CONFIG_PATH))
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("check", help="Run one monitoring cycle")
    sub.add_parser("status", help="Show last state.json (connection status)")
    sub.add_parser("statistics", help="Show probe and adapter statistics")
    sub.add_parser("stats", help="Alias for statistics")
    sub.add_parser("logs", help="Show recent VPN-related log lines")
    sub.add_parser("diagnostics", help="Diagnosis, issues, and runbook steps")
    sub.add_parser("explain", help="Print runbook for current diagnosis")
    sub.add_parser("preflight", help="Dependency and config checks")
    sub.add_parser("adapters", help="List registered VPN adapters")

    init_p = sub.add_parser("init-config", help="Write example config.json")
    init_p.add_argument("--force", action="store_true")

    logs_p = sub.add_parser("logs-tail", help="Fetch logs with line limit")
    logs_p.add_argument("-n", type=int, default=50)

    args = parser.parse_args(argv)
    cfg = MonitorConfig.load(_config_path(args))
    api = MonitorAPI(cfg)

    if args.command == "init-config":
        if DEFAULT_CONFIG_PATH.is_file() and not args.force:
            print(f"Config exists: {DEFAULT_CONFIG_PATH}", file=sys.stderr)
            return 2
        example = MonitorConfig(
            vpn_type="auto",
            remote_lan_ip="192.168.10.1",
            remote_wan_ip="203.0.113.10",
            remote_ddns="remote.example-ddns.test",
            wireguard_interface="wg0",
            openvpn_management="127.0.0.1:7505",
        )
        example.save()
        print(f"Wrote {DEFAULT_CONFIG_PATH}")
        return 0

    if args.command == "adapters":
        for name in list_adapters():
            print(name)
        return 0

    if args.command == "preflight":
        fails, lines = api.preflight()
        for line in lines:
            print(line)
        print(f"\nResult: {len(lines) - fails} ok, {fails} failed")
        return 1 if fails else 0

    if args.command == "explain":
        print(api.explain())
        return 0

    if args.command == "diagnostics":
        print(json.dumps(api.get_diagnostics(), indent=2))
        return 0

    if args.command in ("statistics", "stats"):
        print(json.dumps(api.get_statistics(), indent=2))
        return 0

    if args.command == "logs":
        for line in api.get_logs():
            print(line)
        return 0

    if args.command == "logs-tail":
        for line in api.get_logs(args.n):
            print(line)
        return 0

    if args.command == "status":
        data = api.get_status()
        if not data.get("present"):
            print(data.get("message", "No state"), file=sys.stderr)
            return 1
        print(json.dumps(data, indent=2))
        return 0

    if args.command == "check":
        snap = api.run_check()
        print(json.dumps(snap.to_dict(), indent=2))
        return 0 if snap.diagnosis.value == "HEALTHY" else 1

    return 2


if __name__ == "__main__":
    raise SystemExit(main())
