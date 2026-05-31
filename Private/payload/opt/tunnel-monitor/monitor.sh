#!/bin/bash
# =============================================================================
# Gam-and-Bee Tunnel Health Monitor — Mac Studio vantage point
# =============================================================================
# Runs every 5 minutes from /Library/LaunchDaemons/com.ruter.tunnel-monitor.plist
# as root. Pings the remote LAN gateway over the IPsec tunnel, compares with
# direct-internet and DNS sanity checks, and on a confirmed failure crosses
# threshold -> emits an email alert AND a native macOS banner.
#
# This is a SECOND vantage point. The UDR7 runs its own identical-purpose
# monitor; we coordinate via SSH-read of its state file to avoid duplicate
# emails when both sides see the same outage.
#
# Design invariants (do NOT break):
#   - Always exit 0 so launchd does not back off / mark job failed.
#   - state.json writes are atomic (tmp + mv).
#   - Banner dispatch is non-blocking (guarded by timeout in notify.sh).
#   - Never alert on OUR_INTERNET_DOWN — operator is offline anyway.
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.env"
STATE_FILE="${SCRIPT_DIR}/state.json"
LOG_FILE="${SCRIPT_DIR}/monitor.log"
SEND_EMAIL="${SCRIPT_DIR}/send-email.sh"
NOTIFY="${SCRIPT_DIR}/notify.sh"
SSH_UDR7="${SCRIPT_DIR}/ssh-udr7-state.sh"

# Force-zero exit no matter what. launchd treats non-zero as failure and slows
# down the retry interval. Internal errors are logged but do not surface.
trap 'rc=$?; if [[ ${rc} -ne 0 ]]; then echo "[$(timestamp)] [error] monitor.sh exited with code ${rc} at line ${LINENO}" >> "${LOG_FILE}" 2>/dev/null || true; fi; exit 0' EXIT

# -----------------------------------------------------------------------------
# Logging
# -----------------------------------------------------------------------------

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
iso_now()   { date '+%Y-%m-%dT%H:%M:%S%z' | sed -E 's/([+-][0-9]{2})([0-9]{2})$/\1:\2/'; }

log() {
    local level="$1"; shift
    local line
    line="[$(timestamp)] [${level}] $*"
    echo "${line}" >> "${LOG_FILE}" 2>/dev/null || true
}

log_info()  { log "info"  "$@"; }
log_warn()  { log "warn"  "$@"; }
log_error() { log "error" "$@"; }

rotate_log_if_needed() {
    local max="${LOG_MAX_BYTES:-1048576}"
    [[ -f "${LOG_FILE}" ]] || return 0
    local size
    size="$(stat -f '%z' "${LOG_FILE}" 2>/dev/null || echo 0)"
    if [[ "${size}" -gt "${max}" ]]; then
        mv -f -- "${LOG_FILE}" "${LOG_FILE}.1" 2>/dev/null || true
        : > "${LOG_FILE}"
        chmod 0644 "${LOG_FILE}" 2>/dev/null || true
    fi
}

# -----------------------------------------------------------------------------
# Config
# -----------------------------------------------------------------------------

load_config() {
    if [[ ! -f "${CONFIG_FILE}" ]]; then
        log_error "config.env missing at ${CONFIG_FILE}"
        return 2
    fi
    # shellcheck disable=SC1090
    source "${CONFIG_FILE}"

    REMOTE_LAN_IP="${REMOTE_LAN_IP:-192.168.0.1}"
    REMOTE_WAN_IP="${REMOTE_WAN_IP:-75.73.219.205}"
    REMOTE_DDNS="${REMOTE_DDNS:-gamandbeeu.onthewifi.com}"
    FAILURE_THRESHOLD="${FAILURE_THRESHOLD:-3}"
    PING_COUNT="${PING_COUNT:-3}"
    PING_TIMEOUT="${PING_TIMEOUT:-2}"
    NOTIFY_SOUND_DOWN="${NOTIFY_SOUND_DOWN:-Glass}"
    NOTIFY_SOUND_RECOVERY="${NOTIFY_SOUND_RECOVERY:-Hero}"
    LOG_MAX_BYTES="${LOG_MAX_BYTES:-1048576}"
    return 0
}

# -----------------------------------------------------------------------------
# Health checks
# -----------------------------------------------------------------------------

# check_ping <target> -> echoes integer ms (or empty); rc=0 ok, rc=1 fail.
check_ping() {
    local target="$1"
    local timeout_ms=$(( PING_TIMEOUT * 1000 ))
    local out latency=""
    if out="$(ping -c "${PING_COUNT}" -W "${timeout_ms}" -q "${target}" 2>/dev/null)"; then
        # Extract avg from: round-trip min/avg/max/stddev = 11.234/12.345/13.456/0.123 ms
        latency="$(printf '%s\n' "${out}" | awk -F'/' '/min\/avg\/max/ {print $5}' | awk '{print $1}')"
        latency="${latency%.*}"
        printf '%s' "${latency}"
        return 0
    fi
    printf ''
    return 1
}

# resolve_ddns <host> -> echoes first A record; empty on failure
resolve_ddns() {
    local host="$1"
    local r
    r="$(dig +short +time=3 +tries=1 "${host}" @1.1.1.1 2>/dev/null \
            | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' \
            | head -1)"
    printf '%s' "${r}"
}

# -----------------------------------------------------------------------------
# UDR7 dedup
# -----------------------------------------------------------------------------

# Globals populated by query_udr7_state():
#   UDR7_REACHABLE  ("true"/"false")
#   UDR7_STATE_STR  ("N:UP" / "N:DOWN" / "")
#   UDR7_COUNT      (integer; 0 when unreachable)
#   UDR7_ALERT      ("UP"/"DOWN"/""; "" when unreachable)
query_udr7_state() {
    UDR7_REACHABLE="false"
    UDR7_STATE_STR=""
    UDR7_COUNT="0"
    UDR7_ALERT=""

    local out
    if out="$(bash "${SSH_UDR7}" 2>/dev/null)" && [[ -n "${out}" ]]; then
        UDR7_REACHABLE="true"
        UDR7_STATE_STR="${out}"
        UDR7_COUNT="${out%%:*}"
        UDR7_ALERT="${out##*:}"
    fi
}

# -----------------------------------------------------------------------------
# Diagnosis decision tree (apply in order; first match wins)
# -----------------------------------------------------------------------------

compute_diagnosis() {
    # Pre-condition: query_udr7_state has already been called this cycle and
    # UDR7_REACHABLE / UDR7_STATE_STR are populated.
    #
    # Args (booleans as "true"/"false"):
    #   $1 tunnel_ok  $2 remote_wan_ok  $3 our_internet_ok  $4 dns_match
    local tunnel_ok="$1" remote_wan_ok="$2" our_internet_ok="$3" dns_match="$4"

    if [[ "${our_internet_ok}" == "false" ]]; then
        echo "OUR_INTERNET_DOWN"; return
    fi

    if [[ "${tunnel_ok}" == "true" ]]; then
        echo "HEALTHY"; return
    fi

    # Tunnel is down — refine using UDR7 dedup data already collected.
    if [[ "${UDR7_REACHABLE}" == "false" ]]; then
        echo "UDR7_UNREACHABLE"; return
    fi
    if [[ "${UDR7_STATE_STR}" == "0:UP" ]]; then
        echo "DISAGREEMENT"; return
    fi
    if [[ "${dns_match}" == "false" ]]; then
        echo "DDNS_DRIFT"; return
    fi
    if [[ "${remote_wan_ok}" == "false" ]]; then
        echo "REMOTE_INTERNET_DOWN"; return
    fi
    echo "TUNNEL_DOWN"
}

diagnosis_human() {
    case "$1" in
        HEALTHY)              echo "HEALTHY" ;;
        TUNNEL_DOWN)          echo "TUNNEL DOWN" ;;
        DDNS_DRIFT)           echo "DDNS DRIFT — fix No-IP record" ;;
        REMOTE_INTERNET_DOWN) echo "REMOTE INTERNET DOWN" ;;
        OUR_INTERNET_DOWN)    echo "OUR INTERNET DOWN (no alert)" ;;
        UDR7_UNREACHABLE)     echo "UDR7 UNREACHABLE — Mac taking over" ;;
        DISAGREEMENT)         echo "DISAGREEMENT (UDR7 says UP)" ;;
        *)                    echo "$1" ;;
    esac
}

diagnosis_subject() {
    case "$1" in
        TUNNEL_DOWN)          echo "⚠ Gam-and-Bee Tunnel DOWN — TUNNEL DOWN" ;;
        DDNS_DRIFT)           echo "⚠ Gam-and-Bee Tunnel DOWN — DDNS DRIFT — fix No-IP record" ;;
        REMOTE_INTERNET_DOWN) echo "⚠ Gam-and-Bee Tunnel DOWN — REMOTE INTERNET DOWN" ;;
        UDR7_UNREACHABLE)     echo "⚠ Gam-and-Bee Tunnel DOWN — UDR7 UNREACHABLE" ;;
        DISAGREEMENT)         echo "⚠ Gam-and-Bee Tunnel DOWN — DISAGREEMENT (UDR7 says UP)" ;;
        *)                    echo "⚠ Gam-and-Bee Tunnel DOWN — $1" ;;
    esac
}

# -----------------------------------------------------------------------------
# state.json read / write (atomic)
# -----------------------------------------------------------------------------

state_get() {
    # state_get <jq-path> <default>
    local path="$1" default="$2"
    if [[ -f "${STATE_FILE}" ]]; then
        jq -r "${path} // ${default}" "${STATE_FILE}" 2>/dev/null || echo "${default//\"/}"
    else
        echo "${default//\"/}"
    fi
}

write_state_json() {
    # Build via jq -n with --arg/--argjson for safety.
    local now="$1"
    local diagnosis="$2"
    local alert_state="$3"
    local failure_count="$4"
    local last_alert="$5"
    local last_recovery="$6"

    local tunnel_ok="$7" tunnel_latency="$8"
    local wan_ok="$9"    wan_latency="${10}"
    local our_ok="${11}" our_latency="${12}"
    local dns_resolved="${13}" dns_match="${14}"

    local udr7_reachable="${15}" udr7_state="${16}"
    local down_since="${17}"

    local tmp="${STATE_FILE}.tmp.$$"

    # Wrap latency in jq-friendly null when empty.
    j_num() { if [[ -z "$1" ]]; then echo "null"; else echo "$1"; fi; }
    j_str_or_null() { if [[ -z "$1" || "$1" == "null" ]]; then echo "null"; else printf '"%s"' "$1"; fi; }

    if ! jq -n \
            --arg ts "${now}" \
            --arg diag "${diagnosis}" \
            --arg as "${alert_state}" \
            --argjson fc "${failure_count}" \
            --argjson la "$(j_str_or_null "${last_alert}")" \
            --argjson lr "$(j_str_or_null "${last_recovery}")" \
            --arg tt "${REMOTE_LAN_IP}" \
            --argjson tok $([[ "${tunnel_ok}" == "true" ]] && echo true || echo false) \
            --argjson tlat "$(j_num "${tunnel_latency}")" \
            --arg wt "${REMOTE_WAN_IP}" \
            --argjson wok $([[ "${wan_ok}" == "true" ]] && echo true || echo false) \
            --argjson wlat "$(j_num "${wan_latency}")" \
            --arg ot "1.1.1.1" \
            --argjson ook $([[ "${our_ok}" == "true" ]] && echo true || echo false) \
            --argjson olat "$(j_num "${our_latency}")" \
            --arg dh "${REMOTE_DDNS}" \
            --arg dr "${dns_resolved}" \
            --arg de "${REMOTE_WAN_IP}" \
            --argjson dm $([[ "${dns_match}" == "true" ]] && echo true || echo false) \
            --argjson ur $([[ "${udr7_reachable}" == "true" ]] && echo true || echo false) \
            --argjson us "$(j_str_or_null "${udr7_state}")" \
            --arg uc "${now}" \
            --argjson ds "$(j_str_or_null "${down_since}")" \
            '{
              timestamp: $ts,
              alert_state: $as,
              failure_count: $fc,
              down_since: $ds,
              checks: {
                tunnel:       { target: $tt, ok: $tok, latency_ms: $tlat },
                remote_wan:   { target: $wt, ok: $wok, latency_ms: $wlat },
                our_internet: { target: $ot, ok: $ook, latency_ms: $olat },
                dns: {
                  host: $dh,
                  resolved: $dr,
                  expected: $de,
                  match: $dm
                }
              },
              udr7_dedup: {
                reachable: $ur,
                state: $us,
                checked_at: $uc
              },
              last_alert_sent_at:    $la,
              last_recovery_sent_at: $lr,
              diagnosis: $diag
            }' > "${tmp}" 2>>"${LOG_FILE}"; then
        log_error "failed to render state.json"
        rm -f -- "${tmp}"
        return 1
    fi

    if ! mv -f -- "${tmp}" "${STATE_FILE}" 2>/dev/null; then
        log_error "failed to install new state.json"
        rm -f -- "${tmp}"
        return 1
    fi
    chmod 0644 "${STATE_FILE}" 2>/dev/null || true
}

# -----------------------------------------------------------------------------
# Email body builder
# -----------------------------------------------------------------------------

yn() {
    if [[ "$1" == "true" ]]; then echo "OK ✓"; else echo "FAIL ✗"; fi
}

yn_match() {
    if [[ "$1" == "true" ]]; then echo "YES ✓"; else echo "NO ✗ — UPDATE NO-IP RECORD"; fi
}

build_email_body() {
    local diagnosis="$1"
    local minutes="$2"
    local tunnel_ok="$3" tunnel_latency="$4"
    local wan_ok="$5"    wan_latency="$6"
    local our_ok="$7"    our_latency="$8"
    local dns_resolved="$9" dns_match="${10}"
    local udr7_reachable="${11}" udr7_state="${12}"
    local diag_human; diag_human="$(diagnosis_human "${diagnosis}")"

    local local_ip
    local_ip="$(route -n get 1.1.1.1 2>/dev/null | awk '/interface:/ {iface=$2} END {print iface}')"
    [[ -z "${local_ip}" ]] && local_ip="en0"
    local local_ip_v
    local_ip_v="$(ipconfig getifaddr "${local_ip}" 2>/dev/null)"
    [[ -z "${local_ip_v}" ]] && local_ip_v="unknown"

    local udr7_note=""
    case "${diagnosis}" in
        UDR7_UNREACHABLE) udr7_note="UDR7 SSH check failed; Mac alerting unilaterally." ;;
        DISAGREEMENT)     udr7_note="UDR7 reports tunnel UP from its vantage. Mac sees DOWN — investigate Mac-to-UDR7 path." ;;
        *)
            if [[ "${udr7_reachable}" == "true" ]]; then
                case "${udr7_state}" in
                    0:UP)   udr7_note="UDR7 also reports healthy (this is unusual; investigate)." ;;
                    *:UP)   udr7_note="UDR7 counting failures; will alert independently if it persists." ;;
                    *:DOWN) udr7_note="UDR7 already alerted on this outage (email dedup applied)." ;;
                    *)      udr7_note="state string: ${udr7_state}" ;;
                esac
            else
                udr7_note="UDR7 unreachable at config time of this email."
            fi
            ;;
    esac

    cat <<EOF
The Gam-and-Bee site-to-site VPN tunnel has been down for approximately ${minutes} minutes (Mac Studio vantage point).

Diagnosis: ${diag_human}

==============================================
TUNNEL DIAGNOSTICS — $(date '+%Y-%m-%d %H:%M:%S %Z')
==============================================

[ Vantage Point ]
  Source:                    Mac Studio (Banana LAN)
  Local interface:           ${local_ip:-unknown}
  Local IP:                  ${local_ip_v}

[ Tunnel Endpoints ]
  Local site (Banana):       UDR7 @ 192.168.1.1 (LAN)
  Remote site (Gam-and-Bee): UDM  @ ${REMOTE_LAN_IP} (over tunnel)
  Remote public IP expected: ${REMOTE_WAN_IP}
  Remote DDNS hostname:      ${REMOTE_DDNS}

[ DNS Resolution ]
  ${REMOTE_DDNS} currently resolves to: ${dns_resolved:-<no answer>}
  Expected:                                       ${REMOTE_WAN_IP}
  Match:                                          $(yn_match "${dns_match}")

[ Reachability Tests ]
  Ping ${REMOTE_LAN_IP} (over tunnel):       $(yn "${tunnel_ok}")${tunnel_latency:+  (${tunnel_latency}ms)}
  Ping ${REMOTE_WAN_IP} (over internet):     $(yn "${wan_ok}")${wan_latency:+  (${wan_latency}ms)}
  Ping 1.1.1.1 (sanity / our internet):     $(yn "${our_ok}")${our_latency:+  (${our_latency}ms)}

[ UDR7 Dedup State ]
  UDR7 reachable: $([[ "${udr7_reachable}" == "true" ]] && echo "YES" || echo "NO")
  UDR7 state:     ${udr7_state:-<unavailable>}
  Note:           ${udr7_note}

-- 
tunnel-monitor (Mac Studio) — /opt/tunnel-monitor
EOF
}

build_recovery_body() {
    local tunnel_latency="$1"
    cat <<EOF
The Gam-and-Bee site-to-site VPN tunnel is back UP (Mac Studio vantage point).

Diagnosis: HEALTHY

==============================================
RECOVERY — $(date '+%Y-%m-%d %H:%M:%S %Z')
==============================================

  Ping ${REMOTE_LAN_IP} (over tunnel):       OK ✓${tunnel_latency:+  (${tunnel_latency}ms)}

The Mac will resume passive monitoring.

-- 
tunnel-monitor (Mac Studio) — /opt/tunnel-monitor
EOF
}

# -----------------------------------------------------------------------------
# Alert dispatch
# -----------------------------------------------------------------------------

send_alert_email() {
    local subject="$1" body="$2"
    if printf '%s' "${body}" | bash "${SEND_EMAIL}" "${subject}" >>"${LOG_FILE}" 2>&1; then
        log_info "email dispatched: ${subject}"
        return 0
    fi
    log_error "email dispatch FAILED: ${subject}"
    return 1
}

send_banner() {
    local title="$1" body="$2" sound="$3"
    if bash "${NOTIFY}" "${title}" "${body}" "${sound}" >>"${LOG_FILE}" 2>&1; then
        log_info "banner dispatched: ${title} — ${body}"
        return 0
    fi
    log_warn "banner dispatch failed (notification permission may not be granted)"
    return 1
}

# -----------------------------------------------------------------------------
# Subcommands
# -----------------------------------------------------------------------------

cmd_check() {
    rotate_log_if_needed
    load_config || return 0

    local tunnel_latency wan_latency our_latency dns_resolved
    local tunnel_ok="false" wan_ok="false" our_ok="false" dns_match="false"

    if tunnel_latency="$(check_ping "${REMOTE_LAN_IP}")"; then tunnel_ok="true"; fi
    if wan_latency="$(check_ping "${REMOTE_WAN_IP}")";    then wan_ok="true";    fi
    if our_latency="$(check_ping "1.1.1.1")";             then our_ok="true";    fi
    dns_resolved="$(resolve_ddns "${REMOTE_DDNS}")"
    [[ -n "${dns_resolved}" && "${dns_resolved}" == "${REMOTE_WAN_IP}" ]] && dns_match="true"

    # Always query UDR7 (cheap when reachable; ~5s on failure). This keeps the
    # dedup section of state.json populated even when the tunnel is HEALTHY,
    # which the SwiftBar plugin surfaces continuously.
    query_udr7_state

    local diagnosis
    diagnosis="$(compute_diagnosis "${tunnel_ok}" "${wan_ok}" "${our_ok}" "${dns_match}")"

    local prev_state prev_count prev_last_alert prev_last_recovery prev_down_since
    prev_state="$(state_get '.alert_state' '"UP"')"
    prev_count="$(state_get '.failure_count' '0')"
    prev_last_alert="$(state_get '.last_alert_sent_at' 'null')"
    prev_last_recovery="$(state_get '.last_recovery_sent_at' 'null')"
    prev_down_since="$(state_get '.down_since' 'null')"
    [[ "${prev_state}" =~ ^(UP|DOWN)$ ]] || prev_state="UP"
    [[ "${prev_count}" =~ ^[0-9]+$ ]] || prev_count="0"
    [[ "${prev_down_since}" == "null" ]] && prev_down_since=""

    local new_state="${prev_state}"
    local new_count="${prev_count}"
    local new_last_alert="${prev_last_alert}"
    local new_last_recovery="${prev_last_recovery}"
    local new_down_since="${prev_down_since}"

    log_info "check: diagnosis=${diagnosis} tunnel=${tunnel_ok} wan=${wan_ok} our=${our_ok} dns_match=${dns_match} udr7=${UDR7_REACHABLE}:${UDR7_STATE_STR}"

    case "${diagnosis}" in
        HEALTHY)
            if [[ "${prev_state}" == "DOWN" ]]; then
                log_info "RECOVERY: tunnel back up after DOWN state"
                local subj body
                subj="✓ Gam-and-Bee Tunnel RECOVERED"
                body="$(build_recovery_body "${tunnel_latency}")"
                send_alert_email "${subj}" "${body}" || true
                send_banner "Tunnel RECOVERED" "Gam-and-Bee tunnel is back up." "${NOTIFY_SOUND_RECOVERY}" || true
                new_last_recovery="$(iso_now)"
            fi
            new_state="UP"
            new_count="0"
            new_down_since=""
            ;;

        OUR_INTERNET_DOWN)
            # Our internet is offline; we cannot reliably diagnose remote-side
            # state and cannot email anyway. Do not touch the failure counter
            # so we do not spuriously trip after Wi-Fi blips.
            log_warn "OUR_INTERNET_DOWN — suppressing all alerting; counter unchanged"
            ;;

        *)
            if [[ -z "${new_down_since}" ]]; then
                new_down_since="$(iso_now)"
            fi
            new_count=$(( prev_count + 1 ))
            if [[ "${new_count}" -ge "${FAILURE_THRESHOLD}" && "${prev_state}" == "UP" ]]; then
                local email_skip="false"
                # Suppress only when UDR7 reports an active DOWN alert state.
                if [[ "${diagnosis}" != "UDR7_UNREACHABLE" && "${diagnosis}" != "DISAGREEMENT" ]]; then
                    if [[ "${UDR7_REACHABLE}" == "true" && "${UDR7_ALERT}" == "DOWN" ]]; then
                        email_skip="true"
                        log_info "DEDUP: UDR7 already in DOWN state (${UDR7_STATE_STR}); suppressing email"
                    fi
                fi

                local minutes=$(( new_count * 5 ))
                local subj body
                subj="$(diagnosis_subject "${diagnosis}")"
                body="$(build_email_body "${diagnosis}" "${minutes}" \
                            "${tunnel_ok}" "${tunnel_latency}" \
                            "${wan_ok}" "${wan_latency}" \
                            "${our_ok}" "${our_latency}" \
                            "${dns_resolved}" "${dns_match}" \
                            "${UDR7_REACHABLE}" "${UDR7_STATE_STR}")"

                if [[ "${email_skip}" == "false" ]]; then
                    send_alert_email "${subj}" "${body}" || true
                    new_last_alert="$(iso_now)"
                fi

                send_banner "Tunnel DOWN" "$(diagnosis_human "${diagnosis}")" "${NOTIFY_SOUND_DOWN}" || true
                new_state="DOWN"
            elif [[ "${new_count}" -ge "${FAILURE_THRESHOLD}" && "${prev_state}" == "DOWN" ]]; then
                # Still down; no re-alert. Keep DOWN.
                new_state="DOWN"
            fi
            ;;
    esac

    write_state_json \
        "$(iso_now)" \
        "${diagnosis}" \
        "${new_state}" \
        "${new_count}" \
        "${new_last_alert}" \
        "${new_last_recovery}" \
        "${tunnel_ok}" "${tunnel_latency}" \
        "${wan_ok}"    "${wan_latency}" \
        "${our_ok}"    "${our_latency}" \
        "${dns_resolved}" "${dns_match}" \
        "${UDR7_REACHABLE}" "${UDR7_STATE_STR}" \
        "${new_down_since}" || log_error "state.json write failed"

    return 0
}

cmd_diagnose() {
    # Standalone diagnose: prints diagnosis without touching state or alerting.
    load_config || return 0
    local tunnel_latency wan_latency our_latency dns_resolved
    local tunnel_ok="false" wan_ok="false" our_ok="false" dns_match="false"
    if tunnel_latency="$(check_ping "${REMOTE_LAN_IP}")"; then tunnel_ok="true"; fi
    if wan_latency="$(check_ping "${REMOTE_WAN_IP}")";    then wan_ok="true";    fi
    if our_latency="$(check_ping "1.1.1.1")";             then our_ok="true";    fi
    dns_resolved="$(resolve_ddns "${REMOTE_DDNS}")"
    [[ -n "${dns_resolved}" && "${dns_resolved}" == "${REMOTE_WAN_IP}" ]] && dns_match="true"
    query_udr7_state
    local d; d="$(compute_diagnosis "${tunnel_ok}" "${wan_ok}" "${our_ok}" "${dns_match}")"
    echo "diagnosis: ${d}"
    echo "  tunnel(${REMOTE_LAN_IP}): ${tunnel_ok}${tunnel_latency:+ (${tunnel_latency}ms)}"
    echo "  remote_wan(${REMOTE_WAN_IP}): ${wan_ok}${wan_latency:+ (${wan_latency}ms)}"
    echo "  our_internet(1.1.1.1): ${our_ok}${our_latency:+ (${our_latency}ms)}"
    echo "  dns(${REMOTE_DDNS}): resolved=${dns_resolved:-<none>} match=${dns_match}"
    echo "  udr7: reachable=${UDR7_REACHABLE} state=${UDR7_STATE_STR:-<unavailable>}"
}

cmd_notify_test() {
    load_config || return 0
    send_banner "Tunnel TEST" "If you see this, banner notifications work." "${NOTIFY_SOUND_DOWN}"
}

cmd_email_test() {
    load_config || return 0
    local body
    body=$'This is a test email from /opt/tunnel-monitor on the Mac Studio.\n\nIf you received this, SMTP plumbing works.'
    printf '%s' "${body}" | bash "${SEND_EMAIL}" "Tunnel monitor TEST email"
}

show_help() {
    cat <<'EOF'
monitor.sh — Mac Studio vantage-point tunnel health monitor.

USAGE:
  monitor.sh                 Run a full check (default; what launchd invokes)
  monitor.sh check           Same as no-arg invocation
  monitor.sh diagnose        Run checks + print diagnosis without state/alerts
  monitor.sh notify-test     Fire a test banner notification
  monitor.sh email-test      Fire a test email
  monitor.sh --help          This message

This script is normally invoked by launchd every 300 seconds. It always
exits 0 so launchd does not slow its retry interval; internal errors are
written to /opt/tunnel-monitor/monitor.log.
EOF
}

# -----------------------------------------------------------------------------
# Entry point
# -----------------------------------------------------------------------------

case "${1:-check}" in
    -h|--help)     show_help ;;
    check|"")      cmd_check ;;
    diagnose)      cmd_diagnose ;;
    notify-test)   cmd_notify_test ;;
    email-test)    cmd_email_test ;;
    *)             echo "ERROR: unknown subcommand: $1" >&2; show_help >&2; exit 1 ;;
esac
