#!/bin/bash
# _common.sh — sourced by every script. Not run directly, not globbed by
# start_automation.sh. Gives every install_*.sh: quiet output (real output
# goes to /tmp/.htb_logs/<script>.log, terminal only gets a spinner + final
# ✅/❌), noninteractive apt, flock-safe apt/PATH/toolchain helpers (safe to
# run scripts in parallel), and per-script timing.

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export NEEDRESTART_SUSPEND=1
export HTB_BASE_DIR="${HTB_BASE_DIR:-/opt}"

_NAME="$(basename "$0")"
_IS_TTY=0; [ -t 1 ] && _IS_TTY=1
mkdir -p /tmp/.htb_logs
_LOG="/tmp/.htb_logs/${_NAME%.sh}.log"
: > "$_LOG"

exec 3>&1                       # fd3 = real terminal, kept even if fd1 is redirected below
say() { echo "$@" >&3; }        # print to the real terminal, bypassing any log redirect

if [[ "$_NAME" == install_* ]]; then
    exec >>"$_LOG" 2>&1         # noisy tool output -> log only, from here on
fi

# --- spinner: only for standalone runs (parallel runs would garble a shared one) ---
_SPIN_PID=""
if [[ "$_NAME" == install_* && -z "$HTB_ORCHESTRATED" && "$_IS_TTY" == 1 ]]; then
    ( trap 'exit 0' TERM
      while :; do for c in / - '\' '|'; do printf '\r▶ %s installing... %s ' "$_NAME" "$c" >&3; sleep 0.25; done; done ) &
    _SPIN_PID=$!
    disown "$_SPIN_PID" 2>/dev/null
fi

_SCRIPT_START=$(date +%s)
_TIMING_LOG="${HTB_TIMING_LOG:-/tmp/.htb_automation_timings.log}"
_PRINT_LOCK="/tmp/.htb_print.lock"

_on_exit() {
    local rc=$?
    [ -n "$_SPIN_PID" ] && kill "$_SPIN_PID" 2>/dev/null
    [ "$_IS_TTY" == 1 ] && printf '\r\033[K' >&3
    local elapsed=$(( $(date +%s) - _SCRIPT_START ))
    echo "$_NAME ${elapsed}s" >> "$_TIMING_LOG" 2>/dev/null

    exec {lfd}>"$_PRINT_LOCK"; flock "$lfd"
    if [[ "$_NAME" == install_* ]]; then
        if [ $rc -ne 0 ]; then
            say "❌ FAILED at: $_NAME (${elapsed}s) -- $BASH_COMMAND"
            tail -n 8 "$_LOG" >&3
        elif [ -z "$HTB_ORCHESTRATED" ]; then
            say "✅ $_NAME (${elapsed}s)"
        fi
    fi
    flock -u "$lfd"; exec {lfd}>&-
    return 0
}
trap _on_exit EXIT

# --- apt, flock-guarded so parallel scripts don't fight over the dpkg lock ---
_APT_LOCK="/tmp/.htb_apt.lock"
apt_update() {  # once per run — 7 scripts call this, each was a full serialized update
    local stamp="/tmp/.htb_apt_updated"
    [ -f "$stamp" ] && return 0
    exec {afd}>"$_APT_LOCK"; flock "$afd"
    [ -f "$stamp" ] || { sudo -E apt-get -o Acquire::Languages=none update -qq && touch "$stamp"; }
    flock -u "$afd"; exec {afd}>&-
}
apt_install() {  # apt_install <packages...>, retries transient dpkg failures
    local attempt=1 max=3
    while [ $attempt -le $max ]; do
        exec {afd}>"$_APT_LOCK"; flock "$afd"
        if sudo -E apt-get install -y \
            -o Dpkg::Options::="--force-confdef" \
            -o Dpkg::Options::="--force-confold" \
            "$@"; then
            flock -u "$afd"; exec {afd}>&-
            return 0
        fi
        flock -u "$afd"; exec {afd}>&-
        sleep 10
        attempt=$((attempt + 1))
    done
    return 1
}

# --- shared toolchain bootstraps (flock-guarded: safe if 2 scripts need them at once) ---
ensure_uv() {
    command -v uv >/dev/null 2>&1 || {
        exec {tfd}>/tmp/.htb_uv.lock; flock "$tfd"
        command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh
        flock -u "$tfd"; exec {tfd}>&-
    }
    export PATH="$HOME/.local/bin:$PATH"
}
ensure_cargo() {
    command -v cargo >/dev/null 2>&1 || {
        exec {tfd}>/tmp/.htb_cargo.lock; flock "$tfd"
        command -v cargo >/dev/null 2>&1 || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        flock -u "$tfd"; exec {tfd}>&-
    }
    export PATH="$HOME/.cargo/bin:$PATH"
}

# --- add_to_path <line> [<line> ...]: dedupes old PATH line(s), appends new ones, flock-guarded ---
add_to_path() {
    exec {bfd}>/tmp/.htb_bashrc.lock; flock "$bfd"
    sed -i '/export PATH=/d' "$HOME/.bashrc" 2>/dev/null
    printf '%s\n' "$@" >> "$HOME/.bashrc"
    flock -u "$bfd"; exec {bfd}>&-
}

# --- gh_latest <owner/repo>: latest tag via redirect (no API, no rate limit) ---
gh_latest() {
    curl -sI "https://github.com/$1/releases/latest" \
        | grep -i '^location:' | awk '{print $2}' | tr -d '\r\n' | xargs basename
}

# --- dl <url> <out>: download with retries ---
dl() { curl -fsSL --retry 3 --retry-delay 2 -o "$2" "$1"; }
