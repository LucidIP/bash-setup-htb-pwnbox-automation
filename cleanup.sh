#!/bin/bash
# cleanup.sh
# Single source of truth for removing old/stale tool installs before a fresh
# provision. Safe to re-run; every step is best-effort (never aborts the run).
set +e

echo "🧹 [1/6] AD tools (Certipy, Impacket, NetExec, BloodyAD)..."
sudo rm -f /usr/local/bin/{certipy,impacket,nxc,netexec,bloodyAD}* /usr/bin/{certipy,impacket,nxc,netexec,bloodyAD}*
sudo apt remove -y python3-certipy certipy python3-impacket impacket bloodyad python3-bloodyad 2>/dev/null
sudo pip3 uninstall -y certipy bloodyAD 2>/dev/null

echo "🧹 [2/6] evil-winrm (apt + gem)..."
sudo apt remove -y evil-winrm 2>/dev/null
rm -f /usr/bin/evil-winrm /usr/local/bin/evil-winrm "$HOME/bin/evil-winrm"
gem uninstall evil-winrm -a -x 2>/dev/null

echo "🧹 [3/6] Hashcat..."
rm -rf /usr/src/hashcat "$HOME/hashcat" "$HOME/opt/hashcat" /opt/hashcat /usr/local/bin/hashcat* "$HOME/bin/hashcat"

echo "🧹 [4/6] Neo4j / BloodHound (native packages, ~36GB reclaimed)..."
sudo dpkg --purge --force-all neo4j cypher-shell bloodhound 2>/dev/null
sudo apt purge -y neo4j neo4j-browser neo4j-server bloodhound cypher-shell 2>/dev/null
sudo rm -rf /var/lib/neo4j /etc/neo4j /opt/neo4j /usr/share/neo4j /usr/lib/neo4j /usr/lib/bloodhound "$HOME/neo4j"
sudo rm -f /usr/bin/neo4j /usr/bin/bloodhound "$HOME/bin/bloodhound" /usr/local/bin/bloodhound

echo "🧹 [5/6] Wordlists, /opt, SecLists, Ghidra..."
sudo rm -rf /usr/share/wordlists/* /opt/* 2>/dev/null
sudo apt remove --purge -y seclists ghidra 2>/dev/null

echo "🧹 [6/6] apt autoremove/autoclean..."
sudo apt autoremove -y 2>/dev/null
sudo apt autoclean -y 2>/dev/null

echo "🧠 Clearing bash command cache..."
hash -r

echo "✅ Cleanup complete. Run start_automation.sh (or an individual install_*.sh) next."
