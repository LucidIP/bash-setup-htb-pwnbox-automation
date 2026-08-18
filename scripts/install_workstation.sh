#!/bin/bash
set -e
# install_workstation.sh — tmux (scroll, index, HTB colors+background, copy -> OS clipboard)
# + Firefox + VS Code (ILSpy, Snyk). Skippable: --skip-tmux / --skip-colors / --skip-firefox / --skip-code.
source "$(dirname "$0")/_common.sh"

SKIP_COLORS="${HTB_SKIP_COLORS:-0}"
SKIP_TMUX="${HTB_SKIP_TMUX:-0}"
SKIP_FIREFOX="${HTB_SKIP_FIREFOX:-0}"
SKIP_CODE="${HTB_SKIP_CODE:-0}"

apt_update
apt_install tmux ncurses-term  # ncurses-term = tmux-256color terminfo

# VMware guest -> host clipboard bridge: only *-desktop ships the X11 clipboard plugin,
# the headless open-vm-tools package doesn't sync the clipboard to the host at all
if [ "$(systemd-detect-virt 2>/dev/null)" = "vmware" ]; then
    apt_install open-vm-tools-desktop 2>/dev/null || true
    sudo systemctl restart open-vm-tools.service 2>/dev/null || true
fi

if [ "$SKIP_TMUX" != "1" ]; then
    # fall back if tmux-256color terminfo is still missing (older/minimal builds)
    TERM_DEF="tmux-256color"
    infocmp tmux-256color >/dev/null 2>&1 || TERM_DEF="screen-256color"

    # OS clipboard tool for this session -- inspected once, used below. pbcopy/wl-copy
    # ship with macOS/Wayland already; on plain X11 (pwnbox, most Parrot) install xclip.
    CLIP_CMD=""
    if command -v pbcopy >/dev/null 2>&1; then
        CLIP_CMD="pbcopy"
    elif command -v wl-copy >/dev/null 2>&1; then
        CLIP_CMD="wl-copy"
    elif command -v xclip >/dev/null 2>&1; then
        CLIP_CMD="xclip -selection clipboard -in"
    elif [ -n "$WAYLAND_DISPLAY" ]; then
        apt_install wl-clipboard 2>/dev/null || true
        command -v wl-copy >/dev/null 2>&1 && CLIP_CMD="wl-copy"
    else
        apt_install xclip 2>/dev/null || true
        command -v xclip >/dev/null 2>&1 && CLIP_CMD="xclip -selection clipboard -in"
    fi

    [ -f "$HOME/.tmux.conf" ] && cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak.$(date +%s)"
    cat > "$HOME/.tmux.conf" << EOF
set -g default-terminal "$TERM_DEF"
EOF
    cat >> "$HOME/.tmux.conf" << 'EOF'
# truecolor: match any 256-colour TERM, not just xterm-256color (parrot terminals vary).
# Tc covers tmux < 3.2; terminal-features is guarded so old tmux never errors.
set -ag terminal-overrides ",*256col*:RGB,*256col*:Tc,xterm*:RGB,screen*:RGB"
if -b '[ "$(tmux -V | cut -d" " -f2 | tr -d "a-z")" \> "3.1" ]' 'set -as terminal-features ",*:RGB"'

# scrolling + clipboard sync -- everything else is stock tmux, no custom mouse bindings
set -g mouse on
set -g history-limit 200000
setw -g mode-keys vi
set -s set-clipboard on

# index
set -sg escape-time 0
set -g base-index 0
setw -g pane-base-index 0
set -g renumber-windows on
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
EOF

    # same 3 actions tmux already does by default (drag-release, y, Enter) -- just piped to
    # the OS clipboard above instead of only landing in tmux's own internal buffer
    if [ -n "$CLIP_CMD" ]; then
        cat >> "$HOME/.tmux.conf" << TMUXEOF
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "$CLIP_CMD"
bind -T copy-mode    MouseDragEnd1Pane send -X copy-pipe-and-cancel "$CLIP_CMD"
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "$CLIP_CMD"
bind -T copy-mode-vi Enter send -X copy-pipe-and-cancel "$CLIP_CMD"
TMUXEOF
    fi

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
    if command -v code >/dev/null 2>&1; then
        # only drop codium when a real VS Code is actually present to standardize on --
        # on some Parrot builds "code" doesn't exist and codium IS the only editor; removing
        # it there would leave nothing installed at all
        sudo apt remove -y codium vscodium 2>/dev/null || true
        sudo rm -f /usr/bin/codium /usr/local/bin/codium 2>/dev/null || true
        sudo rm -f /usr/share/applications/codium.desktop /usr/share/applications/*vscodium*.desktop 2>/dev/null || true
        rm -f "$HOME/.local/share/applications/"*codium*.desktop 2>/dev/null || true
        if command -v update-desktop-database >/dev/null 2>&1; then
            sudo update-desktop-database /usr/share/applications 2>/dev/null || true
        fi

        code --install-extension icsharpcode.ilspy-vscode --force >/dev/null 2>&1 || true               # .NET decompiler
        code --install-extension snyk-security.snyk-vulnerability-scanner --force >/dev/null 2>&1 || true # vuln scanning; sign in once per user to sync
    fi
fi

echo "🔍 workstation"
[ "$SKIP_TMUX" != "1" ] && { tmux -V; echo "term=$TERM_DEF"; [ -n "$CLIP_CMD" ] && echo "clipboard=$CLIP_CMD"; }
[ "$SKIP_CODE" != "1" ] && command -v code >/dev/null 2>&1 && echo "vscode-ext=ilspy-vscode,snyk-security"
echo "✅ workstation ready (running tmux: tmux kill-server for a full reload)"
