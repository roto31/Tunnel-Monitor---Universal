#!/bin/bash
# =============================================================================
# vendor-core.sh — pin / verify vendored tunnel-monitor-core version
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
UNIVERSAL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE_SRC="${UNIVERSAL_ROOT}/vendor/core"
MANIFEST="${REPO_ROOT}/bundle-manifest.json"

show_help() {
    cat <<'EOF'
vendor-core.sh — tunnel-monitor-core vendoring helper

USAGE
    vendor-core.sh version          Print vendored core VERSION
    vendor-core.sh verify           Verify bundle-manifest coreVersion matches VERSION
    vendor-core.sh sync-publish DIR Copy vendor/core to tunnel-monitor-core publish tree

For remote tarball fetch (when core repo exists on GitHub):
    vendor-core.sh fetch TAG DEST   Placeholder — copies local vendor/core to DEST
EOF
}

cmd_version() {
    cat "${CORE_SRC}/VERSION"
}

cmd_verify() {
    local vendored expected
    vendored="$(tr -d '[:space:]' < "${CORE_SRC}/VERSION")"
    if [[ ! -f "${MANIFEST}" ]]; then
        echo "WARN: ${MANIFEST} missing" >&2
        echo "${vendored}"
        return 0
    fi
    expected="$(jq -r '.coreVersion // empty' "${MANIFEST}")"
    if [[ -z "${expected}" ]]; then
        echo "WARN: coreVersion not set in manifest" >&2
        return 0
    fi
    if [[ "${vendored}" != "${expected}" ]]; then
        echo "ERROR: vendor/core VERSION (${vendored}) != bundle-manifest coreVersion (${expected})" >&2
        return 1
    fi
    echo "OK: coreVersion ${vendored}"
}

cmd_sync_publish() {
    local dest="$1"
    if [[ -z "${dest}" ]]; then
        echo "ERROR: DEST required" >&2
        exit 2
    fi
    mkdir -p "${dest}"
    rsync -a --delete \
        --exclude '.git' \
        "${CORE_SRC}/" "${dest}/"
    echo "Synced ${CORE_SRC} -> ${dest}"
}

cmd_fetch() {
    local tag="$1"
    local dest="$2"
    echo "WARN: fetch uses local vendor/core (tag ${tag} not resolved remotely)" >&2
    cmd_sync_publish "${dest}"
}

case "${1:-}" in
    --help|-h|help) show_help ;;
    version) cmd_version ;;
    verify) cmd_verify ;;
    sync-publish) cmd_sync_publish "${2:-}" ;;
    fetch) cmd_fetch "${2:-}" "${3:-}" ;;
    *)
        echo "ERROR: unknown subcommand: ${1:-}" >&2
        show_help >&2
        exit 1
        ;;
esac
