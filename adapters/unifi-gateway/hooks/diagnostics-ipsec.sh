#!/bin/bash
# diagnostics-ipsec.sh — UniFi gateway email diagnostics hook
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "UniFi ipsec/strongSwan diagnostics block for alert emails"
    exit 0
fi

resolved_ip=""
resolved_ip="$(dig +short +time=3 +tries=1 "${REMOTE_DDNS:-remote.example.com}" @1.1.1.1 2>/dev/null | head -1)"

cat <<EOF
[ IPsec Status ]
$(ipsec statusall 2>/dev/null | grep -E "(ESTABLISHED|CONNECTING|INSTALLED|Security Associations|^[a-f0-9]{20,}:)" | head -20 || echo "  ipsec statusall returned no relevant output")

[ Recent strongSwan Log (last 15 lines) ]
$(journalctl --no-pager -n 15 2>/dev/null | grep -i charon || echo "  No recent charon log entries")

[ DNS at alert time ]
  ${REMOTE_DDNS:-?} -> ${resolved_ip:-FAILED} (expected ${REMOTE_WAN_IP:-?})
EOF
