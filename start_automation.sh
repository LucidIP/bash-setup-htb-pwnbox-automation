#!/bin/bash
# start_automation.sh — cleanup, then every scripts/install_*.sh in parallel.
# Adding a tool = drop a new scripts/install_<name>.sh in; it's picked up
# automatically. Add its name to ORDER below to control when it starts.

START=$(date +%s)
SKIP_CLEAN=0
export HTB_BASE_DIR="/opt"

# 2 at a time — steady on a VM, and past this the run is bound by the single
# longest job anyway. Raise only if you know the box can take it.
PARALLEL=2

usage() {
    cat << 'EOF'
usage: ./start_automation.sh [options]

  --skip-clean      update tools, skip the cleanup wipe
  --skip-colors     don't force HTB colors/theme (tmux palette, ls, terminal profile)
  --skip-tmux       don't touch tmux config
  --skip-firefox    don't touch Firefox config
  --skip-code       don't touch VS Code (extensions, codium removal)
  --path DIR        install to DIR instead of /opt (nested ok: /path/path)
  -h, --help        this

more flags coming as the project grows.
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-clean) SKIP_CLEAN=1; shift ;;
        --skip-colors) export HTB_SKIP_COLORS=1; shift ;;
        --skip-tmux) export HTB_SKIP_TMUX=1; shift ;;
        --skip-firefox) export HTB_SKIP_FIREFOX=1; shift ;;
        --skip-code) export HTB_SKIP_CODE=1; shift ;;
        --path) export HTB_BASE_DIR="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "unknown option: $1"; echo "try -h"; exit 1 ;;
    esac
done

cd "$(dirname "$0")/scripts" || exit 1
export HTB_ORCHESTRATED=1
export HTB_TIMING_LOG="/tmp/.htb_automation_timings.log"
rm -f "$HTB_TIMING_LOG" /tmp/.htb_apt_updated
source ./_common.sh
mkdir -p /tmp/.htb_logs
rm -f /tmp/.htb_logs/*.rc

sudo -v  # prime sudo once so parallel scripts never race for a password prompt

if [[ $SKIP_CLEAN -eq 0 ]]; then
    echo "🧹 cleanup..."
    bash cleanup.sh --path "$HTB_BASE_DIR" && echo "✅ cleanup" || { echo "❌ cleanup failed"; exit 1; }
else
    echo "⏭️  cleanup skipped"
fi

# slowest first — starting them last leaves everything waiting on one tail.
# anything not listed still runs, appended after these.
ORDER=(install_bloodhound.sh install_reference.sh install_ad_tools.sh install_enum_tools.sh
       install_manspider.sh install_workstation.sh install_hashcat.sh install_pivot.sh
       install_rusthound.sh install_cli_tools.sh install_evilwinrm.sh)
scripts=()
for s in "${ORDER[@]}"; do [[ -f "$s" ]] && scripts+=("$s"); done
for s in install_*.sh; do [[ -f "$s" ]] && { [[ " ${scripts[*]} " == *" $s "* ]] || scripts+=("$s"); }; done
count=${#scripts[@]}
echo "🚀 $count tools, $PARALLEL at a time"
echo

# each job reports the moment it ends — no polling, no repeated counters.
# failures print themselves from _common.sh with the tail of their log.
running=0
for script in "${scripts[@]}"; do
    (
        t=$(date +%s); n="${script%.sh}"
        bash "$script"; rc=$?
        echo $rc > "/tmp/.htb_logs/$n.rc"
        [[ $rc -eq 0 ]] && say "  ✅ $(printf '%-12s' "${n#install_}") $(( $(date +%s) - t ))s"
    ) &
    running=$((running + 1))
    if (( running >= PARALLEL )); then wait -n; running=$((running - 1)); fi
done
wait

echo "🧹 releasing install caches..."
bash cleanup.sh --cache-only

ok=0; bad=()
for script in "${scripts[@]}"; do
    n="${script%.sh}"
    if [[ "$(cat "/tmp/.htb_logs/$n.rc" 2>/dev/null || echo 1)" == "0" ]]; then
        ok=$((ok + 1))
    else
        bad+=("${n#install_}")
    fi
done

TOTAL=$(( $(date +%s) - START ))
echo
echo "──────── summary ────────"
printf '  %s/%s ok · %dm%02ds\n' "$ok" "$count" $((TOTAL/60)) $((TOTAL%60))
if [[ -s "$HTB_TIMING_LOG" ]]; then
    printf '  slowest: '
    sed 's/install_//;s/\.sh//' "$HTB_TIMING_LOG" | sort -k2 -rn -t' ' \
        | head -3 | awk '{printf "%s %s  ", $1, $2}'
    echo
fi
if ((${#bad[@]})); then
    echo "  ❌ ${bad[*]}"
    echo "  logs: /tmp/.htb_logs/<name>.log"
    exit 1
fi
echo "  logs: /tmp/.htb_logs/"
echo "🎉 ready to hunt"
exec bash -l
