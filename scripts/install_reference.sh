#!/bin/bash
set -e
# install_reference.sh — SecLists + rockyou -> $HTB_BASE_DIR. Plain tarball download (SecLists'
# own documented method), not git clone — skips git protocol/object overhead entirely.
# PayloadsAllTheThings dropped: browse it online, or curl a single file when you actually need one —
# no reason to carry the whole repo on disk.
source "$(dirname "$0")/_common.sh"

SECLISTS_DIR="$HTB_BASE_DIR/SecLists"
ROCKYOU="$SECLISTS_DIR/Passwords/Leaked-Databases/rockyou.txt"

sudo mkdir -p "$SECLISTS_DIR"
sudo chown -R "$USER:$USER" "$SECLISTS_DIR"
curl -fsSL https://github.com/danielmiessler/SecLists/archive/master.tar.gz \
    | tar -xz --strip-components=1 -C "$SECLISTS_DIR"

tar -xzf "$SECLISTS_DIR/Passwords/Leaked-Databases/rockyou.txt.tar.gz" \
    -C "$SECLISTS_DIR/Passwords/Leaked-Databases" || true
find "$SECLISTS_DIR" -type f -name "*.gz" -delete

sudo mkdir -p /usr/share/wordlists
sudo ln -sf "$ROCKYOU" /usr/share/wordlists/rockyou.txt

echo "🔍 DEBUG: reference data"; ls /usr/share/wordlists/; wc -l "$ROCKYOU"
echo "✅ SecLists ready!"
