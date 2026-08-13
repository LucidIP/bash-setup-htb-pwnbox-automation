#!/bin/bash
set -e
# install_bloodhound.sh — BloodHound CE + Neo4j via Docker (pwnbox safe)
# Run cleanup.sh first if you want a fresh slate (removes native neo4j/bloodhound, ~36GB).
source "$(dirname "$0")/_common.sh"

USER_NAME=$(whoami)

echo "🐳 Installing docker.io..."
apt_update
apt_install docker.io curl ca-certificates
sudo systemctl enable docker.service || true
sudo systemctl start docker.service || true

ensure_compose() {
    if sudo docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD="sudo docker compose"; return 0
    fi
    if command -v docker-compose >/dev/null 2>&1; then
        COMPOSE_CMD="sudo docker-compose"; return 0
    fi
    echo "📦 Docker Compose not found, installing plugin..."
    apt_install docker-compose-plugin >/dev/null 2>&1
    if sudo docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD="sudo docker compose"; return 0
    fi
    echo "❌ Failed to install Docker Compose."; exit 1
}
compose() { $COMPOSE_CMD "$@"; }
ensure_compose

echo "📁 Setting up BloodHound directory..."
if sudo mkdir -p /opt/bloodhound/server 2>/dev/null && sudo chown -R "$USER_NAME:$USER_NAME" /opt/bloodhound; then
    BH_DIR="/opt/bloodhound"
else
    mkdir -p "$HOME/opt/bloodhound/server"
    BH_DIR="$HOME/opt/bloodhound"
fi
cd "$BH_DIR/server"

echo "📥 Downloading BloodHound Community Edition..."
sudo curl -fsSL "https://ghst.ly/getbhce" -o docker-compose.yaml
sudo chown "$USER_NAME:$USER_NAME" docker-compose.yaml
sudo sed -i 's|BLOODHOUND_PORT:-8080|BLOODHOUND_PORT:-8088|g' docker-compose.yaml

echo "🚀 Starting BloodHound + Neo4j..."
compose pull
compose up -d

echo "⏳ Waiting for Neo4j (max 5min)..."
timeout=300; delay=10; elapsed=0
while ! sudo nc -z localhost 7474 2>/dev/null; do
    sleep $delay; elapsed=$((elapsed + delay))
    if [ $elapsed -ge $timeout ]; then echo "❌ Neo4j timeout"; exit 1; fi
    echo "⏳ Neo4j not ready yet... ($elapsed/$timeout)"
done
echo "✅ Neo4j ready on port 7474!"

echo "🔑 Extracting BloodHound password..."
sleep 10
BH_PASS=$(compose logs bloodhound 2>/dev/null | grep -oP "Password Set To:\s+\K\S+" | tail -1)
if [ -n "$BH_PASS" ]; then
    {
        printf "username: admin\npassword: %s\n" "$BH_PASS"
        echo "# Containers are stopped after install to avoid leaving ports open unused."
        echo "# Start BloodHound back up when you need it:"
        echo "#   cd $BH_DIR/server && sudo docker compose up -d"
    } > initial-password.txt
    echo "✅ Password + restart command saved to initial-password.txt"
else
    echo "⚠️ No password found in logs, check manually: compose logs bloodhound | grep -i password"
fi

echo
echo "🔍 DEBUG: BloodHound status"
echo "==========================="
sudo docker system df
compose ps

echo "🛑 Stopping containers (data/volumes preserved — nothing deleted)..."
compose down

echo
echo "🎉 BloodHound CE installed!"
echo "📍 Directory: $BH_DIR/server"
echo "🔑 Credentials + restart command: $BH_DIR/server/initial-password.txt"
echo "▶️  Start it up: cd $BH_DIR/server && sudo docker compose up -d   (Neo4j: :7474, BloodHound: :8088)"
