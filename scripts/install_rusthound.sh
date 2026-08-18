#!/bin/bash
set -e
# install_rusthound.sh — RustHound-CE. Prebuilt static binary first; falls back to the
# original cargo build (rustup + clang + krb5 gssapi headers) if no asset matches.
source "$(dirname "$0")/_common.sh"

RH_DIR="$HTB_BASE_DIR/rusthound"
sudo mkdir -p "$RH_DIR/bin" && sudo chown -R "$USER:$USER" "$RH_DIR"
mkdir -p "$HOME/bin"

RH_VER=$(gh_latest g0h4n/RustHound-CE)
TMP=$(mktemp -d)
OK=0
if [ -n "$RH_VER" ]; then
    ASSET="rusthound-ce-Linux-gnu-x86_64.tar.gz"
    [ "$(uname -m)" = "aarch64" ] && ASSET="rusthound-ce-Linux-gnu-arm64.tar.gz"
    if dl "https://github.com/g0h4n/RustHound-CE/releases/download/${RH_VER}/${ASSET}" "$TMP/rh.tgz"; then
        tar -xzf "$TMP/rh.tgz" -C "$TMP" && mv "$TMP/rusthound-ce" "$RH_DIR/bin/rusthound-ce"
        chmod +x "$RH_DIR/bin/rusthound-ce"; OK=1
    fi
fi
rm -rf "$TMP"

if [ "$OK" -ne 1 ]; then
    echo "⚠️ no prebuilt, building from source..."
    ensure_cargo
    apt_update
    apt_install clang libclang-dev libkrb5-dev krb5-user libsasl2-modules-gssapi-mit \
        build-essential pkg-config libssl-dev libgss-dev
    GSSAPI_PATH=$(find /usr -name "gssapi.h" 2>/dev/null | head -1 | xargs dirname 2>/dev/null || echo "/usr/include/gssapi")
    export C_INCLUDE_PATH="$GSSAPI_PATH:$C_INCLUDE_PATH"
    export BINDGEN_EXTRA_CLANG_ARGS="-I$GSSAPI_PATH"
    export PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"
    cargo install rusthound-ce --force --locked --root "$RH_DIR"
fi

ln -sf "$RH_DIR/bin/rusthound-ce" "$HOME/bin/rusthound-ce"
add_to_path "export PATH=\"\$HOME/bin:$RH_DIR/bin:\$HOME/.cargo/bin:\$PATH\""
export PATH="$HOME/bin:$RH_DIR/bin:$PATH"

echo "🔍 rusthound-ce"; rusthound-ce --help | head -1
echo "✅ rusthound ready!"
