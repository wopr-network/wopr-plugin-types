#!/usr/bin/env bash
# sync-check.sh — Verify wopr-plugin-types/src/ matches wopr/src/plugin-types/
#
# Usage:
#   ./scripts/sync-check.sh /path/to/wopr/src/plugin-types
#
# Exits 0 if in sync, 1 if drift detected.
#
# Known adaptations handled automatically:
#   - StorageApi import path: ../storage/api/plugin-storage.js → ./storage.js
#   - storage.ts is sourced from wopr/src/storage/api/plugin-storage.ts (not plugin-types/)

set -euo pipefail

CORE_DIR="${1:?Usage: $0 <path-to-wopr/src/plugin-types>}"
EXT_DIR="$(cd "$(dirname "$0")/../src" && pwd)"
# storage.ts is sourced from the parent storage directory, not plugin-types/
STORAGE_SRC="$(cd "$CORE_DIR/../.." && pwd)/src/storage/api/plugin-storage.ts"

if [ ! -d "$CORE_DIR" ]; then
  echo "ERROR: Core directory not found: $CORE_DIR"
  exit 1
fi

# Normalize known import path differences before diffing
normalize_imports() {
  sed 's|from "\.\./storage/api/plugin-storage\.js"|from "./storage.js"|g'
}

DRIFT=0

# Check standard files (direct copies with import normalization)
for file in "$CORE_DIR"/*.ts; do
  base="$(basename "$file")"
  ext_file="$EXT_DIR/$base"

  if [ ! -f "$ext_file" ]; then
    echo "DRIFT: $base exists in core but not in plugin-types"
    DRIFT=1
    continue
  fi

  if ! diff -q <(normalize_imports < "$file") "$ext_file" > /dev/null 2>&1; then
    echo "DRIFT: $base differs between core and plugin-types"
    diff -U 3 <(normalize_imports < "$file") "$ext_file" || true
    DRIFT=1
  fi
done

# Check storage.ts against core's plugin-storage.ts (sourced from different location)
if [ -f "$STORAGE_SRC" ]; then
  if [ ! -f "$EXT_DIR/storage.ts" ]; then
    echo "DRIFT: storage.ts missing from plugin-types (source: $STORAGE_SRC)"
    DRIFT=1
  elif ! diff -q "$STORAGE_SRC" "$EXT_DIR/storage.ts" > /dev/null 2>&1; then
    echo "DRIFT: storage.ts differs from core plugin-storage.ts"
    diff -U 3 "$STORAGE_SRC" "$EXT_DIR/storage.ts" || true
    DRIFT=1
  fi
else
  echo "WARNING: Core storage source not found at $STORAGE_SRC — skipping storage.ts check"
fi

# Check for extra files in plugin-types that don't exist in core
for file in "$EXT_DIR"/*.ts; do
  base="$(basename "$file")"
  if [ "$base" = "storage.ts" ]; then
    continue  # storage.ts is sourced from a different location in core
  fi
  if [ ! -f "$CORE_DIR/$base" ]; then
    echo "DRIFT: $base exists in plugin-types but not in core"
    DRIFT=1
  fi
done

if [ "$DRIFT" -eq 0 ]; then
  echo "OK: All types are in sync with core"
  exit 0
else
  echo ""
  echo "FAILED: Type drift detected."
  echo "To sync from core, run:"
  echo "  cp \"$CORE_DIR\"/*.ts \"$EXT_DIR/\""
  echo "  cp \"$STORAGE_SRC\" \"$EXT_DIR/storage.ts\""
  echo "  # Then fix import paths in context.ts and index.ts:"
  echo "  sed -i 's|from \"../storage/api/plugin-storage.js\"|from \"./storage.js\"|g' \"$EXT_DIR/context.ts\" \"$EXT_DIR/index.ts\""
  exit 1
fi
