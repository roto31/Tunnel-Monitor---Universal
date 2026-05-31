#!/bin/bash
# =============================================================================
# tunnel-monitor.30s.sh — SwiftBar plugin for the Mac tunnel monitor
# =============================================================================
# SwiftBar refreshes plugins by their filename: ".30s." => every 30 seconds.
# This plugin is a STATUS DISPLAY ONLY: it reads /opt/tunnel-monitor/state.json
# and renders the menu bar icon + dropdown. The actual health check runs in
# the LaunchDaemon every 5 minutes; the plugin never invokes its own checks.
# =============================================================================
# <bitbar.title>Gam-and-Bee Tunnel Monitor</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Chris Ruter</bitbar.author>
# <bitbar.author.github>roto1231</bitbar.author.github>
# <bitbar.desc>Reads /opt/tunnel-monitor/state.json and shows tunnel health.</bitbar.desc>
# <bitbar.dependencies>jq</bitbar.dependencies>
# =============================================================================

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

STATE_FILE="/opt/tunnel-monitor/state.json"
LOG_FILE="/opt/tunnel-monitor/monitor.log"
TUNNEL_CHECK="/usr/local/bin/tunnel-check"
NOIP_URL="https://my.noip.com/dynamic-dns/hostnames"

print_action_items() {
    echo "---"
    echo "Refresh now | bash=${TUNNEL_CHECK} param1=--check-now terminal=false refresh=true"
    echo "Test email | bash=${TUNNEL_CHECK} param1=--test-email terminal=false"
    echo "Test notification | bash=${TUNNEL_CHECK} param1=--test-notify terminal=false"
    echo "Open log | bash=/usr/bin/open param1=${LOG_FILE} terminal=false"
    echo "View status in terminal | bash=${TUNNEL_CHECK} terminal=true"
}

# --- Sad path: no jq -------------------------------------------------------
if ! command -v jq >/dev/null 2>&1; then
    echo "⚪️ jq?"
    echo "---"
    echo "jq is not installed | color=red"
    echo "Install: brew install jq"
    print_action_items
    exit 0
fi

# --- Sad path: no state.json ----------------------------------------------
if [[ ! -f "${STATE_FILE}" ]]; then
    echo "⚪️ ?"
    echo "---"
    echo "Tunnel monitor has not run yet | color=gray"
    echo "Expected file: ${STATE_FILE} | color=gray size=11"
    print_action_items
    exit 0
fi

# --- Sad path: unparseable state.json -------------------------------------
if ! jq -e . "${STATE_FILE}" >/dev/null 2>&1; then
    echo "⚪️ ?"
    echo "---"
    echo "state.json unparseable | color=red"
    echo "Path: ${STATE_FILE} | color=gray size=11"
    print_action_items
    exit 0
fi

# --- Pull state ------------------------------------------------------------
DIAGNOSIS="$(jq -r '.diagnosis // "UNKNOWN"' "${STATE_FILE}")"
ALERT_STATE="$(jq -r '.alert_state // "UP"'  "${STATE_FILE}")"
FAILURE_COUNT="$(jq -r '.failure_count // 0' "${STATE_FILE}")"
TIMESTAMP="$(jq -r '.timestamp // ""'        "${STATE_FILE}")"
THRESHOLD="${TUNNEL_MONITOR_THRESHOLD:-3}"

TUNNEL_OK="$(jq -r '.checks.tunnel.ok'       "${STATE_FILE}")"
TUNNEL_TGT="$(jq -r '.checks.tunnel.target // ""' "${STATE_FILE}")"
TUNNEL_LAT="$(jq -r '.checks.tunnel.latency_ms // ""' "${STATE_FILE}")"

RWAN_OK="$(jq -r '.checks.remote_wan.ok'     "${STATE_FILE}")"
RWAN_TGT="$(jq -r '.checks.remote_wan.target // ""'   "${STATE_FILE}")"
RWAN_LAT="$(jq -r '.checks.remote_wan.latency_ms // ""' "${STATE_FILE}")"

OUR_OK="$(jq -r '.checks.our_internet.ok'    "${STATE_FILE}")"
OUR_TGT="$(jq -r '.checks.our_internet.target // "1.1.1.1"' "${STATE_FILE}")"
OUR_LAT="$(jq -r '.checks.our_internet.latency_ms // ""' "${STATE_FILE}")"

DNS_HOST="$(jq -r '.checks.dns.host // ""'     "${STATE_FILE}")"
DNS_RESOLVED="$(jq -r '.checks.dns.resolved // ""' "${STATE_FILE}")"
DNS_EXPECTED="$(jq -r '.checks.dns.expected // ""' "${STATE_FILE}")"
DNS_MATCH="$(jq -r '.checks.dns.match'         "${STATE_FILE}")"

UDR7_REACH="$(jq -r '.udr7_dedup.reachable'  "${STATE_FILE}")"
UDR7_STATE="$(jq -r '.udr7_dedup.state // ""' "${STATE_FILE}")"

LAST_ALERT="$(jq -r    '.last_alert_sent_at    // "never"' "${STATE_FILE}")"
LAST_RECOVERY="$(jq -r '.last_recovery_sent_at // "never"' "${STATE_FILE}")"

# --- Compute menu-bar title ----------------------------------------------
case "${ALERT_STATE}" in
    DOWN)
        case "${DIAGNOSIS}" in
            DDNS_DRIFT)           TITLE="🔴 DOWN · DDNS" ;;
            UDR7_UNREACHABLE)     TITLE="🔴 DOWN · UDR7?" ;;
            DISAGREEMENT)         TITLE="🔴 DOWN · DISAGREE" ;;
            REMOTE_INTERNET_DOWN) TITLE="🔴 DOWN · REMOTE NET" ;;
            *)                    TITLE="🔴 DOWN" ;;
        esac
        ;;
    UP)
        case "${DIAGNOSIS}" in
            HEALTHY)
                TITLE="🟢"
                ;;
            OUR_INTERNET_DOWN)
                TITLE="⚪️ OFFLINE"
                ;;
            *)
                if (( FAILURE_COUNT > 0 )); then
                    TITLE="🟡 ${FAILURE_COUNT}/${THRESHOLD}"
                else
                    TITLE="🟢"
                fi
                ;;
        esac
        ;;
    *)
        TITLE="⚪️ ?"
        ;;
esac

echo "${TITLE}"
echo "---"

# --- Diagnosis line -------------------------------------------------------
case "${ALERT_STATE}" in
    DOWN)
        echo "⚠ Tunnel ${ALERT_STATE} — ${DIAGNOSIS} | size=14 color=red"
        ;;
    UP)
        if [[ "${DIAGNOSIS}" == "HEALTHY" ]]; then
            echo "Tunnel HEALTHY | size=14 color=green"
        elif [[ "${DIAGNOSIS}" == "OUR_INTERNET_DOWN" ]]; then
            echo "Local internet appears DOWN | size=14 color=gray"
        else
            echo "Counting failures: ${FAILURE_COUNT}/${THRESHOLD} — ${DIAGNOSIS} | size=14 color=orange"
        fi
        ;;
esac

if [[ -n "${TIMESTAMP}" ]]; then
    echo "Last check: ${TIMESTAMP} | color=gray size=11"
fi
echo "---"

# --- Per-check lines ------------------------------------------------------
fmt_check() {
    local name="$1" target="$2" ok="$3" latency="$4"
    if [[ "${ok}" == "true" ]]; then
        echo "✓ ${name} (${target}): ${latency}ms | color=green"
    else
        echo "✗ ${name} (${target}): unreachable | color=red"
    fi
}

fmt_check "Tunnel"       "${TUNNEL_TGT:-?}" "${TUNNEL_OK}" "${TUNNEL_LAT:-?}"
fmt_check "Remote WAN"   "${RWAN_TGT:-?}"   "${RWAN_OK}"   "${RWAN_LAT:-?}"
fmt_check "Our internet" "${OUR_TGT:-?}"    "${OUR_OK}"    "${OUR_LAT:-?}"

if [[ "${DNS_MATCH}" == "true" ]]; then
    echo "✓ DNS: ${DNS_RESOLVED} matches ${DNS_EXPECTED} | color=green"
else
    echo "✗ DNS: resolves to ${DNS_RESOLVED:-<none>} (expected ${DNS_EXPECTED:-?}) | color=red"
fi

# --- UDR7 dedup -----------------------------------------------------------
if [[ "${UDR7_REACH}" == "true" ]]; then
    case "${UDR7_STATE}" in
        0:UP)
            echo "✓ UDR7 dedup: ${UDR7_STATE} (healthy) | color=green"
            ;;
        *:DOWN)
            echo "● UDR7 dedup: ${UDR7_STATE} (UDR7 already alerted) | color=yellow"
            ;;
        *:UP)
            echo "● UDR7 dedup: ${UDR7_STATE} (counting) | color=yellow"
            ;;
        *)
            echo "● UDR7 dedup: ${UDR7_STATE:-?} | color=gray"
            ;;
    esac
else
    echo "✗ UDR7 dedup: unreachable | color=red"
fi

# --- DDNS drift fix shortcut ---------------------------------------------
if [[ "${DNS_MATCH}" != "true" ]]; then
    echo "---"
    echo "🔧 Fix No-IP record | href=${NOIP_URL} color=orange"
fi

echo "---"
echo "Last alert:    ${LAST_ALERT}"
echo "Last recovery: ${LAST_RECOVERY}"

print_action_items
