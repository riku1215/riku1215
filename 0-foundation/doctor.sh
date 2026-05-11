#!/usr/bin/env bash
# Phase A Prerequisites Check - Linux/macOS
# Usage: ./doctor.sh
# Verifies environment before running setup.sh

set -uo pipefail

check_tool() {
    local name="$1" cmd="$2" install="$3"
    printf "  %s: " "$name"
    if command -v "$cmd" >/dev/null 2>&1; then
        ver=$("$cmd" --version 2>/dev/null | head -1)
        echo "OK ($ver)"
        return 0
    else
        echo "MISSING"
        echo "    Install: $install"
        return 1
    fi
}

check_disk() {
    local path="$1" min_gb="$2"
    if [ ! -d "$path" ]; then
        path=$(dirname "$path")
    fi
    free_gb=$(df -BG "$path" 2>/dev/null | awk 'NR==2 {gsub("G","",$4); print $4}')
    if [ -z "$free_gb" ]; then
        echo "  Disk space for $path: UNKNOWN"
        return 1
    fi
    printf "  Disk space for %s: %s GB " "$path" "$free_gb"
    if [ "$free_gb" -ge "$min_gb" ]; then
        echo "(>= $min_gb GB OK)"
        return 0
    else
        echo "(< $min_gb GB INSUFFICIENT)"
        return 1
    fi
}

echo "===== Phase A Doctor ====="
echo ""
echo "=== Required tools ==="
tools_ok=true
check_tool "Git" "git" "apt install git / brew install git" || tools_ok=false
check_tool "GitHub CLI" "gh" "apt install gh / brew install gh" || tools_ok=false
check_tool "ripgrep" "rg" "apt install ripgrep / brew install ripgrep" || tools_ok=false
check_tool "jq" "jq" "apt install jq / brew install jq" || tools_ok=false

echo ""
echo "=== GitHub authentication ==="
if gh auth status >/dev/null 2>&1; then
    echo "  gh auth: OK"
    gh auth status 2>&1 | head -5 | sed 's/^/    /'
else
    echo "  gh auth: NOT AUTHENTICATED"
    echo "    Run: gh auth login   OR set GH_TOKEN environment variable"
fi

echo ""
echo "=== Disk space ==="
disk_ok=true
check_disk "$HOME" 20 || disk_ok=false

echo ""
echo "=== Optional: Phase D prerequisites ==="
check_tool "Python" "python3" "apt install python3 / brew install python" || true
check_tool "Ollama" "ollama" "Download from https://ollama.com/download" || true

echo ""
echo "===== Summary ====="
if [ "$tools_ok" = true ] && [ "$disk_ok" = true ]; then
    echo "Ready to run: ./setup.sh"
else
    echo "Fix missing prerequisites before running setup.sh"
fi
