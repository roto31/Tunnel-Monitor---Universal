#!/bin/bash
# =============================================================================
# monitor.sh — UniFi gateway (thin wrapper around tunnel-monitor-core)
# =============================================================================
set -u

SCRIPT_DIR="/data/tunnel-monitor"
ENGINE="${SCRIPT_DIR}/bin/monitor-engine.sh"
ADAPTER_DIR="${SCRIPT_DIR}/adapter"

if [[ ! -f "${ENGINE}" ]]; then
    logger -t tunnel-monitor -p user.err "monitor-engine.sh missing; re-run install.sh"
    echo "ERROR: monitor-engine.sh missing at ${ENGINE}" >&2
    exit 1
fi

exec bash "${ENGINE}" \
    --role gateway \
    --install-root "${SCRIPT_DIR}" \
    --adapter-dir "${ADAPTER_DIR}" \
    check
