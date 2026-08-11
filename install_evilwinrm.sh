#!/bin/bash
set -e
# install_evilwinrm.sh — latest evil-winrm via gem (user-mode, no sudo needed)
# Run cleanup.sh first if you want a fresh slate.

echo "🏠 Setting up user gem directory..."
mkdir -p ~/.gem/ruby/$(ruby -e 'print RUBY_VERSION[/\A\d+\.\d+/]')/bin
echo 'gem: --user-install --no-document' > ~/.gemrc

echo "📥 Installing evil-winrm..."
gem update --system --no-document 2>/dev/null || true
gem install evil-winrm --no-document

echo "🔗 Creating symlink..."
mkdir -p "$HOME/bin"
GEM_BIN=$(ruby -e 'puts Gem.bindir')
ln -sf "$GEM_BIN/evil-winrm" "$HOME/bin/evil-winrm"

echo "⚙️ Fixing PATH..."
sed -i '/export PATH=/d' ~/.bashrc
{
  echo 'export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/snap/bin:$PATH"'
  echo 'export GEM_HOME="$HOME/.gem"'
  echo 'export PATH="$HOME/.gem/ruby/*/bin:$PATH"'
} >> ~/.bashrc
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

echo
echo "🔍 DEBUG: evil-winrm"
echo "===================="
evil-winrm -V
echo "✅ evil-winrm ready!"
