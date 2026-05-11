#!/usr/bin/env bash
# update.sh - Incremental sync of local KB
# Run daily (e.g., via cron 09:00) to keep KB current.

set -euo pipefail

KB_ROOT="${HOME}/.kb"
REPOS_DIR="${KB_ROOT}/repos"
ISSUES_DIR="${KB_ROOT}/issues"
LOG_FILE="${KB_ROOT}/update.log"

[ -d "${REPOS_DIR}" ] || { echo "KB not initialized. Run setup.sh first."; exit 1; }
[ -d "${ISSUES_DIR}" ] || { echo "KB not initialized. Run setup.sh first."; exit 1; }

gh auth status >/dev/null 2>&1 || { echo "ERROR: gh not authenticated"; exit 1; }

log() { echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $*" | tee -a "${LOG_FILE}"; }

START_EPOCH=$(date +%s)
log "Update started"

# Re-fetch repo list (catch new repos)
gh repo list riku1215 --json name,visibility,defaultBranchRef,updatedAt,description --limit 100 > "${KB_ROOT}/repos.json"

NEW_REPOS=0
UPDATED_REPOS=0
FAILED_REPOS=0
UPDATED_ISSUES=0

while IFS= read -r name; do
    target="${REPOS_DIR}/${name}"

    if [ ! -d "${target}/.git" ]; then
        log "[NEW] cloning ${name}"
        if gh repo clone "riku1215/${name}" "${target}" -- --depth=100 --quiet 2>>"${LOG_FILE}"; then
            NEW_REPOS=$((NEW_REPOS + 1))
        else
            FAILED_REPOS=$((FAILED_REPOS + 1))
        fi
    else
        (
            cd "${target}"
            git fetch --all --quiet 2>>"${LOG_FILE}" || exit 1
            default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||' || echo "")
            if [ -n "${default_branch}" ]; then
                before=$(git rev-parse HEAD 2>/dev/null || echo "")
                git checkout "${default_branch}" --quiet 2>/dev/null || true
                git pull origin "${default_branch}" --rebase --quiet 2>>"${LOG_FILE}" || true
                after=$(git rev-parse HEAD 2>/dev/null || echo "")
                if [ "${before}" != "${after}" ]; then
                    log "[UPDATED] ${name} (${before:0:7} -> ${after:0:7})"
                fi
            fi
        ) && {
            after_check=$(cd "${target}" && git rev-parse HEAD 2>/dev/null || echo "")
            UPDATED_REPOS=$((UPDATED_REPOS + 1))
        } || FAILED_REPOS=$((FAILED_REPOS + 1))
    fi

    # Update issues
    OLD_HASH=""
    if [ -f "${ISSUES_DIR}/${name}.json" ]; then
        OLD_HASH=$(sha256sum "${ISSUES_DIR}/${name}.json" | cut -d' ' -f1)
    fi
    if gh issue list -R "riku1215/${name}" --state all --limit 9999 \
        --json number,title,body,labels,comments,state,createdAt,closedAt,updatedAt,author,assignees,url \
        > "${ISSUES_DIR}/${name}.json" 2>>"${LOG_FILE}"; then
        NEW_HASH=$(sha256sum "${ISSUES_DIR}/${name}.json" | cut -d' ' -f1)
        if [ "${OLD_HASH}" != "${NEW_HASH}" ]; then
            UPDATED_ISSUES=$((UPDATED_ISSUES + 1))
        fi
    else
        echo "[]" > "${ISSUES_DIR}/${name}.json"
    fi
done < <(jq -r '.[].name' "${KB_ROOT}/repos.json")

ELAPSED=$(($(date +%s) - START_EPOCH))
log "Update complete: new=${NEW_REPOS} updated=${UPDATED_REPOS} failed=${FAILED_REPOS} issues=${UPDATED_ISSUES} elapsed=${ELAPSED}s"
