#!/usr/bin/env bash
# sync-check.sh — Verify wopr-plugin-types/src/ matches wopr/src/plugin-types/
#
# Usage:
#   ./scripts/sync-check.sh /path/to/wopr/src/plugin-types
#
# Exits 0 if in sync, 1 if drift detected.

set -euo pipefail

CORE_DIR="${1:?Usage: $0 <path-to-wopr/src/plugin-types>}"
EXT_DIR="$(cd "$(dirname "$0")/../src" && pwd)"

if [ ! -d "$CORE_DIR" ]; then
  echo "ERROR: Core directory not found: $CORE_DIR"
  exit 1
fi

DRIFT=0

for file in "$EXT_DIR"/*.ts; do
  base="$(basename "$file")"
  core_file="$CORE_DIR/$base"

  if [ ! -f "$core_file" ]; then
    echo "DRIFT: $base exists in plugin-types but not in core"
    DRIFT=1
    continue
  fi

  if ! diff -q "$core_file" "$file" > /dev/null 2>&1; then
    echo "DRIFT: $base differs between core and plugin-types"
    diff -U 3 "$core_file" "$file" || true
    DRIFT=1
  fi
done

# Check for files in core that are missing from plugin-types
for file in "$CORE_DIR"/*.ts; do
  base="$(basename "$file")"
  if [ ! -f "$EXT_DIR/$base" ]; then
    echo "DRIFT: $base exists in core but not in plugin-types"
    DRIFT=1
  fi
done

if [ "$DRIFT" -eq 0 ]; then
  echo "OK: All types are in sync with core"
  exit 0
else
  echo ""
  echo "FAILED: Type drift detected. Run:"
  echo "  cp \"$CORE_DIR\"/*.ts \"$EXT_DIR/\""
  echo "to sync from core."
  exit 1
fi
