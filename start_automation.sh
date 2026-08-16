#!/bin/bash
# start_automation.sh [--skip-clean] [--path DIR] — cleanup.sh (unless skipped),
# then every install_*.sh in parallel (bounded by HTB_MAX_PARALLEL, default 4).

START=$(date +%s)
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
# concurrency scales to the box (pwnbox vs VM). work is network/IO-bound, so 2x cpus,
# capped at 6, and never more jobs than GB of free RAM. override: HTB_MAX_PARALLEL=n
if [[ -z "$HTB_MAX_PARALLEL" ]]; then
    _c=$(nproc 2>/dev/null || echo 2)
    _r=$(awk '/MemAvailable/{print int($2/1048576)}' /proc/meminfo 2>/dev/null || echo 4)
    _n=$((_c * 2)); ((_n > 6)) && _n=6; ((_n > _r)) && _n=_r; ((_n < 2)) && _n=2
    HTB_MAX_PARALLEL=$_n
fi
export HTB_MAX_PARALLEL
rm -f "$HTB_TIMING_LOG" /tmp/.htb_apt_updated
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

# longest jobs first — starting the slow ones last leaves everything waiting on one tail
ORDER=(install_bloodhound.sh install_reference.sh install_ad_tools.sh install_enum_tools.sh
       install_manspider.sh install_workstation.sh install_hashcat.sh install_pivot.sh
       install_rusthound.sh install_cli_tools.sh install_evilwinrm.sh)
scripts=()
for s in "${ORDER[@]}"; do [[ -f "$s" ]] && scripts+=("$s"); done
for s in install_*.sh; do [[ -f "$s" ]] && { [[ " ${scripts[*]} " == *" $s "* ]] || scripts+=("$s"); }; done
count=${#scripts[@]}
echo "🚀 Installing $count tools (up to $HTB_MAX_PARALLEL at a time)..."

# each script announces itself the moment it ends — no polling, no repeats.
# failures print themselves from _common.sh with the last log lines.
running=0
for script in "${scripts[@]}"; do
    [[ -f "$script" ]] || continue
    (
        t=$(date +%s); n="${script%.sh}"
        bash "$script"; rc=$?
        echo $rc > "/tmp/.htb_logs/$n.rc"
        [[ $rc -eq 0 ]] && say "✅ ${n#install_} ($(( $(date +%s) - t ))s)"
    ) &
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
    [[ "$(cat "/tmp/.htb_logs/${script%.sh}.rc" 2>/dev/null || echo 1)" == "0" ]] || failed=1
done

[[ $failed -eq 1 ]] && { echo "❌ some installs failed — logs: /tmp/.htb_logs/"; exit 1; }
echo "🎉 done in $(( $(date +%s) - START ))s"
exec bash -l
