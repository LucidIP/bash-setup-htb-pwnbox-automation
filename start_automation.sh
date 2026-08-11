#!/bin/bash
# start_automation.sh — runs cleanup.sh, then every install_*.sh in this directory.

cd "$(dirname "$0")"

echo "🧹 Running cleanup.sh..."
if [[ -f "cleanup.sh" ]]; then
    if bash cleanup.sh; then
        echo "✅ cleanup.sh OK"
    else
        echo "❌ cleanup.sh FAILED"; exit 1
    fi
else
    echo "❌ cleanup.sh NOT FOUND - REQUIRED"; exit 1
fi

count=0
for script in install_*.sh; do
    [[ -f "$script" ]] || continue
    ((count++))
    echo
    echo "▶️  $count: $script"
    if bash "$script"; then
        echo "✅ $script OK"
    else
        echo "❌ $script FAILED"; exit 1
    fi
done

echo
echo "🎉 All $count install scripts finished!"
exec bash -l
