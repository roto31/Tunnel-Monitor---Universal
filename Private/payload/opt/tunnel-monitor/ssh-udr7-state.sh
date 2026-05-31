#!/bin/bash
# =============================================================================
# ssh-udr7-state.sh — read the UDR7 monitor's state file via SSH for dedup
# =============================================================================
# Prints the UDR7 state line ("N:UP" / "N:DOWN") to stdout on success.
# Exits non-zero if SSH fails, the key is unauthorized, or the remote file is
# missing — monitor.sh treats any non-zero exit as "UDR7 unreachable".
#
# Exit codes:
#   0  success (state line printed)
#   1  ssh failure or empty/unparseable remote state
#   2  config error (missing config.env or required vars)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.env"

show_help() {
    cat <<'EOF'
ssh-udr7-state.sh — read UDR7 tunnel-monitor state for dedup decisions

USAGE
    ssh-udr7-state.sh
    ssh-udr7-state.sh --help

OUTPUT
    Prints the UDR7 state line (e.g. "0:UP", "3:DOWN") to stdout. Exits
    non-zero if SSH fails or the remote file is missing.

CONFIG
    Reads UDR7_HOST, UDR7_USER, UDR7_KEY, UDR7_STATE_PATH from config.env.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    show_help
    exit 0
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "ERROR: config file missing: ${CONFIG_FILE}" >&2
    exit 2
fi

# shellcheck disable=SC1090
source "${CONFIG_FILE}"

UDR7_HOST="${UDR7_HOST:-192.168.1.1}"
UDR7_USER="${UDR7_USER:-root}"
UDR7_KEY="${UDR7_KEY:-/opt/tunnel-monitor/.ssh/id_ed25519}"
UDR7_STATE_PATH="${UDR7_STATE_PATH:-/data/tunnel-monitor/state}"

if [[ ! -f "${UDR7_KEY}" ]]; then
    echo "ERROR: SSH key missing: ${UDR7_KEY}" >&2
    exit 2
fi

# StrictHostKeyChecking=accept-new: trust on first use, fail on key change.
# BatchMode=yes: never prompt for a password (would block the daemon forever).
state_line="$(
    ssh -o BatchMode=yes \
        -o ConnectTimeout=5 \
        -o ServerAliveInterval=3 \
        -o ServerAliveCountMax=2 \
        -o StrictHostKeyChecking=accept-new \
        -o UserKnownHostsFile="${SCRIPT_DIR}/.ssh/known_hosts" \
        -i "${UDR7_KEY}" \
        "${UDR7_USER}@${UDR7_HOST}" \
        "cat ${UDR7_STATE_PATH} 2>/dev/null" 2>/dev/null
)" || {
    echo "ERROR: ssh to ${UDR7_USER}@${UDR7_HOST} failed" >&2
    exit 1
}

state_line="$(printf '%s' "${state_line}" | tr -d '[:space:]')"

if [[ -z "${state_line}" ]]; then
    echo "ERROR: UDR7 state file empty or missing" >&2
    exit 1
fi

if [[ ! "${state_line}" =~ ^[0-9]+:(UP|DOWN)$ ]]; then
    echo "ERROR: UDR7 state line malformed: '${state_line}'" >&2
    exit 1
fi

printf '%s\n' "${state_line}"
exit 0
