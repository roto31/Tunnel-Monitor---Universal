#!/bin/bash
# shellcheck shell=bash
# operator-explain.sh — diagnosis runbooks (aligned with GUI DiagnosisReference.swift)

tm_normalize_diagnosis() {
    case "$1" in
        UDR7_UNREACHABLE|ROUTER_UNREACHABLE) printf 'GATEWAY_UNREACHABLE' ;;
        RESET|PENDING_FIRST_RUN) printf 'UNKNOWN' ;;
        *) printf '%s' "$1" ;;
    esac
}

tm_explain_diagnosis() {
    local code
    code="$(tm_normalize_diagnosis "${1:-UNKNOWN}")"
    case "${code}" in
        HEALTHY)
            cat <<'EOF'
Summary: All probes passed; tunnel LAN reachable.

Technical: Decision tree stopped at tunnel ping OK. Gateway dedup may still
show N:DOWN while the tunnel is up — email is suppressed in that case.

Steps:
  1. No action required.
  2. Optional: tunnel-check --preflight
EOF
            ;;
        OUR_INTERNET_DOWN)
            cat <<'EOF'
Summary: Local internet down; failure counter frozen; no tunnel alert.

Technical: Probe to 1.1.1.1 failed before tunnel logic. Alerts are suppressed
until local internet recovers.

Steps:
  1. Fix local internet (router, ISP, DNS).
  2. Force Check after recovery.
EOF
            ;;
        GATEWAY_UNREACHABLE)
            cat <<'EOF'
Summary: Gateway SSH dedup failed; this LAN client owns alerting.

Technical: Tunnel ping failed and SSH to the gateway sidecar did not return a
valid state line.

Steps:
  1. Ping gateway LAN IP; run tunnel-check --ssh-test
  2. Allow LAN to gateway TCP 22 on firewall
  3. On gateway: confirm sidecar monitor and state file
  4. Clear known_hosts if the host key changed
EOF
            ;;
        DISAGREEMENT)
            cat <<'EOF'
Summary: Gateway reports tunnel UP (0:UP) but LAN cannot reach remote LAN.

Technical: VPN SA may show established while policy routing or remote LAN
firewall blocks ICMP over the tunnel.

Steps:
  1. On gateway: verify VPN status
  2. Compare ping to REMOTE_LAN_IP from gateway vs this Mac
  3. Review policy routes and VPN interface binding
  4. Bounce VPN on gateway if SA looks stale
EOF
            ;;
        DDNS_DRIFT)
            cat <<'EOF'
Summary: DDNS hostname does not match configured remote WAN IP.

Technical: After a WAN IP change, peers keyed on hostname may dial wrong address
until DDNS or REMOTE_WAN_IP is corrected.

Steps:
  1. Resolve DDNS from this Mac and compare to REMOTE_WAN_IP
  2. Update DDNS A record or config.env
EOF
            ;;
        REMOTE_INTERNET_DOWN)
            cat <<'EOF'
Summary: Remote site WAN unreachable from this vantage.

Technical: REMOTE_WAN_IP ICMP failed. Some sites filter inbound ICMP.

Steps:
  1. Confirm remote site power and ISP status
  2. If ICMP is filtered, treat WAN probe with caution
EOF
            ;;
        TUNNEL_DOWN)
            cat <<'EOF'
Summary: Remote WAN and DDNS OK but tunnel LAN ping failed.

Technical: VPN data plane issue. WAN reachable does not imply IKE or tunnel
interface is working.

Steps:
  1. Inspect gateway VPN logs (charon / UniFi VPN)
  2. Verify PSK/certs and peer addresses on both gateways
  3. Force Check after changes
EOF
            ;;
        *)
            cat <<'EOF'
Summary: No stable diagnosis yet.

Technical: State may be reset or awaiting first daemon cycle (every 5 minutes).

Steps:
  1. Run tunnel-check --preflight
  2. Force Check, then review again
EOF
            ;;
    esac
}

tm_run_preflight() {
    local ok=0
    local fail=0

    _pf_ok() { printf '  OK   %s\n' "$1"; ok=$(( ok + 1 )); }
    _pf_fail() { printf '  FAIL %s\n' "$1"; fail=$(( fail + 1 )); }

    printf 'Tunnel Monitor preflight\n\n'

    for cmd in jq ping dig bash; do
        if command -v "${cmd}" >/dev/null 2>&1; then
            _pf_ok "${cmd} found"
        else
            _pf_fail "${cmd} missing"
        fi
    done

    if [[ -f "${INSTALL_DIR:-/opt/tunnel-monitor}/config.env" ]]; then
        _pf_ok "config.env exists"
        # shellcheck source=/dev/null
        if source "${INSTALL_DIR:-/opt/tunnel-monitor}/config.env" 2>/dev/null; then
            [[ -n "${REMOTE_LAN_IP:-}" && "${REMOTE_LAN_IP}" != REPLACE_WITH_* ]] \
                && _pf_ok "REMOTE_LAN_IP set" || _pf_fail "REMOTE_LAN_IP placeholder"
            [[ -n "${SMTP_PASSWORD:-}" && "${SMTP_PASSWORD}" != REPLACE_WITH_* ]] \
                && _pf_ok "SMTP_PASSWORD set" || _pf_fail "SMTP_PASSWORD placeholder"
        fi
    else
        _pf_fail "config.env missing"
    fi

    if [[ -x "${INSTALL_DIR:-/opt/tunnel-monitor}/monitor.sh" ]]; then
        _pf_ok "monitor.sh executable"
    else
        _pf_fail "monitor.sh missing or not executable"
    fi

    if [[ -f "${STATE_FILE:-/opt/tunnel-monitor/state.json}" ]]; then
        _pf_ok "state.json present"
    else
        _pf_fail "state.json missing (daemon may not have run)"
    fi

    printf '\nResult: %s passed, %s failed\n' "${ok}" "${fail}"
    [[ "${fail}" -eq 0 ]]
}
