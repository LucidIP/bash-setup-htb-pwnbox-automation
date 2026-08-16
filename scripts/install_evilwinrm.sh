#!/bin/bash
set -e
# install_evilwinrm.sh — latest evil-winrm via gem (user-mode, no sudo).
source "$(dirname "$0")/_common.sh"

GEM_USER_DIR=$(ruby -e 'puts Gem.user_dir')  # follows XDG on Debian/Parrot, not ~/.gem
mkdir -p "$GEM_USER_DIR/bin"
echo 'gem: --user-install --no-document' > ~/.gemrc

gem update --system --no-document 2>/dev/null || true
gem install evil-winrm --no-document

mkdir -p "$HOME/bin"
GEM_BIN="$GEM_USER_DIR/bin"
if [ ! -x "$GEM_BIN/evil-winrm" ]; then
    FOUND=$(find "$HOME" -maxdepth 6 -name "evil-winrm" -type f 2>/dev/null | head -1)
    [ -n "$FOUND" ] && GEM_BIN=$(dirname "$FOUND")
fi
[ ! -x "$GEM_BIN/evil-winrm" ] && { echo "❌ evil-winrm binary not found after install"; exit 1; }
ln -sf "$GEM_BIN/evil-winrm" "$HOME/bin/evil-winrm"

add_to_path 'export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/snap/bin:$PATH"' \
    "export GEM_HOME=\"$GEM_USER_DIR\"" \
    "export PATH=\"$GEM_BIN:\$PATH\""
export PATH="$HOME/bin:$GEM_BIN:$PATH"
hash -r

echo "🔍 DEBUG: evil-winrm"; evil-winrm -V
echo "✅ evil-winrm ready!"
