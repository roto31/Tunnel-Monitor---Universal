#!/bin/bash
# shellcheck shell=bash
# state-line.sh — gateway N:UP / N:DOWN file

tm_read_state_line() {
    local state_file="$1"
    if [[ -f "${state_file}" ]]; then
        tr -d '[:space:]' < "${state_file}"
    else
        printf '0:UP'
    fi
}

tm_write_state_line() {
    local state_file="$1"
    local value="$2"
    local tmp="${state_file}.tmp.$$"
    printf '%s\n' "${value}" > "${tmp}"
    mv -f "${tmp}" "${state_file}"
}
