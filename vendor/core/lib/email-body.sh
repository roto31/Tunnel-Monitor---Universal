#!/bin/bash
# shellcheck shell=bash
# email-body.sh — generic alert/recovery bodies for LAN client

tm_yn() { [[ "$1" == "true" ]] && echo "OK ✓" || echo "FAIL ✗"; }
tm_yn_match() { [[ "$1" == "true" ]] && echo "YES ✓" || echo "NO ✗ — UPDATE DDNS RECORD"; }

tm_build_lan_alert_body() {
    local diagnosis="$1"
    local minutes="$2"
    local hook_extra="${3:-}"

    cat <<EOF
The ${SITE_NAME} tunnel has been down for approximately ${minutes} minutes (LAN client vantage).

Diagnosis: $(tm_diagnosis_human "${diagnosis}")

==============================================
TUNNEL DIAGNOSTICS — $(date '+%Y-%m-%d %H:%M:%S %Z')
==============================================

[ Tunnel Endpoints ]
  Remote LAN gateway:        ${REMOTE_LAN_IP} (over tunnel)
  Remote public IP expected: ${REMOTE_WAN_IP}
  Remote DDNS hostname:      ${REMOTE_DDNS}

[ DNS Resolution ]
  ${REMOTE_DDNS} resolves to: ${TM_DNS_RESOLVED:-<no answer>}
  Expected:                   ${REMOTE_WAN_IP}
  Match:                      $(tm_yn_match "${TM_DNS_MATCH}")

[ Reachability Tests ]
  Ping ${REMOTE_LAN_IP} (tunnel):    $(tm_yn "${TM_TUNNEL_OK}")${TM_TUNNEL_LAT:+ (${TM_TUNNEL_LAT}ms)}
  Ping ${REMOTE_WAN_IP} (internet): $(tm_yn "${TM_WAN_OK}")${TM_WAN_LAT:+ (${TM_WAN_LAT}ms)}
  Ping 1.1.1.1 (local internet):     $(tm_yn "${TM_OUR_OK}")${TM_OUR_LAT:+ (${TM_OUR_LAT}ms)}

[ Gateway Dedup State ]
  Reachable: $([[ "${GATEWAY_REACHABLE:-false}" == "true" ]] && echo YES || echo NO)
  State:     ${GATEWAY_STATE_STR:-<unavailable>}
${hook_extra}
--
tunnel-monitor — ${TM_INSTALL_ROOT:-/opt/tunnel-monitor}
EOF
}

tm_build_lan_recovery_body() {
    cat <<EOF
The ${SITE_NAME} tunnel is back UP (LAN client vantage).

Diagnosis: HEALTHY

==============================================
RECOVERY — $(date '+%Y-%m-%d %H:%M:%S %Z')
==============================================

  Ping ${REMOTE_LAN_IP} (over tunnel): OK ✓${TM_TUNNEL_LAT:+ (${TM_TUNNEL_LAT}ms)}

Monitoring resumed.

--
tunnel-monitor — ${TM_INSTALL_ROOT:-/opt/tunnel-monitor}
EOF
}
