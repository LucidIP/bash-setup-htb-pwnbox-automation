#!/bin/bash
set -e
# install_workstation.sh — desktop setup: tmux (pwnbox blue/green/white theme, mouse on) + Firefox (FoxyProxy/uBlock/Wappalyzer -> Burp 127.0.0.1:8080).
source "$(dirname "$0")/_common.sh"

apt_update
apt_install tmux
command -v firefox >/dev/null 2>&1 || command -v firefox-esr >/dev/null 2>&1 || apt_install firefox-esr

# --- tmux: pwnbox-style config, mouse on fixes trackpad scroll + click-drag copy ---
[ -f "$HOME/.tmux.conf" ] && cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$(date +%s)"
cat > "$HOME/.tmux.conf" << 'EOF'
set -g mouse on
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
set -g history-limit 50000
set -sg escape-time 0
set -g status-style "bg=#0d1117,fg=#ffffff"
set -g status-left "#[bg=#0057ff,fg=#ffffff,bold] HTB #[bg=#0d1117,fg=#0057ff]#[default]"
set -g status-left-length 20
set -g status-right "#[fg=#39ff14]#(whoami)@#h #[fg=#ffffff]| #[fg=#0057ff]%H:%M "
set -g window-status-current-style "bg=#39ff14,fg=#0d1117,bold"
set -g window-status-style "fg=#ffffff"
set -g pane-border-style "fg=#0d1117"
set -g pane-active-border-style "fg=#0057ff"
set -g message-style "bg=#39ff14,fg=#0d1117,bold"
setw -g mode-keys vi
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
EOF

# --- Firefox: enterprise policy, no browser launch / tabs opened ---
POLICY_DIR="/etc/firefox/policies"
sudo mkdir -p "$POLICY_DIR"
sudo tee "$POLICY_DIR/policies.json" > /dev/null << 'EOF'
{
  "policies": {
    "Extensions": {
      "Install": [
        "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi",
        "https://addons.mozilla.org/firefox/downloads/latest/wappalyzer/latest.xpi"
      ]
    },
    "Proxy": {
      "Mode": "manual",
      "Locked": false,
      "HTTPProxy": "127.0.0.1:8080",
      "UseHTTPProxyForAllProtocols": true,
      "SSLProxy": "127.0.0.1:8080",
      "Passthrough": "<local>"
    },
    "3rdparty": {
      "Extensions": {
        "foxyproxy@eric.h.jung": {
          "data": [
            { "active": true, "title": "BurpSuite", "type": "http", "hostname": "127.0.0.1",
              "port": "8080", "color": "#e66100", "proxyDNS": true, "include": [], "exclude": [] }
          ]
        }
      }
    }
  }
}
EOF

echo "🔍 DEBUG: workstation"; tmux -V; cat "$POLICY_DIR/policies.json"
echo "✅ tmux + Firefox ready! (extensions install / proxy applies on next Firefox launch)"
