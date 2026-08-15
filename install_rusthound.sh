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

echo "📁 Setting up /opt/rusthound..."
sudo mkdir -p /opt/rusthound && sudo chown -R "$USER:$USER" /opt/rusthound

echo "📥 Installing RustHound-CE..."
cargo install rusthound-ce --force --locked --root /opt/rusthound

echo "🔗 Creating symlink..."
mkdir -p "$HOME/bin"
ln -sf /opt/rusthound/bin/rusthound-ce "$HOME/bin/rusthound-ce"
add_to_path 'export PATH="$HOME/bin:/opt/rusthound/bin:$HOME/.cargo/bin:$PATH"'
export PATH="$HOME/bin:/opt/rusthound/bin:$PATH"

echo
echo "🔍 DEBUG: rusthound-ce"
echo "======================"
rusthound-ce --help | head -1
echo "✅ RustHound-CE ready!"
