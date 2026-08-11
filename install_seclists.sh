#!/bin/bash
set -e
# install_seclists.sh — SecLists + rockyou.txt
# Run cleanup.sh first if you want a fresh slate.

SECLISTS_DIR="/opt/SecLists"
ROCKYOU="$SECLISTS_DIR/Passwords/Leaked-Databases/rockyou.txt"

echo "📥 Cloning SecLists..."
sudo git clone --depth 1 https://github.com/danielmiessler/SecLists.git "$SECLISTS_DIR"
sudo chown -R "$USER:$USER" "$SECLISTS_DIR"

echo "📦 Extracting rockyou..."
tar -xzf "$SECLISTS_DIR/Passwords/Leaked-Databases/rockyou.txt.tar.gz" \
    -C "$SECLISTS_DIR/Passwords/Leaked-Databases" || true
find "$SECLISTS_DIR" -type f -name "*.gz" -delete

echo "🔗 Linking rockyou..."
sudo mkdir -p /usr/share/wordlists
sudo ln -sf "$ROCKYOU" /usr/share/wordlists/rockyou.txt

echo
echo "🔍 DEBUG: SecLists"
echo "=================="
ls /usr/share/wordlists/
wc -l "$ROCKYOU"
echo "✅ SecLists ready!"
