#!/bin/bash
# =============================================================================
# install-core.sh — deploy tunnel-monitor-core lib + engine into an install root
# =============================================================================
set -euo pipefail

install_tunnel_monitor_core() {
    local install_root="$1"
    local repo_root="${2:-}"

    if [[ -z "${repo_root}" ]]; then
        repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    fi

    local core_src=""
    if [[ -d "${repo_root}/vendor/core" ]]; then
        core_src="${repo_root}/vendor/core"
    elif [[ -d "${repo_root}/Universal/vendor/core" ]]; then
        core_src="${repo_root}/Universal/vendor/core"
    else
        core_src="${repo_root}/vendor/core"
    fi
    if [[ ! -d "${core_src}/lib" || ! -f "${core_src}/bin/monitor-engine.sh" ]]; then
        echo "ERROR: vendor/core not found under ${repo_root}" >&2
        return 1
    fi

    mkdir -p "${install_root}/lib" "${install_root}/bin"
    install -m 0755 "${core_src}/bin/monitor-engine.sh" "${install_root}/bin/monitor-engine.sh"
    for f in "${core_src}/lib/"*.sh; do
        [[ -f "${f}" ]] || continue
        install -m 0644 "${f}" "${install_root}/lib/$(basename "${f}")"
    done
    if [[ -d "${core_src}/lib/dedup" ]]; then
        mkdir -p "${install_root}/lib/dedup"
        for f in "${core_src}/lib/dedup/"*.sh; do
            [[ -f "${f}" ]] || continue
            install -m 0644 "${f}" "${install_root}/lib/dedup/$(basename "${f}")"
        done
    fi
    if [[ -f "${core_src}/VERSION" ]]; then
        install -m 0644 "${core_src}/VERSION" "${install_root}/core.version"
    fi
    return 0
}

install_lan_adapter() {
    local install_root="$1"
    local adapter_src="$2"
    mkdir -p "${install_root}/adapter"
    if [[ -f "${adapter_src}/adapter.manifest.json" ]]; then
        install -m 0644 "${adapter_src}/adapter.manifest.json" "${install_root}/adapter/adapter.manifest.json"
    fi
    if [[ -d "${adapter_src}/hooks" ]]; then
        mkdir -p "${install_root}/adapter/hooks"
        for h in "${adapter_src}/hooks/"*; do
            [[ -f "${h}" ]] || continue
            install -m 0755 "${h}" "${install_root}/adapter/hooks/$(basename "${h}")"
        done
    fi
}

install_gateway_adapter() {
    local install_root="$1"
    local adapter_src="$2"
    install_lan_adapter "${install_root}" "${adapter_src}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 1 ]]; then
        echo "Usage: install-core.sh INSTALL_ROOT [REPO_ROOT]" >&2
        exit 2
    fi
    install_tunnel_monitor_core "$1" "${2:-}"
fi
