#!/bin/bash
# diagnostics.sh — generic-linux gateway (no VPN CLI diagnostics)
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Generic reachability summary for gateway alert emails"
    exit 0
fi

cat <<EOF
[ Reachability summary ]
  Tunnel ping (${REMOTE_LAN_IP:-?}): ${TUNNEL_OK:-unknown}
  Remote WAN (${REMOTE_WAN_IP:-?}): ${REMOTE_WAN_OK:-unknown}
  Local internet (1.1.1.1): ${OUR_INTERNET_OK:-unknown}
  DDNS ${REMOTE_DDNS:-?} match: ${DNS_MATCH:-unknown}
EOF
