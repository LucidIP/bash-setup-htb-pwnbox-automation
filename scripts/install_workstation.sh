#!/bin/bash
set -e
# install_workstation.sh — tmux + Firefox + VS Code (ILSpy, Snyk). Each piece is skippable
# via start_automation.sh flags: --skip-tmux / --skip-colors / --skip-firefox / --skip-code.
source "$(dirname "$0")/_common.sh"

SKIP_COLORS="${HTB_SKIP_COLORS:-0}"
SKIP_TMUX="${HTB_SKIP_TMUX:-0}"
SKIP_FIREFOX="${HTB_SKIP_FIREFOX:-0}"
SKIP_CODE="${HTB_SKIP_CODE:-0}"

apt_update
# ncurses-term = tmux-256color terminfo; xclip = copy out to system clipboard
apt_install tmux ncurses-term xclip

if [ "$SKIP_TMUX" != "1" ]; then
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
# copy-pipe (not copy-selection) so it reaches xclip/system clipboard, not just tmux's buffer
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-no-clear "xclip -selection clipboard -in"
bind -T copy-mode    MouseDragEnd1Pane send -X copy-pipe-no-clear "xclip -selection clipboard -in"
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-pipe-no-clear "xclip -selection clipboard -in"
bind -T copy-mode-vi Enter send -X copy-pipe-and-cancel "xclip -selection clipboard -in"

set -sg escape-time 0
set -g base-index 0
setw -g pane-base-index 0
set -g renumber-windows on
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
EOF

    if [ "$SKIP_COLORS" != "1" ]; then
        cat >> "$HOME/.tmux.conf" << 'EOF'
# --- pwnbox palette --- HTB green #9fef00 + navy #141a26 (brand guide), blue #004cff (terminal scheme)
# pane text white by default; explicit ANSI colours (ls, prompts) still win
set -g window-style "fg=#ffffff"
set -g window-active-style "fg=#ffffff"
set -g status-style "bg=#141a26,fg=#ffffff"
set -g status-left "#[bg=#004cff,fg=#ffffff,bold] HTB #[bg=#141a26,fg=#004cff]#[default]"
set -g status-left-length 20
set -g status-right "#[fg=#004cff]#(whoami)#[fg=#ffffff]@#h | #[fg=#004cff]%H:%M "
set -g window-status-current-style "bg=#9fef00,fg=#141a26,bold"
set -g window-status-style "fg=#ffffff"
set -g pane-border-style "fg=#141a26"
set -g pane-active-border-style "fg=#004cff"
set -g message-style "bg=#9fef00,fg=#141a26,bold"
EOF
    fi

    # config only binds to a NEW server — reload if one is already running
    tmux source-file "$HOME/.tmux.conf" 2>/dev/null || true
fi

if [ "$SKIP_COLORS" != "1" ]; then
    # HTB green/navy/blue, verified: green+navy from hackthebox.com's brand guide, blue from
    # the established HTB terminal scheme (github.com/audibleblink/hackthebox.vim)
    cat > "$HOME/.htb_colors.sh" << 'EOF'
export COLORTERM=truecolor
# blue dirs, green executables, white files — same as pwnbox
export LS_COLORS="${LS_COLORS}:no=38;2;255;255;255:fi=38;2;255;255;255:di=1;38;2;0;76;255:ex=1;38;2;159;239;0:ln=38;2;46;231;182:"
EOF
    grep -q 'htb_colors.sh' "$HOME/.bashrc" 2>/dev/null || \
        echo '[ -f "$HOME/.htb_colors.sh" ] && . "$HOME/.htb_colors.sh"' >> "$HOME/.bashrc"

    # force the same palette on the actual terminal profile too -- not just ls/tmux, every
    # plain terminal window should open already in HTB colors. Best-effort: silently skipped
    # on desktops/terminal versions where these schemas/keys don't exist.
    HTB_PALETTE="#000000:#FF3E3E:#9FEF00:#FFAF00:#004CFF:#9F00FF:#2EE7B6:#FFFFFF:#666666:#FF8484:#C5F467:#FFCC5C:#5CB2FF:#C16CFA:#5CECC6:#FFFFFF"
    if command -v gsettings >/dev/null 2>&1; then
        # mate terminal (parrot default)
        MT="org.mate.terminal.profile:/org/mate/terminal/profiles/default/"
        gsettings set "$MT" use-theme-colors false 2>/dev/null
        gsettings set "$MT" background-color '#141A26' 2>/dev/null
        gsettings set "$MT" foreground-color '#FFFFFF' 2>/dev/null
        gsettings set "$MT" palette "$HTB_PALETTE" 2>/dev/null
        # gnome terminal (pwnbox) -- profile id is dynamic, look it up first
        GT_ID=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
        if [ -n "$GT_ID" ]; then
            GT="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GT_ID/"
            gsettings set "$GT" use-theme-colors false 2>/dev/null
            gsettings set "$GT" background-color "'#141A26'" 2>/dev/null
            gsettings set "$GT" foreground-color "'#FFFFFF'" 2>/dev/null
            gsettings set "$GT" palette "['#000000','#FF3E3E','#9FEF00','#FFAF00','#004CFF','#9F00FF','#2EE7B6','#FFFFFF','#666666','#FF8484','#C5F467','#FFCC5C','#5CB2FF','#C16CFA','#5CECC6','#FFFFFF']" 2>/dev/null
        fi
    fi
fi

if [ "$SKIP_FIREFOX" != "1" ]; then
    command -v firefox >/dev/null 2>&1 || command -v firefox-esr >/dev/null 2>&1 || apt_install firefox-esr

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
fi

if [ "$SKIP_CODE" != "1" ]; then
    # standardizing on VS Code only -- drop VSCodium if it's on the box
    sudo apt remove -y codium vscodium 2>/dev/null
    sudo rm -f /usr/bin/codium /usr/local/bin/codium 2>/dev/null

    if command -v code >/dev/null 2>&1; then
        code --install-extension icsharpcode.ilspy-vscode --force >/dev/null 2>&1               # .NET decompiler
        code --install-extension snyk-security.snyk-vulnerability-scanner --force >/dev/null 2>&1 # vuln scanning
    fi
fi

echo "🔍 workstation"
[ "$SKIP_TMUX" != "1" ] && { tmux -V; echo "term=$TERM_DEF"; }
[ "$SKIP_CODE" != "1" ] && command -v code >/dev/null 2>&1 && echo "vscode-ext=ilspy-vscode,snyk-security"
echo "✅ workstation ready (running tmux: tmux kill-server for a full reload)"
