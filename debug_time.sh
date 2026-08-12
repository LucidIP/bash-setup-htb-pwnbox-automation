#!/bin/bash
# _common.sh — sourced by every script in this repo (`source "$(dirname "$0")/_common.sh"`).
# Not meant to be run directly, and not matched by start_automation.sh's
# install_*.sh glob, so it's never treated as a step of its own.
#
# Provides:
#   - Fully noninteractive apt: no debconf dialogs (e.g. the pwnbox-insights
#     vs NetworkManager service picker), no "which services should be
#     restarted?" needrestart prompt — both auto-answer with the default.
#   - apt_install / apt_update wrappers that retry on the transient
#     "dpkg returned an error code (1)" some packages (like docker.io) throw
#     when installed right after a fresh pwnbox boot, before the system has
#     settled. Retries with a 10s backoff instead of needing a manual rerun.
#   - Automatic per-script timing: prints elapsed time on exit (success OR
#     failure) via a trap, so speed/perf can be compared across runs later.

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export NEEDRESTART_SUSPEND=1

_SCRIPT_START=$(date +%s)
_print_elapsed() {
    local elapsed=$(( $(date +%s) - _SCRIPT_START ))
    echo "⏱️  DEBUG_TIME[$(basename "$0")]=${elapsed}s"
}
trap _print_elapsed EXIT

apt_update() {
    sudo -E apt-get update -qq
}

# apt_install <packages...>
apt_install() {
    local attempt=1 max=3
    while [ $attempt -le $max ]; do
        if sudo -E apt-get install -y \
            -o Dpkg::Options::="--force-confdef" \
            -o Dpkg::Options::="--force-confold" \
            "$@"; then
            return 0
        fi
        echo "⚠️  apt install failed (attempt $attempt/$max) — retrying in 10s..."
        sleep 10
        attempt=$((attempt + 1))
    done
    echo "❌ apt install failed after $max attempts: $*"
    return 1
}
