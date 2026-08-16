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
apt_install tmux ncurses-term  # ncurses-term = tmux-256color terminfo

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

# --- mouse: stock tmux behaviour for wheel (scrolls/enters copy-mode on its own) --
# but plain click-drag no longer auto-enters copy-mode: that's what caused the stray
# orange selection bar. Shift+drag still gets the terminal's own native selection/copy.
set -g mouse on
set -g history-limit 200000
setw -g mode-keys vi
set -s set-clipboard on
unbind -n MouseDrag1Pane
# stops the screen-flash on empty tab-completion (readline bell -> tmux was passing it through)
set -g bell-action none

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
# navy is forced as the pane background too, not just text colour
set -g window-style "fg=#ffffff,bg=#141a26"
set -g window-active-style "fg=#ffffff,bg=#141a26"
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

# terminal profile ids -- looked up once, used for colors below and for bell suppression
# further down (that part isn't gated behind --skip-colors, it's a separate bug fix)
MT_ID=""; GT_ID=""
if command -v gsettings >/dev/null 2>&1; then
    # mate: don't assume the id is literally "default" -- it's often "Default", case-sensitive
    MT_ID=$(gsettings get org.mate.terminal.global default-profile 2>/dev/null | tr -d "'")
    [ -z "$MT_ID" ] && MT_ID="Default"
    GT_ID=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
fi

if [ "$SKIP_COLORS" != "1" ]; then
    # HTB green/navy/blue, verified: green+navy from hackthebox.com's brand guide, blue from
    # the established HTB terminal scheme (github.com/audibleblink/hackthebox.vim)
    cat > "$HOME/.htb_colors.sh" << 'EOF'
export COLORTERM=truecolor
# blue dirs, green files (+ executables), white for everything else — same as pwnbox
export LS_COLORS="${LS_COLORS}:no=38;2;255;255;255:fi=1;38;2;159;239;0:di=1;38;2;0;76;255:ex=1;38;2;159;239;0:ln=38;2;46;231;182:"
EOF
    grep -q 'htb_colors.sh' "$HOME/.bashrc" 2>/dev/null || \
        echo '[ -f "$HOME/.htb_colors.sh" ] && . "$HOME/.htb_colors.sh"' >> "$HOME/.bashrc"

    # force the same palette on the actual terminal profile too -- not just ls/tmux, every
    # plain terminal window should open already in HTB colors. Best-effort: silently skipped
    # on desktops/terminal versions where these schemas/keys don't exist. Opens a NEW terminal
    # window to see it -- profile changes don't repaint windows already open.
    HTB_PALETTE="#000000:#FF3E3E:#9FEF00:#FFAF00:#004CFF:#9F00FF:#2EE7B6:#FFFFFF:#666666:#FF8484:#C5F467:#FFCC5C:#5CB2FF:#C16CFA:#5CECC6:#FFFFFF"
    if command -v gsettings >/dev/null 2>&1; then
        MT="org.mate.terminal.profile:/org/mate/terminal/profiles/$MT_ID/"
        gsettings set "$MT" use-theme-colors false 2>/dev/null
        gsettings set "$MT" background-color '#141A26' 2>/dev/null
        gsettings set "$MT" foreground-color '#FFFFFF' 2>/dev/null
        gsettings set "$MT" palette "$HTB_PALETTE" 2>/dev/null
        if [ -n "$GT_ID" ]; then
            GT="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GT_ID/"
            gsettings set "$GT" use-theme-colors false 2>/dev/null
            gsettings set "$GT" background-color "'#141A26'" 2>/dev/null
            gsettings set "$GT" foreground-color "'#FFFFFF'" 2>/dev/null
            gsettings set "$GT" palette "['#000000','#FF3E3E','#9FEF00','#FFAF00','#004CFF','#9F00FF','#2EE7B6','#FFFFFF','#666666','#FF8484','#C5F467','#FFCC5C','#5CB2FF','#C16CFA','#5CECC6','#FFFFFF']" 2>/dev/null
        fi
    fi
fi

# bell suppression, not gated behind --skip-colors -- separate concern (VMware/X screen-flash
# on tab-complete, tmux's own bell-action fix alone didn't fully cover it there)
command -v xset >/dev/null 2>&1 && [ -n "$DISPLAY" ] && xset b off 2>/dev/null
if command -v gsettings >/dev/null 2>&1; then
    gsettings set "org.mate.terminal.profile:/org/mate/terminal/profiles/$MT_ID/" audible-bell false 2>/dev/null
    [ -n "$GT_ID" ] && gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GT_ID/" audible-bell false 2>/dev/null
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
    # standardizing on VS Code only -- drop VSCodium (app + any leftover panel/menu shortcut)
    sudo apt remove -y codium vscodium 2>/dev/null
    sudo rm -f /usr/bin/codium /usr/local/bin/codium 2>/dev/null
    sudo rm -f /usr/share/applications/codium.desktop /usr/share/applications/*vscodium*.desktop 2>/dev/null
    rm -f "$HOME/.local/share/applications/"*codium*.desktop 2>/dev/null
    command -v update-desktop-database >/dev/null 2>&1 && sudo update-desktop-database /usr/share/applications 2>/dev/null

    if command -v code >/dev/null 2>&1; then
        code --install-extension icsharpcode.ilspy-vscode --force >/dev/null 2>&1               # .NET decompiler
        code --install-extension snyk-security.snyk-vulnerability-scanner --force >/dev/null 2>&1 # vuln scanning; each user signs in once to sync -- can't be automated without storing a token
    fi
fi

echo "🔍 workstation"
[ "$SKIP_TMUX" != "1" ] && { tmux -V; echo "term=$TERM_DEF"; }
[ "$SKIP_CODE" != "1" ] && command -v code >/dev/null 2>&1 && echo "vscode-ext=ilspy-vscode,snyk-security (snyk: sign in once to sync)"
echo "✅ workstation ready (running tmux: tmux kill-server for a full reload)"
