#!/bin/bash
set -e
# install_pivot.sh — chisel + ligolo-ng prebuilt -> $HTB_BASE_DIR/pivot, + proxychains4 (apt, install only).
source "$(dirname "$0")/_common.sh"

PIVOT_DIR="$HTB_BASE_DIR/pivot"
sudo mkdir -p "$PIVOT_DIR"
sudo chown -R "$USER:$USER" "$PIVOT_DIR"
TMP=$(mktemp -d)

# --- chisel (linux + windows) ---
CH_VER=$(gh_latest jpillora/chisel); CH_NUM="${CH_VER#v}"
[ -z "$CH_VER" ] && { echo "❌ chisel version"; exit 1; }
for plat in linux windows; do
    got=""
    for ext in gz zip; do
        if dl "https://github.com/jpillora/chisel/releases/download/${CH_VER}/chisel_${CH_NUM}_${plat}_amd64.${ext}" "$TMP/c.$ext"; then got="$TMP/c.$ext"; break; fi
    done
    [ -z "$got" ] && { echo "❌ chisel $plat download"; exit 1; }
    mkdir -p "$TMP/x_$plat"
    case "$got" in
        *.zip) unzip -qo "$got" -d "$TMP/x_$plat" ;;
        *.gz)  gunzip -c "$got" > "$TMP/x_$plat/chisel" ;;
    esac
    rm -f "$got"
    f=$(find "$TMP/x_$plat" -type f | head -1)
    [ -z "$f" ] && { echo "❌ chisel $plat extract"; exit 1; }
    [ "$plat" = linux ] && { mv "$f" "$PIVOT_DIR/chisel"; chmod +x "$PIVOT_DIR/chisel"; } || mv "$f" "$PIVOT_DIR/chisel.exe"
done

# --- ligolo-ng prebuilt (was: install Go + `make all`, which cross-builds 8 binaries) ---
LG_VER=$(gh_latest nicocha30/ligolo-ng); LG_NUM="${LG_VER#v}"
[ -z "$LG_VER" ] && { echo "❌ ligolo version"; exit 1; }
LG_URL="https://github.com/nicocha30/ligolo-ng/releases/download/${LG_VER}"
dl "$LG_URL/ligolo-ng_proxy_${LG_NUM}_linux_amd64.tar.gz" "$TMP/lp.tgz"
dl "$LG_URL/ligolo-ng_agent_${LG_NUM}_linux_amd64.tar.gz" "$TMP/la.tgz"
dl "$LG_URL/ligolo-ng_agent_${LG_NUM}_windows_amd64.zip"  "$TMP/lw.zip"
tar -xzf "$TMP/lp.tgz" -C "$TMP" proxy && mv "$TMP/proxy" "$PIVOT_DIR/ligolo-proxy"
tar -xzf "$TMP/la.tgz" -C "$TMP" agent && mv "$TMP/agent" "$PIVOT_DIR/ligolo-agent"
unzip -qo "$TMP/lw.zip" -d "$TMP/lw" && mv "$TMP/lw/agent.exe" "$PIVOT_DIR/ligolo-agent.exe"
chmod +x "$PIVOT_DIR/ligolo-proxy" "$PIVOT_DIR/ligolo-agent"

apt_update
apt_install proxychains4
rm -rf "$TMP"

echo "🔍 $PIVOT_DIR"; ls "$PIVOT_DIR"
echo "✅ pivot ready (proxychains4 conf not auto-wired yet)"
