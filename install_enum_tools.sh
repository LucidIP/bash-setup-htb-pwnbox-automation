#!/bin/bash
set -e
# install_enum_tools.sh — linPEAS/winPEAS + SharpCollection
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

echo "📥 Installing SharpCollection (NetFramework_4.5_Any)..."
TMP_SHARP=$(mktemp -d)
wget -q "https://github.com/Flangvik/SharpCollection/archive/refs/heads/master.zip" -O "$TMP_SHARP/sharpcollection.zip"
unzip -q "$TMP_SHARP/sharpcollection.zip" -d "$TMP_SHARP"
if [ -d "$TMP_SHARP/SharpCollection-master/NetFramework_4.5_Any" ]; then
    mv "$TMP_SHARP/SharpCollection-master/NetFramework_4.5_Any"/* "$SHARP_DIR"/
fi
rm -rf "$TMP_SHARP"

echo
echo "🔍 DEBUG: /opt/tools"
echo "===================="
ls "$PEAS_DIR" "$SHARP_DIR"
echo "✅ Enum tools ready!"
