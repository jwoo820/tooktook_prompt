#!/usr/bin/env bash
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$(pwd)}"

echo "[TookTookCursorPack] target: ${TARGET_DIR}"

mkdir -p "${TARGET_DIR}/.cursor/rules"

rsync -a "${PACK_DIR}/cursor/rules/" "${TARGET_DIR}/.cursor/rules/"

echo "[TookTookCursorPack] install completed"
