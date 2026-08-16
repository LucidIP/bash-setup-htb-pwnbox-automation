#!/bin/bash
set -e
# install_reference.sh — reference data, fetched in parallel -> $HTB_BASE_DIR: SecLists+rockyou,
# PayloadsAllTheThings. Plain tarball download (upstream's own documented method), not git clone —
# skips git protocol/object overhead entirely.
source "$(dirname "$0")/_common.sh"

SECLISTS_DIR="$HTB_BASE_DIR/SecLists"
PAYLOADS_DIR="$HTB_BASE_DIR/PayloadsAllTheThings"
ROCKYOU="$SECLISTS_DIR/Passwords/Leaked-Databases/rockyou.txt"

sudo mkdir -p "$SECLISTS_DIR" "$PAYLOADS_DIR"
sudo chown -R "$USER:$USER" "$SECLISTS_DIR" "$PAYLOADS_DIR"
curl -fsSL https://github.com/danielmiessler/SecLists/archive/master.tar.gz \
    | tar -xz --strip-components=1 -C "$SECLISTS_DIR" & p1=$!
curl -fsSL https://github.com/swisskyrepo/PayloadsAllTheThings/archive/master.tar.gz \
    | tar -xz --strip-components=1 -C "$PAYLOADS_DIR" & p2=$!
wait "$p1"; wait "$p2"

tar -xzf "$SECLISTS_DIR/Passwords/Leaked-Databases/rockyou.txt.tar.gz" \
    -C "$SECLISTS_DIR/Passwords/Leaked-Databases" || true
find "$SECLISTS_DIR" -type f -name "*.gz" -delete

sudo mkdir -p /usr/share/wordlists
sudo ln -sf "$ROCKYOU" /usr/share/wordlists/rockyou.txt

echo "🔍 DEBUG: reference data"; ls /usr/share/wordlists/; wc -l "$ROCKYOU"; ls "$PAYLOADS_DIR" | head -3
echo "✅ SecLists + PayloadsAllTheThings ready!"
