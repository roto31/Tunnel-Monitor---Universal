from __future__ import annotations

import argparse
import logging
import os
import sys


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="uvpn-statusd",
        description="Read-only status portal for uvpn (private overlay; requires [portal] extra)",
    )
    parser.add_argument(
        "--bind",
        default=os.environ.get("UVPN_STATUS_BIND", "127.0.0.1:8080"),
        help="Host:port (default 127.0.0.1:8080 or UVPN_STATUS_BIND)",
    )
    parser.add_argument(
        "--config",
        default="",
        help="Optional path to config.json (sets UVPN_CONFIG_DIR parent)",
    )
    args = parser.parse_args(argv)

    if args.config:
        from pathlib import Path

        os.environ.setdefault("UVPN_CONFIG_DIR", str(Path(args.config).parent))

    from uvpn.security.auth import load_bearer_token

    if not load_bearer_token():
        print(
            "ERROR: Set UVPN_STATUS_TOKEN or UVPN_STATUS_TOKEN_FILE (mode 0600)",
            file=sys.stderr,
        )
        return 2

    logging.basicConfig(
        level=logging.INFO,
        format="%(message)s",
    )

    try:
        import uvicorn
    except ImportError:
        print("ERROR: pip install 'uvpn[portal]'", file=sys.stderr)
        return 3

    from uvpn.interfaces.statusd.app import create_app

    host, _, port_str = args.bind.rpartition(":")
    if not host:
        host, port_str = "127.0.0.1", args.bind
    port = int(port_str)

    app = create_app()
    uvicorn.run(app, host=host, port=port, log_level="info", access_log=False)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
