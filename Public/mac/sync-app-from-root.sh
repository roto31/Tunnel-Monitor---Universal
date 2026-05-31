#!/bin/bash
# DEPRECATED: use Public/mac/sync-app-from-private.sh
set -euo pipefail
echo "WARN: sync-app-from-root.sh is deprecated; use sync-app-from-private.sh" >&2
exec bash "$(dirname "$0")/sync-app-from-private.sh" "$@"
