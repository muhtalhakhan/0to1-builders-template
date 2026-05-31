#!/usr/bin/env bash
set -euo pipefail

REPO_URL_DEFAULT="https://github.com/muhtalhakhan/0to1-builders-template.git"
RAW_BASE_URL="https://raw.githubusercontent.com/muhtalhakhan/0to1-builders-template/main"
INSTALL_DIR="$HOME/Desktop/0to1-builders"

TARGET_DIR="${1:-$INSTALL_DIR}"
REPO_URL="${REPO_URL:-$REPO_URL_DEFAULT}"
SCAFFOLD="${SCAFFOLD:-web}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 1
  }
}

echo
echo "==============================================="
echo "   0to1-builders - setup"
echo "==============================================="
echo "scaffold: $SCAFFOLD"
echo

echo "[1/4] checking prerequisites..."
require_cmd git

if [ -e "$TARGET_DIR" ]; then
  base="$TARGET_DIR"
  i=1
  while [ -e "$TARGET_DIR" ]; do
    TARGET_DIR="${base}-${i}"
    i=$((i + 1))
  done
  echo "note: '$base' already exists, using '$TARGET_DIR' instead."
fi

echo "[2/4] cloning template..."
git clone "$REPO_URL" "$TARGET_DIR"

cd "$TARGET_DIR"

if [ "$SCAFFOLD" = "web" ]; then
  require_cmd node
  require_cmd npm
  echo "[3/4] setting up web scaffold..."
  npm install
  echo "[4/4] running setup verification..."
  npm run check
elif [ "$SCAFFOLD" = "mobile" ]; then
  cd scaffolds/flutter-app
  echo "[3/4] setting up mobile scaffold..."
  bash ../../scripts/check-mobile-prereqs.sh
  echo "[4/4] installing flutter packages..."
  flutter pub get
else
  echo "invalid SCAFFOLD value: '$SCAFFOLD' (use web or mobile)" >&2
  exit 1
fi

echo ""
echo "setup complete. your project is ready in:"
echo "open this folder in codex:"
pwd
