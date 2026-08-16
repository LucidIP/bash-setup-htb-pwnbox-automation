#!/bin/bash
# cleanup.sh [--path DIR] — removes stale/system tool installs before a fresh provision. Safe to re-run, best-effort.
source "$(dirname "$0")/_common.sh"
set +e
while [[ $# -gt 0 ]]; do
    case "$1" in
        --path) export HTB_BASE_DIR="$2"; shift 2 ;;
        *) shift ;;
    esac
done

echo "🧹 [1/10] AD tools (Certipy, Impacket, NetExec, BloodyAD)..."
sudo rm -f /usr/local/bin/{certipy,impacket,nxc,netexec,bloodyAD}* /usr/bin/{certipy,impacket,nxc,netexec,bloodyAD}*
sudo apt remove -y python3-certipy certipy python3-impacket impacket bloodyad python3-bloodyad 2>/dev/null
sudo pip3 uninstall -y certipy bloodyAD 2>/dev/null

echo "🧹 [2/10] evil-winrm (apt + gem)..."
sudo apt remove -y evil-winrm 2>/dev/null
rm -f /usr/bin/evil-winrm /usr/local/bin/evil-winrm "$HOME/bin/evil-winrm"
gem uninstall evil-winrm -a -x 2>/dev/null

echo "🧹 [3/10] Hashcat..."
sudo rm -rf /usr/src/hashcat "$HTB_BASE_DIR/hashcat"
rm -rf "$HOME/hashcat" "$HOME/opt/hashcat" /usr/local/bin/hashcat* "$HOME/bin/hashcat"

echo "🧹 [4/10] Neo4j / BloodHound (native packages, ~36GB reclaimed)..."
sudo dpkg --purge --force-all neo4j cypher-shell bloodhound 2>/dev/null
sudo apt purge -y neo4j neo4j-browser neo4j-server bloodhound cypher-shell 2>/dev/null
sudo rm -rf /var/lib/neo4j /etc/neo4j /usr/share/neo4j /usr/lib/neo4j /usr/lib/bloodhound "$HOME/neo4j"
sudo rm -f /usr/bin/neo4j /usr/bin/bloodhound "$HOME/bin/bloodhound" /usr/local/bin/bloodhound

echo "🧹 [5/10] Penelope + rlwrap + exiftool..."
command -v uv >/dev/null 2>&1 && uv tool uninstall penelope-shell-handler 2>/dev/null
sudo apt remove -y rlwrap libimage-exiftool-perl 2>/dev/null

echo "🧹 [6/10] Responder, sqlmap, proxychains4, manspider..."
sudo apt remove -y responder sqlmap proxychains4 2>/dev/null
command -v uv >/dev/null 2>&1 && uv tool uninstall manspider 2>/dev/null
sudo apt remove -y tesseract-ocr 2>/dev/null

echo "🧹 [7/10] tmux + Firefox automation configs..."
rm -f "$HOME/.tmux.conf"
sudo rm -f /etc/firefox/policies/policies.json

echo "🧹 [8/10] Wordlists, $HTB_BASE_DIR, Ghidra, logs+cache (disk space)..."
sudo rm -rf /usr/share/wordlists/* "$HTB_BASE_DIR"/* 2>/dev/null
sudo apt remove --purge -y seclists ghidra 2>/dev/null
sudo apt clean 2>/dev/null
sudo journalctl --vacuum-size=50M 2>/dev/null
sudo find /var/log -type f \( -name "*.gz" -o -name "*.[0-9]" \) -delete 2>/dev/null
rm -rf "$HOME/.cache/thumbnails" "$HOME/.cache/pip" "$HOME/.cache/uv" /tmp/.htb_logs /tmp/.htb_* 2>/dev/null

echo "🧹 [9/10] apt autoremove/autoclean..."
sudo apt autoremove -y 2>/dev/null
sudo apt autoclean -y 2>/dev/null

echo "🧹 [10/10] Disabling desktop animations (perf)..."
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.mate.interface enable-animations false 2>/dev/null
    gsettings set org.mate.Marco.general compositing-manager false 2>/dev/null
    gsettings set org.mate.Marco.general reduced-resources true 2>/dev/null
fi
for kw in kwriteconfig6 kwriteconfig5; do
    if command -v "$kw" >/dev/null 2>&1; then
        "$kw" --file kwinrc --group Compositing --key AnimationSpeed 0 2>/dev/null
        "$kw" --file kdeglobals --group KDE --key AnimationDurationFactor 0 2>/dev/null
    fi
done

hash -r
echo "✅ Cleanup done."
