#!/bin/bash
set -e
# install_evilwinrm.sh — latest evil-winrm via gem (user-mode, no sudo needed)
# Run cleanup.sh first if you want a fresh slate.

echo "🏠 Setting up user gem directory..."
# Ask Ruby directly instead of guessing the path — on Debian/Ubuntu/Parrot the
# user gem dir follows XDG (~/.local/share/gem/ruby/X.Y), not ~/.gem/ruby/X.Y.
GEM_USER_DIR=$(ruby -e 'puts Gem.user_dir')
mkdir -p "$GEM_USER_DIR/bin"
echo 'gem: --user-install --no-document' > ~/.gemrc

echo "📥 Installing evil-winrm..."
gem update --system --no-document 2>/dev/null || true
gem install evil-winrm --no-document

echo "🔗 Creating symlink..."
mkdir -p "$HOME/bin"
GEM_BIN="$GEM_USER_DIR/bin"
if [ ! -x "$GEM_BIN/evil-winrm" ]; then
    echo "⚠️  Not at $GEM_BIN, searching for the binary..."
    FOUND=$(find "$HOME" -maxdepth 6 -name "evil-winrm" -type f 2>/dev/null | head -1)
    [ -n "$FOUND" ] && GEM_BIN=$(dirname "$FOUND")
fi
if [ ! -x "$GEM_BIN/evil-winrm" ]; then
    echo "❌ evil-winrm binary not found after install. Check 'gem list -d evil-winrm'."
    exit 1
fi
ln -sf "$GEM_BIN/evil-winrm" "$HOME/bin/evil-winrm"

echo "⚙️ Fixing PATH..."
sed -i '/export PATH=/d' ~/.bashrc
{
  echo 'export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/snap/bin:$PATH"'
  echo "export GEM_HOME=\"$GEM_USER_DIR\""
  echo "export PATH=\"$GEM_BIN:\$PATH\""
} >> ~/.bashrc
export PATH="$HOME/bin:$GEM_BIN:$PATH"
hash -r

echo
echo "🔍 DEBUG: evil-winrm"
echo "===================="
echo "Binary: $GEM_BIN/evil-winrm"
evil-winrm -V
echo "✅ evil-winrm ready!"
