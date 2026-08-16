#!/bin/bash
set -e
# install_rusthound.sh — RustHound-CE. Rigid build (gssapi headers) — logic below intentionally untouched.
source "$(dirname "$0")/_common.sh"

ensure_cargo
cargo --version || { echo "❌ Rust install failed"; exit 1; }

echo "📦 Installing build dependencies..."
apt_update
apt_install clang libclang-dev libkrb5-dev krb5-user libsasl2-modules-gssapi-mit \
    build-essential pkg-config libssl-dev libgss-dev

echo "🔧 Fixing gssapi headers..."
GSSAPI_PATH=$(find /usr -name "gssapi.h" 2>/dev/null | head -1 | xargs dirname 2>/dev/null || echo "/usr/include/gssapi")
export C_INCLUDE_PATH="$GSSAPI_PATH:$C_INCLUDE_PATH"
export BINDGEN_EXTRA_CLANG_ARGS="-I$GSSAPI_PATH"
export PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"

RH_DIR="$HTB_BASE_DIR/rusthound"
sudo mkdir -p "$RH_DIR" && sudo chown -R "$USER:$USER" "$RH_DIR"

echo "📥 Installing RustHound-CE..."
cargo install rusthound-ce --force --locked --root "$RH_DIR"

echo "🔗 Creating symlink..."
mkdir -p "$HOME/bin"
ln -sf "$RH_DIR/bin/rusthound-ce" "$HOME/bin/rusthound-ce"
add_to_path "export PATH=\"\$HOME/bin:$RH_DIR/bin:\$HOME/.cargo/bin:\$PATH\""
export PATH="$HOME/bin:$RH_DIR/bin:$PATH"

echo
echo "🔍 DEBUG: rusthound-ce"
echo "======================"
rusthound-ce --help | head -1
echo "✅ RustHound-CE ready!"
