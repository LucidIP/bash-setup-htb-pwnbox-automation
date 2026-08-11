#!/bin/bash
set -e
# install_hashcat.sh — latest hashcat release binary
# Run cleanup.sh first if you want a fresh slate.

echo "📁 Setting up hashcat directory..."
if sudo mkdir -p /opt/hashcat 2>/dev/null && sudo chown -R "$USER:$USER" /opt/hashcat; then
    HASHCAT_DIR="/opt/hashcat"
else
    mkdir -p "$HOME/opt/hashcat"
    HASHCAT_DIR="$HOME/opt/hashcat"
fi
cd "$HASHCAT_DIR"

echo "📥 Downloading latest release..."
LATEST_URL=$(curl -s https://api.github.com/repos/hashcat/hashcat/releases/latest \
    | grep '"browser_download_url"' | grep -i 7z | head -1 | cut -d '"' -f 4)
wget -q "$LATEST_URL" -O hashcat.7z || curl -L "$LATEST_URL" -o hashcat.7z
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
