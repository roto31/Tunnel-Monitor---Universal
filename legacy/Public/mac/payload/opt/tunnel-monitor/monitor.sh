#!/bin/bash
# =============================================================================
# monitor.sh — Mac LAN client (thin wrapper around tunnel-monitor-core)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENGINE="${SCRIPT_DIR}/bin/monitor-engine.sh"
ADAPTER_DIR="${SCRIPT_DIR}/adapter"

if [[ ! -x "${ENGINE}" ]]; then
    echo "ERROR: monitor-engine.sh missing at ${ENGINE}" >&2
    echo "       Re-run install.sh to deploy tunnel-monitor-core." >&2
    exit 1
fi

subcmd="${1:-check}"
case "${subcmd}" in
    -h|--help)
        exec bash "${ENGINE}" --help
        ;;
    check|"") subcmd="check" ;;
esac

exec bash "${ENGINE}" \
    --role lan_client \
    --install-root "${SCRIPT_DIR}" \
    --adapter-dir "${ADAPTER_DIR}" \
    "${subcmd}" "${@:2}"
