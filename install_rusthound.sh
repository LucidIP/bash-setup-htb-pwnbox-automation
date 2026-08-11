#!/bin/bash
set -e
# install_rusthound.sh — RustHound-CE (Rust + build deps + binary)
# Run cleanup.sh first if you want a fresh slate.

echo "🛠️ Installing Rust + Cargo..."
if ! command -v cargo >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
export PATH="$HOME/.cargo/bin:$PATH"
cargo --version || { echo "❌ Rust install failed"; exit 1; }

echo "📦 Installing build dependencies..."
sudo apt update -qq
sudo apt install -y clang libclang-dev libkrb5-dev krb5-user libsasl2-modules-gssapi-mit \
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
echo 'export PATH="$HOME/bin:/opt/rusthound/bin:$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/bin:/opt/rusthound/bin:$PATH"

echo
echo "🔍 DEBUG: rusthound-ce"
echo "======================"
rusthound-ce --help | head -1
echo "✅ RustHound-CE ready!"
