#!/bin/bash
# =============================================================================
# monitor-engine.sh — tunnel-monitor-core entry point
# =============================================================================
set -uo pipefail

TM_CORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TM_ROLE=""
TM_ADAPTER_DIR=""
TM_INSTALL_ROOT=""
TM_CONFIG_FILE=""
TM_STATE_FILE=""
TM_LOG_FILE=""
TM_SEND_EMAIL=""
TM_NOTIFY=""

# Always exit 0 for schedulers unless explicit subcommand errors
trap 'rc=$?; if [[ ${rc} -ne 0 && "${TM_TRAP_EXIT0:-true}" == "true" ]]; then tm_log_error "engine exited ${rc} at line ${LINENO}" 2>/dev/null; exit 0; fi; exit ${rc}' EXIT

tm_source_core() {
    # shellcheck source=/dev/null
    source "${TM_CORE_DIR}/lib/common.sh"
    # shellcheck source=/dev/null
    source "${TM_CORE_DIR}/lib/checks.sh"
    # shellcheck source=/dev/null
    source "${TM_CORE_DIR}/lib/diagnosis.sh"
    # shellcheck source=/dev/null
    source "${TM_CORE_DIR}/lib/dedup.sh"
    # shellcheck source=/dev/null
    source "${TM_CORE_DIR}/lib/state-json.sh"
    # shellcheck source=/dev/null
    source "${TM_CORE_DIR}/lib/state-line.sh"
    # shellcheck source=/dev/null
    source "${TM_CORE_DIR}/lib/email-body.sh"
}

tm_show_help() {
    cat <<EOF
monitor-engine.sh — tunnel-monitor-core engine

USAGE
    monitor-engine.sh --role gateway|lan_client --install-root PATH [options] [subcommand]

OPTIONS
    --role ROLE           gateway or lan_client (required)
    --install-root PATH   Install root (e.g. /opt/tunnel-monitor or /data/tunnel-monitor)
    --adapter-dir PATH    Adapter hooks directory (optional)
    --config PATH         config.env path (default: INSTALL_ROOT/config.env)

SUBCOMMANDS
    check          Full check cycle (default)
    diagnose       Print diagnosis only
    notify-test    Test notify hook
    email-test     Test email
    ssh-test       Test gateway SSH dedup (lan_client)
    --help

Always exits 0 from check path for launchd/systemd compatibility.
EOF
}

tm_parse_args() {
    TM_SUBCMD="check"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --role) TM_ROLE="$2"; shift 2 ;;
            --install-root) TM_INSTALL_ROOT="$2"; shift 2 ;;
            --adapter-dir) TM_ADAPTER_DIR="$2"; shift 2 ;;
            --config) TM_CONFIG_FILE="$2"; shift 2 ;;
            --help|-h) tm_show_help; exit 0 ;;
            check|diagnose|notify-test|email-test|ssh-test)
                TM_SUBCMD="$1"; shift ;;
            *) echo "ERROR: unknown argument: $1" >&2; tm_show_help >&2; exit 1 ;;
        esac
    done

    if [[ -z "${TM_ROLE}" || -z "${TM_INSTALL_ROOT}" ]]; then
        echo "ERROR: --role and --install-root are required" >&2
        exit 2
    fi

    TM_CONFIG_FILE="${TM_CONFIG_FILE:-${TM_INSTALL_ROOT}/config.env}"
    TM_LOG_FILE="${TM_INSTALL_ROOT}/monitor.log"
    TM_SEND_EMAIL="${TM_INSTALL_ROOT}/send-email.sh"
    TM_NOTIFY="${TM_INSTALL_ROOT}/notify.sh"
    TM_SSH_GATEWAY_SCRIPT="${TM_INSTALL_ROOT}/ssh-gateway-state.sh"
    if [[ ! -f "${TM_SSH_GATEWAY_SCRIPT}" ]]; then
        for alt in ssh-router-state.sh ssh-udr7-state.sh; do
            if [[ -f "${TM_INSTALL_ROOT}/${alt}" ]]; then
                TM_SSH_GATEWAY_SCRIPT="${TM_INSTALL_ROOT}/${alt}"
                break
            fi
        done
    fi

    if [[ "${TM_ROLE}" == "lan_client" ]]; then
        TM_STATE_FILE="${TM_INSTALL_ROOT}/state.json"
    else
        TM_STATE_FILE="${TM_INSTALL_ROOT}/state"
    fi
}

tm_run_hook() {
    local hook_name="$1"
    shift
    local hook_path=""
    if [[ -n "${TM_ADAPTER_DIR}" && -f "${TM_ADAPTER_DIR}/hooks/${hook_name}" ]]; then
        hook_path="${TM_ADAPTER_DIR}/hooks/${hook_name}"
    elif [[ -f "${TM_INSTALL_ROOT}/hooks/${hook_name}" ]]; then
        hook_path="${TM_INSTALL_ROOT}/hooks/${hook_name}"
    else
        return 0
    fi
    bash "${hook_path}" "$@"
}

tm_send_email_payload() {
    local subject="$1"
    local body="$2"
    if [[ ! -f "${TM_SEND_EMAIL}" ]]; then
        tm_log_error "send-email.sh missing"
        return 1
    fi
    if [[ "${TM_ROLE}" == "gateway" ]]; then
        bash "${TM_SEND_EMAIL}" "${subject}" "${body}" >>"${TM_LOG_FILE}" 2>&1
        return $?
    fi
    local body_file
    body_file="$(mktemp -t tm-email.XXXXXX)"
    printf '%s' "${body}" > "${body_file}"
    bash "${TM_SEND_EMAIL}" "${subject}" "${body_file}" >>"${TM_LOG_FILE}" 2>&1
    local rc=$?
    rm -f "${body_file}"
    return "${rc}"
}

tm_send_email_body() {
    tm_send_email_payload "$1" "$2"
}

tm_send_email_stdin() {
    tm_send_email_payload "$1" "$2"
}

tm_notify_banner() {
    local title="$1"
    local body="$2"
    local sound="${3:-}"
    if [[ -x "${TM_NOTIFY}" ]]; then
        bash "${TM_NOTIFY}" "${title}" "${body}" "${sound}" >>"${TM_LOG_FILE}" 2>&1 || true
    fi
}

tm_lan_client_check() {
    tm_rotate_log_if_needed
    tm_load_config "${TM_CONFIG_FILE}" || return 0

    tm_run_health_checks
    tm_query_gateway_dedup

    local diagnosis
    diagnosis="$(tm_compute_diagnosis "${TM_TUNNEL_OK}" "${TM_WAN_OK}" "${TM_OUR_OK}" "${TM_DNS_MATCH}")"

    local prev_state prev_count prev_last_alert prev_last_recovery prev_down_since
    prev_state="$(tm_state_get '.alert_state' '"UP"')"
    prev_count="$(tm_state_get '.failure_count' '0')"
    prev_last_alert="$(tm_state_get '.last_alert_sent_at' 'null')"
    prev_last_recovery="$(tm_state_get '.last_recovery_sent_at' 'null')"
    prev_down_since="$(tm_state_get '.down_since' 'null')"
    [[ "${prev_state}" =~ ^(UP|DOWN)$ ]] || prev_state="UP"
    [[ "${prev_count}" =~ ^[0-9]+$ ]] || prev_count="0"
    [[ "${prev_down_since}" == "null" ]] && prev_down_since=""

    local new_state="${prev_state}"
    local new_count="${prev_count}"
    local new_last_alert="${prev_last_alert}"
    local new_last_recovery="${prev_last_recovery}"
    local new_down_since="${prev_down_since}"
    local now
    now="$(tm_iso_now)"

    tm_log_info "check: diagnosis=${diagnosis} tunnel=${TM_TUNNEL_OK} wan=${TM_WAN_OK} gateway=${GATEWAY_REACHABLE}:${GATEWAY_STATE_STR:-}"

    case "${diagnosis}" in
        HEALTHY)
            if [[ "${prev_state}" == "DOWN" ]]; then
                local subj body
                subj="✓ ${SITE_NAME} Tunnel RECOVERED"
                body="$(tm_build_lan_recovery_body)"
                tm_send_email_stdin "${subj}" "${body}" || true
                tm_notify_banner "Tunnel RECOVERED" "${SITE_NAME} tunnel is back up." "${NOTIFY_SOUND_RECOVERY:-Hero}"
                new_last_recovery="${now}"
            fi
            new_state="UP"
            new_count="0"
            new_down_since=""
            ;;
        OUR_INTERNET_DOWN)
            tm_log_warn "OUR_INTERNET_DOWN — counter unchanged"
            ;;
        *)
            [[ -z "${new_down_since}" ]] && new_down_since="${now}"
            new_count=$(( prev_count + 1 ))
            if [[ "${new_count}" -ge "${FAILURE_THRESHOLD}" && "${prev_state}" == "UP" ]]; then
                local hook_extra=""
                hook_extra="$(tm_run_hook diagnostics.sh 2>/dev/null || true)"
                local minutes=$(( new_count * CHECK_INTERVAL_MIN ))
                local subj body
                subj="$(tm_diagnosis_subject "${diagnosis}")"
                body="$(tm_build_lan_alert_body "${diagnosis}" "${minutes}" "${hook_extra}")"
                if ! tm_should_suppress_email "${diagnosis}"; then
                    tm_send_email_stdin "${subj}" "${body}" || true
                    new_last_alert="${now}"
                else
                    tm_log_info "DEDUP: gateway already DOWN; suppressing email"
                fi
                tm_notify_banner "Tunnel DOWN" "$(tm_diagnosis_human "${diagnosis}")" "${NOTIFY_SOUND_DOWN:-Glass}"
                tm_run_hook post_alert.sh "${diagnosis}" "${new_count}" || true
                new_state="DOWN"
            elif [[ "${new_count}" -ge "${FAILURE_THRESHOLD}" ]]; then
                new_state="DOWN"
            fi
            ;;
    esac

    tm_write_state_json "${now}" "${diagnosis}" "${new_state}" "${new_count}" \
        "${new_last_alert}" "${new_last_recovery}" "${new_down_since}" || true
}

tm_lan_client_diagnose() {
    tm_load_config "${TM_CONFIG_FILE}" || return 0
    tm_run_health_checks
    tm_query_gateway_dedup
    local d
    d="$(tm_compute_diagnosis "${TM_TUNNEL_OK}" "${TM_WAN_OK}" "${TM_OUR_OK}" "${TM_DNS_MATCH}")"
    echo "diagnosis: ${d}"
    echo "  tunnel(${REMOTE_LAN_IP}): ${TM_TUNNEL_OK}${TM_TUNNEL_LAT:+ (${TM_TUNNEL_LAT}ms)}"
    echo "  remote_wan(${REMOTE_WAN_IP}): ${TM_WAN_OK}${TM_WAN_LAT:+ (${TM_WAN_LAT}ms)}"
    echo "  gateway: reachable=${GATEWAY_REACHABLE} state=${GATEWAY_STATE_STR:-<n/a>}"
    TM_TRAP_EXIT0=false
}

tm_gateway_check() {
    tm_load_config "${TM_CONFIG_FILE}" || exit 1
    TM_LOG_STDOUT=true

    local state_file="${TM_STATE_FILE}"
    local state_raw fail_count alert_state
    state_raw="$(tm_read_state_line "${state_file}")"
    fail_count="${state_raw%%:*}"
    alert_state="${state_raw##*:}"

    local tunnel_ok=0 wan_ok=0
    tm_check_ping_bool "${REMOTE_LAN_IP}" && tunnel_ok=1
    tm_check_ping_bool "${REMOTE_WAN_IP}" && wan_ok=1

    local send_email="${TM_INSTALL_ROOT}/send-email.sh"
    local hook_diag=""

    if [[ ${tunnel_ok} -eq 1 ]]; then
        if [[ "${alert_state}" == "DOWN" ]]; then
            tm_log_info "Tunnel RECOVERED"
            hook_diag="$(tm_run_hook diagnostics.sh 2>/dev/null || true)"
            local subj body
            subj="${SUBJECT_PREFIX:+${SUBJECT_PREFIX} }✓ Site-to-site Tunnel RECOVERED"
            body="$(printf 'Tunnel recovered.\n\n%s' "${hook_diag}")"
            tm_send_email_body "${subj}" "${body}" || true
            tm_write_state_line "${state_file}" "0:UP"
        else
            [[ "${fail_count}" -ne 0 ]] && tm_log_info "Tunnel healthy; reset counter"
            tm_write_state_line "${state_file}" "0:UP"
        fi
    else
        local new_fail=$(( fail_count + 1 ))
        if [[ ${new_fail} -ge ${FAILURE_THRESHOLD} && "${alert_state}" == "UP" ]]; then
            local diag_text="TUNNEL DOWN"
            if [[ ${wan_ok} -eq 0 ]]; then
                diag_text="REMOTE INTERNET DOWN"
            else
                local resolved
                resolved="$(tm_resolve_ddns)"
                if [[ "${resolved}" != "${REMOTE_WAN_IP}" ]]; then
                    diag_text="DDNS DRIFT — fix your DDNS provider record"
                fi
            fi
            hook_diag="$(tm_run_hook diagnostics.sh 2>/dev/null || true)"
            local subj body
            subj="${SUBJECT_PREFIX:+${SUBJECT_PREFIX} }⚠ Site-to-site Tunnel DOWN — ${diag_text}"
            body="$(printf 'Tunnel down ~%d minutes.\n\nDiagnosis: %s\n\n%s' \
                "$(( new_fail * CHECK_INTERVAL_MIN ))" "${diag_text}" "${hook_diag}")"
            tm_send_email_body "${subj}" "${body}" || true
            tm_write_state_line "${state_file}" "${new_fail}:DOWN"
        elif [[ "${alert_state}" == "DOWN" ]]; then
            tm_log_warn "Still DOWN (${new_fail}); no re-alert"
            tm_write_state_line "${state_file}" "${new_fail}:DOWN"
        else
            tm_log_info "Ping failed (${new_fail}/${FAILURE_THRESHOLD}); counting"
            tm_write_state_line "${state_file}" "${new_fail}:UP"
        fi
    fi
    TM_TRAP_EXIT0=false
}

tm_main() {
    tm_source_core
    tm_parse_args "$@"

    case "${TM_SUBCMD}" in
        check)
            if [[ "${TM_ROLE}" == "lan_client" ]]; then
                tm_lan_client_check
            else
                tm_gateway_check
            fi
            ;;
        diagnose)
            if [[ "${TM_ROLE}" == "lan_client" ]]; then
                tm_lan_client_diagnose
            else
                echo "diagnose not implemented for gateway role" >&2
                exit 1
            fi
            ;;
        notify-test)
            tm_load_config "${TM_CONFIG_FILE}" || exit 0
            tm_notify_banner "Tunnel TEST" "Test notification" "${NOTIFY_SOUND_DOWN:-Glass}"
            TM_TRAP_EXIT0=false
            ;;
        email-test)
            tm_load_config "${TM_CONFIG_FILE}" || exit 0
            tm_send_email_stdin "Tunnel monitor TEST" "Test email from monitor-engine.sh"
            TM_TRAP_EXIT0=false
            ;;
        ssh-test)
            tm_load_config "${TM_CONFIG_FILE}" || exit 0
            tm_query_gateway_dedup
            echo "gateway: reachable=${GATEWAY_REACHABLE} state=${GATEWAY_STATE_STR:-<n/a>}"
            TM_TRAP_EXIT0=false
            ;;
    esac
}

tm_main "$@"
