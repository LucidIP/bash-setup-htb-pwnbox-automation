#!/bin/bash
set -e
# install_pivot.sh — chisel + ligolo-ng (built from source) -> /opt/pivot, + proxychains4 (apt, install only).
source "$(dirname "$0")/_common.sh"

PIVOT_DIR="/opt/pivot"
sudo mkdir -p "$PIVOT_DIR"
sudo chown -R "$USER:$USER" "$PIVOT_DIR"

# chisel (linux + windows, latest release)
CHISEL_VER=$(curl -sI "https://github.com/jpillora/chisel/releases/latest" \
    | grep -i '^location:' | awk '{print $2}' | tr -d '\r\n' | xargs basename)  # github.com redirect avoids api rate limits
[ -z "$CHISEL_VER" ] && { echo "❌ could not resolve chisel version"; exit 1; }
CHISEL_VER_NUM="${CHISEL_VER#v}"

TMP_CHISEL=$(mktemp -d)
cd "$TMP_CHISEL"
for platform in linux windows; do
    DOWNLOADED=""
    for ext in gz zip; do
        URL="https://github.com/jpillora/chisel/releases/download/${CHISEL_VER}/chisel_${CHISEL_VER_NUM}_${platform}_amd64.${ext}"
        if wget -q "$URL" -O "asset_${platform}.${ext}"; then DOWNLOADED="asset_${platform}.${ext}"; break; fi
        rm -f "asset_${platform}.${ext}"
    done
    [ -z "$DOWNLOADED" ] && { echo "❌ chisel download failed for $platform"; exit 1; }

    mkdir -p "extract_$platform"
    case "$DOWNLOADED" in
        *.zip) unzip -q "$DOWNLOADED" -d "extract_$platform" ;;
        *.gz)  gunzip -c "$DOWNLOADED" > "extract_$platform/chisel_bin" ;;
    esac
    rm -f "$DOWNLOADED"

    EXTRACTED=$(find "extract_$platform" -type f | head -1)
    [ -z "$EXTRACTED" ] && { echo "❌ chisel extract failed for $platform"; exit 1; }
    if [ "$platform" = "linux" ]; then
        mv "$EXTRACTED" "$PIVOT_DIR/chisel"; chmod +x "$PIVOT_DIR/chisel"
    else
        mv "$EXTRACTED" "$PIVOT_DIR/chisel.exe"
    fi
done
cd - >/dev/null
rm -rf "$TMP_CHISEL"

# ligolo-ng (built from source)
if ! command -v go >/dev/null 2>&1; then apt_update; apt_install golang-go; fi
TMP_LIGOLO=$(mktemp -d)
git clone --depth 1 https://github.com/nicocha30/ligolo-ng.git "$TMP_LIGOLO/ligolo-ng"
( cd "$TMP_LIGOLO/ligolo-ng" && make all )
mv "$TMP_LIGOLO"/ligolo-ng/dist/* "$PIVOT_DIR/"
chmod +x "$PIVOT_DIR"/ligolo-ng-*linux* 2>/dev/null || true
rm -rf "$TMP_LIGOLO"

# proxychains4 — install only, chisel/ligolo auto-chain config is a future update
apt_update
apt_install proxychains4

echo "🔍 DEBUG: $PIVOT_DIR"; ls -la "$PIVOT_DIR"
dpkg -l proxychains4 | tail -1
echo "✅ Pivot tools ready! (proxychains4 config: /etc/proxychains4.conf, not auto-configured yet)"
