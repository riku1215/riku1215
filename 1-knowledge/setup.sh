#!/usr/bin/env bash
# setup.sh - Linux/macOS bash equivalent of setup.ps1
# Builds local KB at $HOME/.kb/ by cloning all riku1215 repos and fetching all issues.
#
# Usage: ./setup.sh
# Prerequisites: gh CLI authenticated, git, jq

set -euo pipefail

KB_ROOT="${HOME}/.kb"
REPOS_DIR="${KB_ROOT}/repos"
ISSUES_DIR="${KB_ROOT}/issues"
LOG_FILE="${KB_ROOT}/setup.log"

# === Prerequisites check ===
command -v gh >/dev/null 2>&1 || { echo "ERROR: gh CLI not installed"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "ERROR: git not installed"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "ERROR: jq not installed"; exit 1; }

gh auth status >/dev/null 2>&1 || { echo "ERROR: gh not authenticated (run 'gh auth login' or set GH_TOKEN)"; exit 1; }

mkdir -p "${REPOS_DIR}" "${ISSUES_DIR}"

log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "${LOG_FILE}"; }

log "=== Phase 1: Repo discovery ==="
gh repo list riku1215 --json name,visibility,defaultBranchRef,updatedAt,description --limit 100 > "${KB_ROOT}/repos.json"
REPO_COUNT=$(jq 'length' "${KB_ROOT}/repos.json")
log "Found ${REPO_COUNT} repos"

# === Phase 2: Clone all repos ===
log "=== Phase 2: Cloning ${REPO_COUNT} repos (depth=100) ==="
FAILED_CLONES=()
i=0
while IFS= read -r name; do
    i=$((i + 1))
    target="${REPOS_DIR}/${name}"
    if [ -d "${target}/.git" ]; then
        log "  [${i}/${REPO_COUNT}] ${name} (skip - already exists)"
        continue
    fi
    log "  [${i}/${REPO_COUNT}] cloning ${name}..."
    if ! gh repo clone "riku1215/${name}" "${target}" -- --depth=100 --quiet 2>>"${LOG_FILE}"; then
        log "  WARNING: failed to clone ${name}"
        FAILED_CLONES+=("${name}")
    fi
done < <(jq -r '.[].name' "${KB_ROOT}/repos.json")

if [ ${#FAILED_CLONES[@]} -gt 0 ]; then
    log "Failed clones: ${FAILED_CLONES[*]}"
fi

# === Phase 3: Fetch issues ===
log "=== Phase 3: Fetching issues for ${REPO_COUNT} repos ==="
i=0
TOTAL_ISSUES=0
while IFS= read -r name; do
    i=$((i + 1))
    log "  [${i}/${REPO_COUNT}] ${name} issues..."
    if gh issue list -R "riku1215/${name}" --state all --limit 9999 \
        --json number,title,body,labels,comments,state,createdAt,closedAt,updatedAt,author,assignees,url \
        > "${ISSUES_DIR}/${name}.json" 2>>"${LOG_FILE}"; then
        count=$(jq 'length' "${ISSUES_DIR}/${name}.json" 2>/dev/null || echo 0)
        TOTAL_ISSUES=$((TOTAL_ISSUES + count))
    else
        echo "[]" > "${ISSUES_DIR}/${name}.json"
    fi
done < <(jq -r '.[].name' "${KB_ROOT}/repos.json")

# === Summary ===
KB_SIZE=$(du -sh "${KB_ROOT}" | cut -f1)
log "=== Setup complete ==="
log "  KB root:        ${KB_ROOT}"
log "  Repos cloned:   $((REPO_COUNT - ${#FAILED_CLONES[@]})) / ${REPO_COUNT}"
log "  Total issues:   ${TOTAL_ISSUES}"
log "  Size:           ${KB_SIZE}"
log ""
log "Next steps:"
log "  Search: rg 'keyword' ${KB_ROOT}"
log "  Claude: cd ${KB_ROOT} && claude"
log "  Update: ./update.sh"
