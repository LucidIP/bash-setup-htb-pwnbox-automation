#!/bin/bash
# start_automation.sh — cleanup.sh, then every install_*.sh in parallel (bounded by
# HTB_MAX_PARALLEL, default 4). Each script's own noisy output goes to its own log;
# failures print immediately (see _common.sh); one timing summary prints at the end.

cd "$(dirname "$0")" || exit 1
export HTB_ORCHESTRATED=1
export HTB_TIMING_LOG="/tmp/.htb_automation_timings.log"
export HTB_MAX_PARALLEL="${HTB_MAX_PARALLEL:-4}"
rm -f "$HTB_TIMING_LOG"
source ./_common.sh
mkdir -p /tmp/.htb_logs
rm -f /tmp/.htb_logs/*.rc

sudo -v  # prime sudo once, up front, so parallel scripts never race each other for a password prompt

echo "🧹 Running cleanup.sh..."
if bash cleanup.sh; then
    echo "✅ cleanup.sh OK"
else
    echo "❌ cleanup.sh FAILED"; exit 1
fi

scripts=(install_*.sh)
count=${#scripts[@]}
echo
echo "🚀 Installing $count tools (up to $HTB_MAX_PARALLEL at a time)..."

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

failed=0
for script in "${scripts[@]}"; do
    [[ -f "$script" ]] || continue
    rc=$(cat "/tmp/.htb_logs/${script%.sh}.rc" 2>/dev/null || echo 1)
    if [[ "$rc" == "0" ]]; then
        echo "✅ $script OK"
    else
        echo "❌ $script FAILED — log: /tmp/.htb_logs/${script%.sh}.log"
        failed=1
    fi
done

echo
echo "⏱️  Timing summary"
echo "=================="
if [[ -s "$HTB_TIMING_LOG" ]]; then
    command -v column >/dev/null 2>&1 && column -t "$HTB_TIMING_LOG" || cat "$HTB_TIMING_LOG"
else
    echo "(no timing data)"
fi

if [[ $failed -eq 1 ]]; then
    echo; echo "❌ One or more install scripts failed."
    exit 1
fi

echo
echo "🎉 All $count install scripts finished!"
exec bash -l
