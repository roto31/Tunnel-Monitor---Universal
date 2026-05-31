from __future__ import annotations

import argparse
import json
import sys

from uvpn.adapters.registry import list_adapters
from uvpn.core.config import DEFAULT_CONFIG_PATH, MonitorConfig
from uvpn.core.engine import MonitorEngine


def _print_snapshot(snapshot) -> None:
    print(json.dumps(snapshot.to_dict(), indent=2))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="uvpn", description="Universal VPN Monitor CLI")
    parser.add_argument("--config", type=str, default=str(DEFAULT_CONFIG_PATH))
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("check", help="Run one monitoring cycle")
    sub.add_parser("status", help="Show last state.json")
    sub.add_parser("explain", help="Print runbook for current diagnosis")
    sub.add_parser("preflight", help="Dependency and config checks")
    sub.add_parser("adapters", help="List registered VPN adapters")

    init_p = sub.add_parser("init-config", help="Write example config.json")
    init_p.add_argument("--force", action="store_true")

    args = parser.parse_args(argv)
    cfg = MonitorConfig.load(DEFAULT_CONFIG_PATH if args.config == str(DEFAULT_CONFIG_PATH) else __import__("pathlib").Path(args.config))
    engine = MonitorEngine(cfg)

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
        fails, lines = engine.preflight()
        for line in lines:
            print(line)
        print(f"\nResult: {len(lines) - fails} ok, {fails} failed")
        return 1 if fails else 0

    if args.command == "explain":
        print(engine.explain())
        return 0

    if args.command == "status":
        data = engine.store.read()
        if not data:
            print("No state file yet. Run: uvpn check", file=sys.stderr)
            return 1
        print(json.dumps(data, indent=2))
        return 0

    if args.command == "check":
        snap = engine.run_check()
        _print_snapshot(snap)
        return 0 if snap.diagnosis.value == "HEALTHY" else 1

    return 2


if __name__ == "__main__":
    raise SystemExit(main())
