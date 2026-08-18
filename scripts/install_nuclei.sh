#!/bin/bash
set -e
# install_nuclei.sh — latest nuclei release binary, templates pre-fetched so the
# first real scan isn't the one paying for -update-templates.
source "$(dirname "$0")/_common.sh"

NUC_DIR="$HTB_BASE_DIR/nuclei"
sudo mkdir -p "$NUC_DIR" && sudo chown -R "$USER:$USER" "$NUC_DIR"
mkdir -p "$HOME/bin"

NUC_VER=$(gh_latest projectdiscovery/nuclei); NUC_NUM="${NUC_VER#v}"
[ -z "$NUC_VER" ] && { echo "❌ could not resolve nuclei version"; exit 1; }
ASSET="nuclei_${NUC_NUM}_linux_amd64.zip"
[ "$(uname -m)" = "aarch64" ] && ASSET="nuclei_${NUC_NUM}_linux_arm64.zip"

TMP=$(mktemp -d)
dl "https://github.com/projectdiscovery/nuclei/releases/download/${NUC_VER}/${ASSET}" "$TMP/nuclei.zip"
unzip -qo "$TMP/nuclei.zip" -d "$TMP"
mv "$TMP/nuclei" "$NUC_DIR/nuclei"
chmod +x "$NUC_DIR/nuclei"
rm -rf "$TMP"

ln -sf "$NUC_DIR/nuclei" "$HOME/bin/nuclei"
add_to_path 'export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/snap/bin:$PATH"'
export PATH="$HOME/bin:$PATH"

# ready to hunt: templates fetched now, not burned on the first real scan
"$NUC_DIR/nuclei" -ut >/dev/null 2>&1 || true

echo "🔍 DEBUG: nuclei"; nuclei -version
echo "✅ nuclei ready (templates pre-fetched)!"
