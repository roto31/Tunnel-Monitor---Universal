#!/bin/bash
# validate-folder-structure.sh — verify Private/Public/Universal monorepo layout
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
STRICT="${TM_STRUCTURE_STRICT:-0}"

errors=0
warnings=0

err() {
    printf 'ERROR: %s\n' "$*" >&2
    errors=$((errors + 1))
}

warn() {
    printf 'WARN: %s\n' "$*" >&2
    warnings=$((warnings + 1))
}

ok() {
    printf 'OK: %s\n' "$*"
}

report() {
    if [[ "${errors}" -gt 0 ]]; then
        printf '\nStructure validation failed: %d error(s), %d warning(s)\n' "${errors}" "${warnings}" >&2
        exit 1
    fi
    if [[ "${warnings}" -gt 0 && "${STRICT}" == "1" ]]; then
        printf '\nStructure validation failed (strict): %d warning(s)\n' "${warnings}" >&2
        exit 1
    fi
    printf '\nStructure validation passed (%d warning(s))\n' "${warnings}"
}

show_help() {
    cat <<'EOF'
validate-folder-structure.sh — verify Tunnel Monitor monorepo folder layout

USAGE
    bash Universal/scripts/validate-folder-structure.sh
    TM_STRUCTURE_STRICT=1 bash Universal/scripts/validate-folder-structure.sh

Exit codes: 0 pass, 1 failure, 2 usage/config error
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    show_help
    exit 0
fi

cd "${REPO_ROOT}"

# Required top-level category folders
for dir in Private Public Universal; do
    if [[ ! -d "${dir}" ]]; then
        err "missing top-level ${dir}/"
    fi
done

# Required meta files per category
for pair in \
    "Private/VERSION" \
    "Private/datasets/bundle-manifest.json" \
    "Private/builds/releases/README.md" \
    "Public/VERSION" \
    "Public/datasets/bundle-manifest.json" \
    "Public/builds/releases/README.md" \
    "Universal/VERSION" \
    "Universal/datasets/bundle-manifest.json" \
    "Universal/builds/releases/README.md" \
    "Public/wiki/README.md" \
    "Universal/docs/wiki/README.md"; do
    if [[ ! -f "${pair}" ]]; then
        err "missing required file: ${pair}"
    fi
done

# Forbidden legacy roots (warn during migration compat period; error in strict)
legacy_roots=(app vendor adapters scripts internal tunnel-monitor-core datasets Library opt)
for legacy in "${legacy_roots[@]}"; do
    if [[ -e "${legacy}" ]]; then
        if [[ "${STRICT}" == "1" ]]; then
            err "legacy root path must not exist: ${legacy}/"
        else
            warn "legacy root path still present: ${legacy}/"
        fi
    fi
done

legacy_doc_paths=(
    private-docs-repo
    private-docs-wiki
    tunnel-monitor-cursor-prompt
    .wiki-publish
    .wiki-uni-tunnel-monitor
)
for legacy in "${legacy_doc_paths[@]}"; do
    if [[ -e "${legacy}" ]]; then
        if [[ "${STRICT}" == "1" ]]; then
            err "docs/wiki must live under Private/, Public/, or Universal/: ${legacy}/"
        else
            warn "move ${legacy}/ into category folder (see folder-structure rule)"
        fi
    fi
done

for legacy_doc in CURSOR_PROMPT.md HOW_TO_USE.md REFERENCE_APPENDIX.md tunnel-monitor.mdc; do
    if [[ -f "${legacy_doc}" ]]; then
        err "move ${legacy_doc} to Private/docs/cursor-prompt/"
    fi
done

for legacy_script in install.sh verify.sh uninstall.sh; do
    if [[ -f "${legacy_script}" ]]; then
        if grep -q "DEPRECATED: use Private/install/" "${legacy_script}" 2>/dev/null; then
            ok "compat shim present: ${legacy_script}"
        elif [[ "${STRICT}" == "1" ]]; then
            err "root ${legacy_script} must be a compat shim or removed"
        else
            warn "root ${legacy_script} should forward to Private/install/"
        fi
    fi
done

# Release folder naming
release_re='^[0-9]{2}-v[0-9]+\.[0-9]+\.[0-9]+$'
for category in Private Public Universal; do
    releases_dir="${category}/builds/releases"
    [[ -d "${releases_dir}" ]] || continue
    while IFS= read -r -d '' entry; do
        base="$(basename "${entry}")"
        [[ "${base}" == "README.md" ]] && continue
        if [[ ! "${base}" =~ ${release_re} ]]; then
            err "invalid release folder name in ${releases_dir}/: ${base}"
        fi
    done < <(find "${releases_dir}" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
done

# Manifest sync (skip Universal when releases list is empty)
sync_manifest() {
    local category="$1"
    local manifest="${category}/datasets/bundle-manifest.json"
    local releases_dir="${category}/builds/releases"

    if [[ ! -f "${manifest}" ]] || ! command -v jq >/dev/null 2>&1; then
        warn "skipping manifest sync for ${category} (missing manifest or jq)"
        return
    fi

    local release_count
    release_count="$(jq '.releases | length' "${manifest}")"
    if [[ "${category}" == "Universal" && "${release_count}" == "0" ]]; then
        ok "Universal manifest has no releases (scaffold)"
        return
    fi

    while IFS= read -r folder; do
        [[ -z "${folder}" || "${folder}" == "null" ]] && continue
        if [[ ! -d "${releases_dir}/${folder}" ]]; then
            err "manifest folder missing on disk: ${releases_dir}/${folder}"
        fi
    done < <(jq -r '.releases[].folder' "${manifest}")

    while IFS= read -r -d '' dir; do
        base="$(basename "${dir}")"
        [[ "${base}" == "README.md" ]] && continue
        if ! jq -e --arg f "${base}" '.releases[] | select(.folder == $f)' "${manifest}" >/dev/null; then
            err "release folder not in ${manifest}: ${base}"
        fi
    done < <(find "${releases_dir}" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
}

sync_manifest Private
sync_manifest Public
sync_manifest Universal

# VERSION alignment for Universal
if [[ -f Universal/VERSION && -f Universal/vendor/core/VERSION ]]; then
    u_ver="$(tr -d '[:space:]' < Universal/VERSION)"
    c_ver="$(tr -d '[:space:]' < Universal/vendor/core/VERSION)"
    if [[ "${u_ver}" != "${c_ver}" ]]; then
        err "Universal/VERSION (${u_ver}) != Universal/vendor/core/VERSION (${c_ver})"
    else
        ok "Universal/VERSION matches vendor/core"
    fi
fi

# No config.env in tracked tree (excluding templates)
while IFS= read -r -d '' cfg; do
    if [[ "${cfg}" != *".template" ]]; then
        err "config.env must not be committed: ${cfg}"
    fi
done < <(find Private Public Universal -name 'config.env' -print0 2>/dev/null)

# Public must not contain obvious private-doc references at root of Public/
if [[ -d Public ]]; then
    if find Public -name 'config.env' ! -name '*.template' 2>/dev/null | grep -q .; then
        err "Public/ contains committed config.env"
    fi
fi

# Cursor enforcement artifacts
for artifact in \
    ".cursor/rules/tunnel-monitor-folder-structure.mdc" \
    ".cursor/skills/tunnel-monitor-organization/SKILL.md"; do
    if [[ ! -f "${artifact}" ]]; then
        err "missing enforcement artifact: ${artifact}"
    fi
done

report
