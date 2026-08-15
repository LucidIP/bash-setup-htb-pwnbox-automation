#!/bin/bash
set -e
# install_hashcat.sh — latest hashcat release binary.
source "$(dirname "$0")/_common.sh"

if sudo mkdir -p /opt/hashcat 2>/dev/null && sudo chown -R "$USER:$USER" /opt/hashcat; then
    HASHCAT_DIR="/opt/hashcat"
else
    mkdir -p "$HOME/opt/hashcat"; HASHCAT_DIR="$HOME/opt/hashcat"
fi
cd "$HASHCAT_DIR"

HC_VER=$(curl -sI "https://github.com/hashcat/hashcat/releases/latest" \
    | grep -i '^location:' | awk '{print $2}' | tr -d '\r\n' | xargs basename)  # github.com redirect avoids api rate limits
[ -z "$HC_VER" ] && { echo "❌ could not resolve hashcat version"; exit 1; }
HC_VER_NUM="${HC_VER#v}"
wget -q "https://github.com/hashcat/hashcat/releases/download/${HC_VER}/hashcat-${HC_VER_NUM}.7z" -O hashcat.7z
7z x hashcat.7z -y > /dev/null 2>&1
rm hashcat.7z

HASHCAT_SUBDIR=$(find . -maxdepth 1 -type d -name "hashcat-*" | head -1)
if [ -n "$HASHCAT_SUBDIR" ]; then
    mv "$HASHCAT_SUBDIR"/* . 2>/dev/null || true
    mv "$HASHCAT_SUBDIR"/.* . 2>/dev/null || true
    rm -rf "$HASHCAT_SUBDIR"
fi
[ -x "hashcat.bin" ] && mv hashcat.bin hashcat && chmod +x hashcat

mkdir -p "$HOME/bin"
ln -sf "$HASHCAT_DIR/hashcat" "$HOME/bin/hashcat"
add_to_path 'export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/snap/bin:$PATH"'
export PATH="$HOME/bin:$PATH"

echo "🔍 DEBUG: hashcat"; hashcat --version
echo "✅ Hashcat ready!"
