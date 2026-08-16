#!/bin/bash
set -e
# install_cli_tools.sh — quick single-purpose apt tools, one transaction: Responder, sqlmap, rlwrap, exiftool.
source "$(dirname "$0")/_common.sh"

apt_update
apt_install responder sqlmap rlwrap libimage-exiftool-perl

echo "🔍 DEBUG: cli tools"
sqlmap --version
rlwrap --version
exiftool -ver
echo "✅ Responder + sqlmap + rlwrap + exiftool ready!"
