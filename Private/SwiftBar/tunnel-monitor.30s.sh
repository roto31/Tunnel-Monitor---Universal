#!/bin/bash
# =============================================================================
# tunnel-monitor.30s.sh — SwiftBar plugin
# =============================================================================
# Refresh interval: 30 seconds (encoded in the filename per SwiftBar's
# `<name>.<duration>.<ext>` convention).
#
# This plugin is a status display ONLY. It does not run health checks. It
# reads /opt/tunnel-monitor/state.json (single source of truth, written by
# the launchd daemon) and renders SwiftBar output.
#
# Actions in the dropdown shell out to /usr/local/bin/tunnel-check.
# =============================================================================

# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>false</swiftbar.hideDisablePlugin>

set -uo pipefail

STATE_FILE="/opt/tunnel-monitor/state.json"
LOG_FILE="/opt/tunnel-monitor/monitor.log"
TUNNEL_CHECK="/usr/local/bin/tunnel-check"

emit_unknown() {
    local why="$1"
    echo "⚪️ ?"
    echo "---"
    echo "Tunnel monitor: ${why} | color=gray size=12"
    echo "---"
    echo "Open install instructions | href=file:///opt/tunnel-monitor/README.md"
    echo "Refresh now (requires sudo) | bash=${TUNNEL_CHECK} param1=--check-now terminal=true"
    exit 0
}

if ! command -v jq >/dev/null 2>&1; then
    emit_unknown "jq not installed (brew install jq)"
fi

if [[ ! -f "${STATE_FILE}" ]]; then
    emit_unknown "state.json missing — daemon has not run yet"
fi

if ! jq empty "${STATE_FILE}" 2>/dev/null; then
    emit_unknown "state.json unparseable"
fi

DIAG="$(jq -r '.diagnosis // "UNKNOWN"' "${STATE_FILE}")"
ALERT="$(jq -r '.alert_state // "UP"' "${STATE_FILE}")"
FC="$(jq -r '.failure_count // 0' "${STATE_FILE}")"
TS="$(jq -r '.timestamp // "never"' "${STATE_FILE}")"
LAST_ALERT="$(jq -r '.last_alert_sent_at // "never"' "${STATE_FILE}")"
LAST_RECOVERY="$(jq -r '.last_recovery_sent_at // "never"' "${STATE_FILE}")"

T_TARGET="$(jq -r '.checks.tunnel.target // "—"' "${STATE_FILE}")"
T_OK="$(jq -r '.checks.tunnel.ok // false' "${STATE_FILE}")"
T_LAT="$(jq -r '.checks.tunnel.latency_ms // empty' "${STATE_FILE}")"

W_TARGET="$(jq -r '.checks.remote_wan.target // "—"' "${STATE_FILE}")"
W_OK="$(jq -r '.checks.remote_wan.ok // false' "${STATE_FILE}")"
W_LAT="$(jq -r '.checks.remote_wan.latency_ms // empty' "${STATE_FILE}")"

O_TARGET="$(jq -r '.checks.our_internet.target // "—"' "${STATE_FILE}")"
O_OK="$(jq -r '.checks.our_internet.ok // false' "${STATE_FILE}")"
O_LAT="$(jq -r '.checks.our_internet.latency_ms // empty' "${STATE_FILE}")"

D_HOST="$(jq -r '.checks.dns.host // "—"' "${STATE_FILE}")"
D_RESOLVED="$(jq -r '.checks.dns.resolved // "<none>"' "${STATE_FILE}")"
D_EXPECTED="$(jq -r '.checks.dns.expected // "—"' "${STATE_FILE}")"
D_MATCH="$(jq -r '.checks.dns.match // false' "${STATE_FILE}")"

U_REACH="$(jq -r '.udr7_dedup.reachable // false' "${STATE_FILE}")"
U_STATE="$(jq -r '.udr7_dedup.state // "<unavailable>"' "${STATE_FILE}")"

case "${ALERT}" in
    DOWN) MENU_TITLE="🔴 DOWN" ;;
    UP)
        if [[ "${FC}" != "0" ]]; then
            MENU_TITLE="🟡 ${FC}/3"
        else
            MENU_TITLE="🟢"
        fi
        ;;
    *) MENU_TITLE="⚪️ ?" ;;
esac

short_time() {
    local s="$1"
    if [[ "${s}" == "never" || "${s}" == "null" || -z "${s}" ]]; then
        echo "never"
        return
    fi
    if [[ "${s}" =~ T([0-9]{2}:[0-9]{2}:[0-9]{2}) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "${s}"
    fi
}

check_line() {
    local label="$1" target="$2" ok="$3" detail="$4"
    if [[ "${ok}" == "true" ]]; then
        echo "✓ ${label} (${target}): ${detail} | color=green"
    else
        echo "✗ ${label} (${target}): ${detail} | color=red"
    fi
}

t_detail() {
    if [[ "${1}" == "true" ]]; then
        if [[ -n "${2}" && "${2}" != "null" ]]; then echo "${2}ms"; else echo "ok"; fi
    else
        echo "unreachable"
    fi
}

dns_detail() {
    if [[ "${D_MATCH}" == "true" ]]; then
        echo "${D_RESOLVED} matches"
    else
        echo "resolves to ${D_RESOLVED} (expected ${D_EXPECTED})"
    fi
}

udr7_color() {
    if [[ "${U_REACH}" != "true" ]]; then echo "red"; return; fi
    case "${U_STATE}" in
        0:UP)   echo "green" ;;
        *:UP)   echo "yellow" ;;
        *:DOWN) echo "yellow" ;;
        *)      echo "gray" ;;
    esac
}

udr7_descr() {
    if [[ "${U_REACH}" != "true" ]]; then echo "UNREACHABLE"; return; fi
    case "${U_STATE}" in
        0:UP)   echo "${U_STATE} (healthy)" ;;
        *:UP)   echo "${U_STATE} (counting; not yet alerted)" ;;
        *:DOWN) echo "${U_STATE} (UDR7 already alerted)" ;;
        *)      echo "${U_STATE}" ;;
    esac
}

udr7_mark() {
    if [[ "${U_REACH}" == "true" ]]; then echo "✓"; else echo "✗"; fi
}

echo "${MENU_TITLE}"
echo "---"

case "${ALERT}" in
    DOWN)
        echo "⚠ Tunnel DOWN — ${DIAG} | size=14 color=red"
        ;;
    *)
        if [[ "${DIAG}" == "HEALTHY" ]]; then
            echo "Tunnel HEALTHY | size=14"
        else
            echo "Tunnel ${ALERT} — ${DIAG} | size=14 color=orange"
        fi
        ;;
esac

echo "Last check: $(short_time "${TS}") | color=gray size=12"
echo "---"

check_line "Tunnel"          "${T_TARGET}" "${T_OK}" "$(t_detail "${T_OK}" "${T_LAT}")"
check_line "Remote internet" "${W_TARGET}" "${W_OK}" "$(t_detail "${W_OK}" "${W_LAT}")"
check_line "Our internet"    "${O_TARGET}" "${O_OK}" "$(t_detail "${O_OK}" "${O_LAT}")"
if [[ "${D_MATCH}" == "true" ]]; then
    echo "✓ DNS (${D_HOST}): $(dns_detail) | color=green"
else
    echo "✗ DNS (${D_HOST}): $(dns_detail) | color=red"
fi
echo "$(udr7_mark) UDR7 dedup: $(udr7_descr) | color=$(udr7_color)"

if [[ "${D_MATCH}" != "true" && "${ALERT}" == "DOWN" ]]; then
    echo "---"
    echo "🔧 Fix No-IP record | href=https://my.noip.com/dynamic-dns/hostnames color=orange"
fi

echo "---"
echo "Last alert:    $(short_time "${LAST_ALERT}") | color=gray"
echo "Last recovery: $(short_time "${LAST_RECOVERY}") | color=gray"
echo "Failure count: ${FC} | color=gray"
echo "---"
echo "Refresh now | bash=${TUNNEL_CHECK} param1=--check-now terminal=false refresh=true"
echo "Test email | bash=${TUNNEL_CHECK} param1=--test-email terminal=false"
echo "Test notification | bash=${TUNNEL_CHECK} param1=--test-notify terminal=false"
echo "Open log | bash=/usr/bin/open param1=${LOG_FILE} terminal=false"
echo "View full status in terminal | bash=${TUNNEL_CHECK} terminal=true"
