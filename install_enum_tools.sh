#!/bin/bash
set -e
# install_enum_tools.sh — linPEAS/winPEAS + sharp/ (mimikatz, Rubeus, RunasCs)
# /opt/tools is for enum/loot payloads (peas, sharp) — pivoting binaries live
# in /opt/pivot instead (see install_pivot.sh).
# Run cleanup.sh first if you want a fresh slate.

TOOLS_DIR="/opt/tools"
PEAS_DIR="$TOOLS_DIR/peas"
SHARP_DIR="$TOOLS_DIR/sharp"
sudo mkdir -p "$PEAS_DIR" "$SHARP_DIR"
sudo chown -R "$USER:$USER" "$TOOLS_DIR"

echo "📥 Installing linPEAS + winPEASx64..."
wget -q "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh" -O "$PEAS_DIR/linpeas.sh"
chmod +x "$PEAS_DIR/linpeas.sh"
wget -q "https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASx64.exe" -O "$PEAS_DIR/winPEASx64.exe"

echo "📥 Installing mimikatz..."
MK_VER=$(curl -sI "https://github.com/gentilkiwi/mimikatz/releases/latest" \
    | grep -i '^location:' | awk '{print $2}' | tr -d '\r\n' | xargs basename)
if [ -z "$MK_VER" ]; then
    echo "❌ Could not resolve latest mimikatz version"; exit 1
fi
TMP_MK=$(mktemp -d)
wget -q "https://github.com/gentilkiwi/mimikatz/releases/download/${MK_VER}/mimikatz_trunk.zip" -O "$TMP_MK/mimikatz.zip"
unzip -q "$TMP_MK/mimikatz.zip" -d "$TMP_MK"
cp "$TMP_MK/x64/mimikatz.exe" "$SHARP_DIR/mimikatz.exe"
rm -rf "$TMP_MK"

# GhostPack intentionally ships no compiled Rubeus.exe (avoids static AV signatures),
# so this pulls from the community-maintained Ghostpack-CompiledBinaries mirror —
# the one third-party (non-official) source in this script.
echo "📥 Installing Rubeus (community-compiled, see script comment)..."
wget -q "https://raw.githubusercontent.com/r3motecontrol/Ghostpack-CompiledBinaries/master/Rubeus.exe" -O "$SHARP_DIR/Rubeus.exe"

echo "📥 Installing RunasCs..."
RC_VER=$(curl -sI "https://github.com/antonioCoco/RunasCs/releases/latest" \
    | grep -i '^location:' | awk '{print $2}' | tr -d '\r\n' | xargs basename)
if [ -z "$RC_VER" ]; then
    echo "❌ Could not resolve latest RunasCs version"; exit 1
fi
TMP_RC=$(mktemp -d)
wget -q "https://github.com/antonioCoco/RunasCs/releases/download/${RC_VER}/RunasCs.zip" -O "$TMP_RC/RunasCs.zip"
unzip -q "$TMP_RC/RunasCs.zip" -d "$TMP_RC"
cp "$TMP_RC"/RunasCs*.exe "$SHARP_DIR/"
rm -rf "$TMP_RC"

# --- To add another tool later, copy one of the blocks above: ---
# direct binary (like Rubeus): wget -q "<raw-url>" -O "$SHARP_DIR/<name>.exe"
# zip release (like mimikatz/RunasCs): download to a mktemp -d, unzip, cp the
#   .exe you want into "$SHARP_DIR/", then rm -rf the temp dir.

echo
echo "🔍 DEBUG: /opt/tools"
echo "===================="
ls "$PEAS_DIR" "$SHARP_DIR"
echo "✅ Enum tools ready!"
