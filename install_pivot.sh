#!/bin/bash
set -e
# install_pivot.sh — chisel (linux + windows) + ligolo-ng, built from source.
# Everything lands flat in /opt/pivot (no subfolders). Source clones/build dirs
# are removed after — only the final binaries stay.
# Run cleanup.sh first if you want a fresh slate.

PIVOT_DIR="/opt/pivot"
sudo mkdir -p "$PIVOT_DIR"
sudo chown -R "$USER:$USER" "$PIVOT_DIR"

#####################################
# chisel (linux + windows, latest release)
#####################################
echo "📥 Installing chisel..."
CHISEL_API="https://api.github.com/repos/jpillora/chisel/releases/latest"
RELEASE_JSON=$(curl -s "$CHISEL_API")
CHISEL_VER=$(echo "$RELEASE_JSON" | grep '"tag_name"' | head -1 | cut -d '"' -f4)

TMP_CHISEL=$(mktemp -d)
cd "$TMP_CHISEL"
for platform in linux windows; do
    ASSET_URL=$(echo "$RELEASE_JSON" | grep "browser_download_url" | grep "${platform}_amd64" | head -1 | cut -d '"' -f4)
    ASSET_FILE=$(basename "$ASSET_URL")
    wget -q "$ASSET_URL" -O "$ASSET_FILE"
    mkdir -p "extract_$platform"
    case "$ASSET_FILE" in
        *.zip) unzip -q "$ASSET_FILE" -d "extract_$platform" ;;
        *.gz)  gunzip -c "$ASSET_FILE" > "extract_$platform/chisel_bin" ;;
    esac
    rm -f "$ASSET_FILE"
    EXTRACTED=$(find "extract_$platform" -type f | head -1)
    if [ "$platform" = "linux" ]; then
        mv "$EXTRACTED" "$PIVOT_DIR/chisel"
        chmod +x "$PIVOT_DIR/chisel"
    else
        mv "$EXTRACTED" "$PIVOT_DIR/chisel.exe"
    fi
done
cd - >/dev/null
rm -rf "$TMP_CHISEL"
echo "✅ chisel $CHISEL_VER -> $PIVOT_DIR/{chisel,chisel.exe}"

#####################################
# ligolo-ng (built from source: make all)
#####################################
echo "📥 Building ligolo-ng..."
if ! command -v go >/dev/null 2>&1; then
    echo "🛠️ Installing Go..."
    sudo apt update -qq
    sudo apt install -y golang-go
fi

TMP_LIGOLO=$(mktemp -d)
git clone --depth 1 https://github.com/nicocha30/ligolo-ng.git "$TMP_LIGOLO/ligolo-ng"
( cd "$TMP_LIGOLO/ligolo-ng" && make all )
mv "$TMP_LIGOLO"/ligolo-ng/dist/* "$PIVOT_DIR/"
chmod +x "$PIVOT_DIR"/ligolo-ng-*linux* 2>/dev/null || true
rm -rf "$TMP_LIGOLO"
echo "✅ ligolo-ng -> $PIVOT_DIR/ligolo-ng-*"

echo
echo "🔍 DEBUG: /opt/pivot"
echo "===================="
ls -la "$PIVOT_DIR"
echo "✅ Pivot tools ready!"
