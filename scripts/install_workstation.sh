#!/bin/bash
set -e
# install_workstation.sh — tmux (pwnbox theme, mouse scroll+copy across full history) + Firefox (FoxyProxy/uBlock/Wappalyzer -> Burp 127.0.0.1:8080).
source "$(dirname "$0")/_common.sh"

apt_update
# ncurses-term = tmux-256color terminfo; xclip = copy out to system clipboard
apt_install tmux ncurses-term xclip
command -v firefox >/dev/null 2>&1 || command -v firefox-esr >/dev/null 2>&1 || apt_install firefox-esr

# fall back if tmux-256color terminfo is still missing (older/minimal builds)
TERM_DEF="tmux-256color"
infocmp tmux-256color >/dev/null 2>&1 || TERM_DEF="screen-256color"

[ -f "$HOME/.tmux.conf" ] && cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$(date +%s)"
cat > "$HOME/.tmux.conf" << EOF
set -g default-terminal "$TERM_DEF"
EOF
cat >> "$HOME/.tmux.conf" << 'EOF'
# truecolor: match any 256-colour TERM, not just xterm-256color (parrot terminals vary).
# Tc covers tmux < 3.2; terminal-features is guarded so old tmux never errors.
set -ag terminal-overrides ",*256col*:RGB,*256col*:Tc,xterm*:RGB,screen*:RGB"
if -b '[ "$(tmux -V | cut -d" " -f2 | tr -d "a-z")" \> "3.1" ]' 'set -as terminal-features ",*:RGB"'

# --- mouse: scroll + select across the whole scrollback, not just the visible pane ---
set -g mouse on
set -g history-limit 200000
setw -g mode-keys vi
set -s set-clipboard on
# wheel scrolls history instead of sending arrow keys
bind -n WheelUpPane if -Ft= "#{mouse_any_flag}" "send -M" "if -Ft= '#{pane_in_mode}' 'send -M' 'copy-mode -e'"
bind -n WheelDownPane send -M
# releasing a drag keeps copy mode open -> keep scrolling up and extend the selection
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-selection-no-clear
bind -T copy-mode    MouseDragEnd1Pane send -X copy-selection-no-clear
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-selection-no-clear

# --- pwnbox palette ---
# pane text white by default; explicit ANSI colours (ls, prompts) still win
set -g window-style "fg=#ffffff"
set -g window-active-style "fg=#ffffff"
set -g status-style "bg=#0d1117,fg=#ffffff"
set -g status-left "#[bg=#0057ff,fg=#ffffff,bold] HTB #[bg=#0d1117,fg=#0057ff]#[default]"
set -g status-left-length 20
set -g status-right "#[fg=#0057ff]#(whoami)#[fg=#ffffff]@#h | #[fg=#0057ff]%H:%M "
set -g window-status-current-style "bg=#39ff14,fg=#0d1117,bold"
set -g window-status-style "fg=#ffffff"
set -g pane-border-style "fg=#0d1117"
set -g pane-active-border-style "fg=#0057ff"
set -g message-style "bg=#39ff14,fg=#0d1117,bold"
set -sg escape-time 0
set -g base-index 0
setw -g pane-base-index 0
set -g renumber-windows on
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
EOF

# matching blue dirs + truecolor, idempotent
cat > "$HOME/.htb_colors.sh" << 'EOF'
export COLORTERM=truecolor
# blue dirs, green executables, white files — same as pwnbox
export LS_COLORS="${LS_COLORS}:no=38;2;255;255;255:fi=38;2;255;255;255:di=1;38;2;0;87;255:ex=1;38;2;57;255;20:ln=38;2;0;191;255:"
EOF
grep -q 'htb_colors.sh' "$HOME/.bashrc" 2>/dev/null || \
    echo '[ -f "$HOME/.htb_colors.sh" ] && . "$HOME/.htb_colors.sh"' >> "$HOME/.bashrc"

# config only binds to a NEW server — reload if one is already running
tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true

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

echo "🔍 workstation"; tmux -V; echo "term=$TERM_DEF"
echo "✅ tmux + firefox ready (running tmux: tmux kill-server for a full reload)"
