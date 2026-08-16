#!/bin/bash
set -e
# install_cli_tools.sh — quick single-purpose apt tools, one transaction: Responder, sqlmap,
# rlwrap, exiftool, freerdp3-x11, ffuf, feroxbuster. apt = prebuilt packages, fastest path for
# ffuf/feroxbuster (no Go/Rust toolchain, no GitHub release resolution).
source "$(dirname "$0")/_common.sh"

apt_update
apt_install responder sqlmap rlwrap libimage-exiftool-perl freerdp3-x11 ffuf feroxbuster

echo "🔍 DEBUG: cli tools"
sqlmap --version
rlwrap --version
exiftool -ver
xfreerdp3 --version
ffuf -V
feroxbuster -V
echo "✅ Responder + sqlmap + rlwrap + exiftool + freerdp3-x11 + ffuf + feroxbuster ready!"
