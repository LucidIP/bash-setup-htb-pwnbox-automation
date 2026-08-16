#!/bin/bash
set -e
# install_manspider.sh — MANSPIDER SMB crawler, via uv.
source "$(dirname "$0")/_common.sh"

ensure_uv
apt_update
apt_install tesseract-ocr  # OCR/legacy-doc extraction extra
uv tool install --force "git+https://github.com/blacklanternsecurity/MANSPIDER"
hash -r

echo "🔍 DEBUG: manspider"; manspider --help | head -1
echo "✅ MANSPIDER ready! Loot dir: ~/.manspider/loot"
