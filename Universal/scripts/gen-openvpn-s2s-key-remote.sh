#!/usr/bin/env bash
# Generate a UniFi OpenVPN site-to-site static key on the Banana UDR7 over SSH.
# Usage:
#   export UDR7_SSH_HOST=192.168.1.1
#   optional: export UDR7_SSH_USER=root UDR7_SSH_KEY=/opt/tunnel-monitor/.ssh/id_ed25519
#   bash scripts/gen-openvpn-s2s-key-remote.sh [/path/to/outfile.hex]
#
# Outputs 512 lowercase hex chars (no newlines). Never commit the outfile.
set -euo pipefail

UDR7_SSH_HOST="${UDR7_SSH_HOST:-192.168.1.1}"
UDR7_SSH_USER="${UDR7_SSH_USER:-root}"
UDR7_SSH_KEY="${UDR7_SSH_KEY:-}"

show_help() {
  cat <<'EOF'
generate OpenVPN site-to-site static key on Banana UDR7 (ssh + openvpn)

USAGE
  bash scripts/gen-openvpn-s2s-key-remote.sh [OUTPUT_FILE]

ENVIRONMENT
  UDR7_SSH_HOST   SSH target host (default: 192.168.1.1)
  UDR7_SSH_USER   SSH username (default: root)
  UDR7_SSH_KEY    SSH private key path (optional)

If OUTPUT_FILE is omitted, prints key to stdout.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi

SSH_BASE=(ssh -o BatchMode=yes -o ConnectTimeout="${SSH_CONNECT_TIMEOUT:-10}" "${UDR7_SSH_USER}@${UDR7_SSH_HOST}")
if [[ -n "${UDR7_SSH_KEY}" ]]; then
  SSH_BASE+=(-o StrictHostKeyChecking=accept-new -i "${UDR7_SSH_KEY}")
fi

key="$("${SSH_BASE[@]}" bash -s <<'REMOTE'
openvpn --genkey secret 2>/dev/null | egrep -o '[0-9a-f]{32}' | tr -d '\n'
REMOTE
)" || {
  echo "ERROR: failed to generate key on ${UDR7_SSH_USER}@${UDR7_SSH_HOST}" >&2
  exit 1
}

[[ "${#key}" -eq 512 ]] || {
  echo "ERROR: expected key length 512 chars, got ${#key}" >&2
  exit 1
}

if [[ "${#}" -ge 1 && -n "${1}" ]]; then
  outfile="${1}"
  tmp="${outfile}.tmp.$$"
  umask 077
  printf '%s' "${key}" >"${tmp}"
  mv -f "${tmp}" "${outfile}"
  chmod 600 "${outfile}" || true
  echo "Wrote OpenVPN key to ${outfile} (mode 0600)." >&2
else
  printf '%s\n' "${key}"
fi
