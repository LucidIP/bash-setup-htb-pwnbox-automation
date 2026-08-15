#!/bin/bash
set -e
# install_reference.sh — reference data, cloned in parallel -> /opt: SecLists+rockyou, PayloadsAllTheThings.
source "$(dirname "$0")/_common.sh"

SECLISTS_DIR="/opt/SecLists"
PAYLOADS_DIR="/opt/PayloadsAllTheThings"
ROCKYOU="$SECLISTS_DIR/Passwords/Leaked-Databases/rockyou.txt"

sudo git clone --depth 1 https://github.com/danielmiessler/SecLists.git "$SECLISTS_DIR" & p1=$!
sudo git clone --depth 1 https://github.com/swisskyrepo/PayloadsAllTheThings.git "$PAYLOADS_DIR" & p2=$!
wait "$p1"; wait "$p2"
sudo chown -R "$USER:$USER" "$SECLISTS_DIR" "$PAYLOADS_DIR"

tar -xzf "$SECLISTS_DIR/Passwords/Leaked-Databases/rockyou.txt.tar.gz" \
    -C "$SECLISTS_DIR/Passwords/Leaked-Databases" || true
find "$SECLISTS_DIR" -type f -name "*.gz" -delete

sudo mkdir -p /usr/share/wordlists
sudo ln -sf "$ROCKYOU" /usr/share/wordlists/rockyou.txt

echo "🔍 DEBUG: reference data"; ls /usr/share/wordlists/; wc -l "$ROCKYOU"; ls "$PAYLOADS_DIR" | head -3
echo "✅ SecLists + PayloadsAllTheThings ready!"
