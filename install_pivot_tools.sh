#!/bin/bash
set -e
# install_pivot_tools.sh — chisel, linPEAS/winPEAS, SharpCollection
# Run cleanup.sh first if you want a fresh slate.

TOOLS_DIR="/opt/tools"
PEAS_DIR="$TOOLS_DIR/peas"
SHARP_DIR="$TOOLS_DIR/sharp"
sudo mkdir -p "$TOOLS_DIR" "$PEAS_DIR" "$SHARP_DIR"

echo "📥 Installing chisel..."
wget -q "https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_amd64.gz" -O /tmp/chisel.gz
sudo mv /tmp/chisel.gz "$TOOLS_DIR/chisel.gz"
sudo gunzip -f "$TOOLS_DIR/chisel.gz"
sudo chmod +x "$TOOLS_DIR/chisel"

echo "📥 Installing linPEAS + winPEASx64..."
wget -q "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh" -O /tmp/linpeas.sh
sudo mv /tmp/linpeas.sh "$PEAS_DIR/linpeas.sh"
sudo chmod +x "$PEAS_DIR/linpeas.sh"
wget -q "https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASx64.exe" -O /tmp/winPEASx64.exe
sudo mv /tmp/winPEASx64.exe "$PEAS_DIR/winPEASx64.exe"

echo "📥 Installing SharpCollection (NetFramework_4.5_Any)..."
wget -q "https://github.com/Flangvik/SharpCollection/archive/refs/heads/master.zip" -O /tmp/sharpcollection.zip
sudo unzip -q /tmp/sharpcollection.zip -d "$SHARP_DIR"
sudo rm -f /tmp/sharpcollection.zip
if [ -d "$SHARP_DIR/SharpCollection-master/NetFramework_4.5_Any" ]; then
    sudo mv "$SHARP_DIR/SharpCollection-master/NetFramework_4.5_Any"/* "$SHARP_DIR"/ 2>/dev/null || true
    sudo rm -rf "$SHARP_DIR/SharpCollection-master"
fi

echo
echo "🔍 DEBUG: pivot tools"
echo "====================="
ls -la "$TOOLS_DIR/chisel" "$PEAS_DIR" "$SHARP_DIR" 2>/dev/null | head -20
echo "✅ Pivot tools ready! ($TOOLS_DIR)"
