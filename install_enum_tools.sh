#!/bin/bash
set -e
# install_enum_tools.sh — linPEAS/winPEAS + mimikatz/Rubeus/RunasCs -> /opt/{peas,sharp}.
source "$(dirname "$0")/_common.sh"

TOOLS_DIR="/opt"
PEAS_DIR="$TOOLS_DIR/peas"
SHARP_DIR="$TOOLS_DIR/sharp"
sudo mkdir -p "$PEAS_DIR" "$SHARP_DIR"
sudo chown -R "$USER:$USER" "$TOOLS_DIR"

wget -q "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh" -O "$PEAS_DIR/linpeas.sh"
chmod +x "$PEAS_DIR/linpeas.sh"
wget -q "https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASx64.exe" -O "$PEAS_DIR/winPEASx64.exe"

MK_VER=$(curl -sI "https://github.com/gentilkiwi/mimikatz/releases/latest" \
    | grep -i '^location:' | awk '{print $2}' | tr -d '\r\n' | xargs basename)
[ -z "$MK_VER" ] && { echo "❌ could not resolve mimikatz version"; exit 1; }
TMP_MK=$(mktemp -d)
wget -q "https://github.com/gentilkiwi/mimikatz/releases/download/${MK_VER}/mimikatz_trunk.zip" -O "$TMP_MK/mimikatz.zip"
unzip -q "$TMP_MK/mimikatz.zip" -d "$TMP_MK"
cp "$TMP_MK/x64/mimikatz.exe" "$SHARP_DIR/mimikatz.exe"
rm -rf "$TMP_MK"

# GhostPack ships no compiled Rubeus.exe (avoids AV signatures) -> community mirror instead
wget -q "https://raw.githubusercontent.com/r3motecontrol/Ghostpack-CompiledBinaries/master/Rubeus.exe" -O "$SHARP_DIR/Rubeus.exe"

RC_VER=$(curl -sI "https://github.com/antonioCoco/RunasCs/releases/latest" \
    | grep -i '^location:' | awk '{print $2}' | tr -d '\r\n' | xargs basename)
[ -z "$RC_VER" ] && { echo "❌ could not resolve RunasCs version"; exit 1; }
TMP_RC=$(mktemp -d)
wget -q "https://github.com/antonioCoco/RunasCs/releases/download/${RC_VER}/RunasCs.zip" -O "$TMP_RC/RunasCs.zip"
unzip -q "$TMP_RC/RunasCs.zip" -d "$TMP_RC"
cp "$TMP_RC"/RunasCs*.exe "$SHARP_DIR/"
rm -rf "$TMP_RC"

echo "🔍 DEBUG: /opt/{peas,sharp}"; ls "$PEAS_DIR" "$SHARP_DIR"
echo "✅ Enum tools ready!"
