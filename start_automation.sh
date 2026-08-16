#!/bin/bash
# start_automation.sh [--skip-clean] [--path DIR] — cleanup.sh (unless skipped),
# then every install_*.sh in parallel (bounded by HTB_MAX_PARALLEL, default 4).

SKIP_CLEAN=0
export HTB_BASE_DIR="/opt"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-clean) SKIP_CLEAN=1; shift ;;
        --path) export HTB_BASE_DIR="$2"; shift 2 ;;
        *) echo "unknown option: $1"; exit 1 ;;
    esac
done

cd "$(dirname "$0")/scripts" || exit 1
export HTB_ORCHESTRATED=1
export HTB_TIMING_LOG="/tmp/.htb_automation_timings.log"
export HTB_MAX_PARALLEL="${HTB_MAX_PARALLEL:-4}"
rm -f "$HTB_TIMING_LOG"
source ./_common.sh
mkdir -p /tmp/.htb_logs
rm -f /tmp/.htb_logs/*.rc

sudo -v  # prime sudo once, up front, so parallel scripts never race for a password prompt

if [[ $SKIP_CLEAN -eq 0 ]]; then
    echo "🧹 cleanup.sh..."
    bash cleanup.sh --path "$HTB_BASE_DIR" && echo "✅ cleanup OK" || { echo "❌ cleanup FAILED"; exit 1; }
else
    echo "⏭️  cleanup skipped, updating tools in place..."
fi

scripts=(install_*.sh)
count=${#scripts[@]}
echo "🚀 Installing $count tools (up to $HTB_MAX_PARALLEL at a time)..."

( while :; do
    sleep 20
    d=$(shopt -s nullglob; f=(/tmp/.htb_logs/*.rc); echo "${#f[@]}")
    echo "⏳ $d/$count done..."
done ) &
HEARTBEAT=$!
disown "$HEARTBEAT" 2>/dev/null

running=0
for script in "${scripts[@]}"; do
    [[ -f "$script" ]] || continue
    ( bash "$script"; echo $? > "/tmp/.htb_logs/${script%.sh}.rc" ) &
    running=$((running + 1))
    if (( running >= HTB_MAX_PARALLEL )); then
        wait -n
        running=$((running - 1))
    fi
done
wait
kill "$HEARTBEAT" 2>/dev/null

failed=0
for script in "${scripts[@]}"; do
    [[ -f "$script" ]] || continue
    rc=$(cat "/tmp/.htb_logs/${script%.sh}.rc" 2>/dev/null || echo 1)
    [[ "$rc" == "0" ]] && echo "✅ $script" || { echo "❌ $script (log: /tmp/.htb_logs/${script%.sh}.log)"; failed=1; }
done

echo "⏱️ times:"
if [[ -s "$HTB_TIMING_LOG" ]]; then
    command -v column >/dev/null 2>&1 && column -t "$HTB_TIMING_LOG" || cat "$HTB_TIMING_LOG"
fi

[[ $failed -eq 1 ]] && { echo "❌ some installs failed"; exit 1; }
echo "🎉 done!"
exec bash -l
