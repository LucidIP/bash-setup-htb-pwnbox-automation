#!/bin/bash
set -e
# install_hashcat.sh — latest hashcat release binary
# Run cleanup.sh first if you want a fresh slate.
source "$(dirname "$0")/_common.sh"

echo "📁 Setting up hashcat directory..."
if sudo mkdir -p /opt/hashcat 2>/dev/null && sudo chown -R "$USER:$USER" /opt/hashcat; then
    HASHCAT_DIR="/opt/hashcat"
else
    mkdir -p "$HOME/opt/hashcat"
    HASHCAT_DIR="$HOME/opt/hashcat"
fi
cd "$HASHCAT_DIR"

echo "📥 Downloading latest release..."
# Use the plain github.com redirect, not api.github.com — the API's 60 req/hr
# unauthenticated limit gets hit constantly on shared pwnbox IPs.
HC_VER=$(curl -sI "https://github.com/hashcat/hashcat/releases/latest" \
    | grep -i '^location:' | awk '{print $2}' | tr -d '\r\n' | xargs basename)
if [ -z "$HC_VER" ]; then
    echo "❌ Could not resolve latest hashcat version (network/GitHub issue)."
    exit 1
fi
HC_VER_NUM="${HC_VER#v}"
LATEST_URL="https://github.com/hashcat/hashcat/releases/download/${HC_VER}/hashcat-${HC_VER_NUM}.7z"
wget -q "$LATEST_URL" -O hashcat.7z || { echo "❌ Download failed: $LATEST_URL"; exit 1; }
7z x hashcat.7z -y > /dev/null 2>&1
rm hashcat.7z

echo "📦 Preparing binary..."
HASHCAT_SUBDIR=$(find . -maxdepth 1 -type d -name "hashcat-*" | head -1)
if [ -n "$HASHCAT_SUBDIR" ]; then
    mv "$HASHCAT_SUBDIR"/* . 2>/dev/null || true
    mv "$HASHCAT_SUBDIR"/.* . 2>/dev/null || true
    rm -rf "$HASHCAT_SUBDIR"
fi
[ -x "hashcat.bin" ] && mv hashcat.bin hashcat && chmod +x hashcat

echo "🔗 Creating symlink..."
mkdir -p "$HOME/bin"
ln -sf "$HASHCAT_DIR/hashcat" "$HOME/bin/hashcat"
sed -i '/export PATH=/d' ~/.bashrc
echo 'export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/snap/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/bin:$PATH"

echo
echo "🔍 DEBUG: hashcat"
echo "================="
hashcat --version
echo "✅ Hashcat ready!"
