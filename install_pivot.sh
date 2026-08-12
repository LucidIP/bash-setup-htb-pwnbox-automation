#!/bin/bash
set -e
# install_pivot.sh — chisel (linux + windows) + ligolo-ng, built from source.
# Everything lands flat in /opt/pivot (no subfolders). Source clones/build dirs
# are removed after — only the final binaries stay.
# Run cleanup.sh first if you want a fresh slate.
source "$(dirname "$0")/_common.sh"

PIVOT_DIR="/opt/pivot"
sudo mkdir -p "$PIVOT_DIR"
sudo chown -R "$USER:$USER" "$PIVOT_DIR"

#####################################
# chisel (linux + windows, latest release)
#####################################
echo "📥 Installing chisel..."
# Use the plain github.com redirect, not api.github.com — the API's 60 req/hr
# unauthenticated limit gets hit constantly on shared pwnbox IPs.
CHISEL_VER=$(curl -sI "https://github.com/jpillora/chisel/releases/latest" \
    | grep -i '^location:' | awk '{print $2}' | tr -d '\r\n' | xargs basename)
if [ -z "$CHISEL_VER" ]; then
    echo "❌ Could not resolve latest chisel version (network/GitHub issue). Aborting chisel install."
    exit 1
fi
CHISEL_VER_NUM="${CHISEL_VER#v}"

TMP_CHISEL=$(mktemp -d)
cd "$TMP_CHISEL"
for platform in linux windows; do
    DOWNLOADED=""
    for ext in gz zip; do
        URL="https://github.com/jpillora/chisel/releases/download/${CHISEL_VER}/chisel_${CHISEL_VER_NUM}_${platform}_amd64.${ext}"
        if wget -q "$URL" -O "asset_${platform}.${ext}"; then
            DOWNLOADED="asset_${platform}.${ext}"
            break
        fi
        rm -f "asset_${platform}.${ext}"
    done
    if [ -z "$DOWNLOADED" ]; then
        echo "❌ Could not download chisel $CHISEL_VER for $platform (tried .gz and .zip)"
        exit 1
    fi

    mkdir -p "extract_$platform"
    case "$DOWNLOADED" in
        *.zip) unzip -q "$DOWNLOADED" -d "extract_$platform" ;;
        *.gz)  gunzip -c "$DOWNLOADED" > "extract_$platform/chisel_bin" ;;
    esac
    rm -f "$DOWNLOADED"

    EXTRACTED=$(find "extract_$platform" -type f | head -1)
    if [ -z "$EXTRACTED" ]; then
        echo "❌ Extraction produced no file for $platform — chisel install aborted"
        exit 1
    fi
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
    apt_update
    apt_install golang-go
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
