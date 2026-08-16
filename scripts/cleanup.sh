#!/bin/bash
# cleanup.sh [--path DIR] [--cache-only] — removes stale/system tool installs before a fresh
# provision, or (--cache-only) just releases caches after install. Safe to re-run, best-effort.
source "$(dirname "$0")/_common.sh"
set +e
CACHE_ONLY=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --path) export HTB_BASE_DIR="$2"; shift 2 ;;
        --cache-only) CACHE_ONLY=1; shift ;;
        *) shift ;;
    esac
done

# apt/uv/pip/cargo/npm/go/docker caches -- shared by the pre-install deep wipe (step 8)
# and the post-install --cache-only pass, so both stay in sync
release_cache() {
    sudo apt clean 2>/dev/null
    sudo rm -rf /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/* 2>/dev/null
    command -v uv     >/dev/null 2>&1 && uv cache clean 2>/dev/null
    command -v pip3   >/dev/null 2>&1 && pip3 cache purge 2>/dev/null
    command -v cargo  >/dev/null 2>&1 && rm -rf "$HOME/.cargo/registry/cache" "$HOME/.cargo/registry/src" 2>/dev/null
    command -v npm    >/dev/null 2>&1 && npm cache clean --force 2>/dev/null
    command -v go     >/dev/null 2>&1 && go clean -cache -modcache 2>/dev/null
    command -v docker >/dev/null 2>&1 && sudo docker builder prune -af 2>/dev/null
    rm -rf "$HOME/.cache"/* 2>/dev/null
}

if [[ $CACHE_ONLY -eq 1 ]]; then
    echo "🧹 post-install cache release (frees the RAM/disk the installers just used)..."
    release_cache
    sync; echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1
    hash -r
    echo "✅ cache released."
    exit 0
fi

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
# stale containers/volumes are why a re-install failed the neo4j healthcheck
if command -v docker >/dev/null 2>&1; then
    sudo docker ps -aq --filter "name=server-" | xargs -r sudo docker rm -f 2>/dev/null
    sudo docker volume ls -q --filter "name=server_" | xargs -r sudo docker volume rm -f 2>/dev/null
    sudo docker image prune -af 2>/dev/null
fi

echo "🧹 [5/10] Penelope + rlwrap + exiftool..."
command -v uv >/dev/null 2>&1 && uv tool uninstall penelope-shell-handler 2>/dev/null
sudo apt remove -y rlwrap libimage-exiftool-perl 2>/dev/null

echo "🧹 [6/10] Responder, sqlmap, proxychains4, manspider, freerdp3-x11..."
sudo apt remove -y responder sqlmap proxychains4 freerdp3-x11 2>/dev/null
command -v uv >/dev/null 2>&1 && uv tool uninstall manspider 2>/dev/null
sudo apt remove -y tesseract-ocr 2>/dev/null

echo "🧹 [7/10] tmux + Firefox automation configs..."
rm -f "$HOME/.tmux.conf"
sudo rm -f /etc/firefox/policies/policies.json

echo "🧹 [8/10] Wordlists, $HTB_BASE_DIR, Ghidra, logs+cache (disk space)..."
sudo rm -rf /usr/share/wordlists/* "$HTB_BASE_DIR"/* 2>/dev/null
sudo apt remove --purge -y seclists ghidra 2>/dev/null
sudo journalctl --vacuum-size=50M 2>/dev/null
sudo find /var/log -type f \( -name "*.gz" -o -name "*.[0-9]" \) -delete 2>/dev/null
release_cache
rm -rf /tmp/.htb_logs /tmp/.htb_* 2>/dev/null

echo "🧹 [9/10] apt autoremove/autoclean..."
sudo apt autoremove -y 2>/dev/null
sudo apt autoclean -y 2>/dev/null

echo "🧹 [10/10] Performance: animations off, 1 workspace, caches freed..."
if command -v gsettings >/dev/null 2>&1; then
    # mate (parrot default)
    gsettings set org.mate.interface enable-animations false 2>/dev/null
    gsettings set org.mate.interface gtk-enable-animations false 2>/dev/null
    # compositing stays on -- off caused black-flash on the streamed remote desktop
    gsettings set org.mate.Marco.general compositing-fast-alt-tab true 2>/dev/null
    gsettings set org.mate.Marco.general reduced-resources true 2>/dev/null
    gsettings set org.mate.Marco.general num-workspaces 1 2>/dev/null
    gsettings set org.mate.panel enable-animations false 2>/dev/null
    gsettings set org.mate.caja.preferences preview-sound never 2>/dev/null
    # gnome (pwnbox)
    gsettings set org.gnome.desktop.interface enable-animations false 2>/dev/null
    gsettings set org.gnome.desktop.interface gtk-enable-animations false 2>/dev/null
fi
# xfce
if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
    xfconf-query -c xfwm4 -p /general/workspace_count -s 1 2>/dev/null
fi
# kde
for kw in kwriteconfig6 kwriteconfig5; do
    if command -v "$kw" >/dev/null 2>&1; then
        "$kw" --file kwinrc --group Compositing --key AnimationSpeed 0 2>/dev/null
        "$kw" --file kwinrc --group Desktops --key Number 1 2>/dev/null
        "$kw" --file kdeglobals --group KDE --key AnimationDurationFactor 0 2>/dev/null
    fi
done
# cpu governor -> performance (ignored on VMs without the driver)
if command -v cpupower >/dev/null 2>&1; then
    sudo cpupower frequency-set -g performance >/dev/null 2>&1
else
    for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -w "$g" ] && echo performance | sudo tee "$g" >/dev/null 2>&1
    done
fi
# free page cache / dentries — most of it is install leftovers we never read again
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1

hash -r
echo "✅ Cleanup done."
