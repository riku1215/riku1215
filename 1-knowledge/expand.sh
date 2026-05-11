#!/usr/bin/env bash
# Phase F: NAS-like expansion - fetch PRs, Releases, Workflow runs, Wikis, Discussions
# Usage: ./expand.sh [--with-runs] [--with-discussions]
#
# Adds beyond setup.sh (which only fetches Issues):
# - Pull Requests (with reviews, comments, files changed metadata)
# - Releases (with assets metadata)
# - Workflow runs (recent failures, useful for "this error happened before?")
# - Discussions (if repo has them enabled)
# - Wiki content (if repo has Wiki)
# - Repository topics, languages, settings

set -euo pipefail

KB_ROOT="${HOME}/.kb"
PRS_DIR="${KB_ROOT}/prs"
RELEASES_DIR="${KB_ROOT}/releases"
RUNS_DIR="${KB_ROOT}/workflow-runs"
DISCUSSIONS_DIR="${KB_ROOT}/discussions"
META_DIR="${KB_ROOT}/repo-meta"
LOG_FILE="${KB_ROOT}/expand.log"

WITH_RUNS=0
WITH_DISCUSSIONS=0
for arg in "$@"; do
    case "$arg" in
        --with-runs) WITH_RUNS=1;;
        --with-discussions) WITH_DISCUSSIONS=1;;
    esac
done

mkdir -p "${PRS_DIR}" "${RELEASES_DIR}" "${META_DIR}"
[ "${WITH_RUNS}" = "1" ] && mkdir -p "${RUNS_DIR}"
[ "${WITH_DISCUSSIONS}" = "1" ] && mkdir -p "${DISCUSSIONS_DIR}"

[ ! -f "${KB_ROOT}/repos.json" ] && { echo "Run setup.sh first."; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "gh not authenticated"; exit 1; }

log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "${LOG_FILE}"; }

REPO_COUNT=$(jq 'length' "${KB_ROOT}/repos.json")
log "=== Phase F expansion: ${REPO_COUNT} repos ==="

i=0
while IFS= read -r name; do
    i=$((i + 1))
    log "  [${i}/${REPO_COUNT}] ${name}"

    # === Pull Requests ===
    gh pr list -R "riku1215/${name}" --state all --limit 9999 \
        --json number,title,body,state,createdAt,closedAt,updatedAt,mergedAt,author,assignees,labels,reviews,comments,reviewRequests,changedFiles,additions,deletions,baseRefName,headRefName,url,isDraft,mergeable \
        > "${PRS_DIR}/${name}.json" 2>/dev/null || echo "[]" > "${PRS_DIR}/${name}.json"

    # === Releases ===
    gh release list -R "riku1215/${name}" --limit 100 \
        --json name,tagName,createdAt,publishedAt,isDraft,isPrerelease,isLatest,url \
        > "${RELEASES_DIR}/${name}.json" 2>/dev/null || echo "[]" > "${RELEASES_DIR}/${name}.json"

    # === Repo metadata ===
    gh repo view "riku1215/${name}" \
        --json name,description,topics,languages,defaultBranchRef,createdAt,pushedAt,homepageUrl,visibility,isArchived,isFork,licenseInfo,diskUsage,stargazerCount,forkCount,openIssues,owner \
        > "${META_DIR}/${name}.json" 2>/dev/null || echo "{}" > "${META_DIR}/${name}.json"

    # === Workflow runs (optional, heavy) ===
    if [ "${WITH_RUNS}" = "1" ]; then
        gh run list -R "riku1215/${name}" --limit 50 \
            --json databaseId,name,displayTitle,event,status,conclusion,workflowName,headBranch,createdAt,updatedAt,url \
            > "${RUNS_DIR}/${name}.json" 2>/dev/null || echo "[]" > "${RUNS_DIR}/${name}.json"
    fi

    # === Discussions (optional, GraphQL) ===
    if [ "${WITH_DISCUSSIONS}" = "1" ]; then
        gh api graphql -f query="{
            repository(owner: \"riku1215\", name: \"${name}\") {
                discussions(first: 50) {
                    nodes { number title body createdAt updatedAt url category { name } author { login } }
                }
            }
        }" 2>/dev/null > "${DISCUSSIONS_DIR}/${name}.json" || echo "{}" > "${DISCUSSIONS_DIR}/${name}.json"
    fi
done < <(jq -r '.[].name' "${KB_ROOT}/repos.json")

# === Summary ===
log "=== Phase F expansion done ==="
TOTAL_PRS=0
for f in "${PRS_DIR}"/*.json; do
    c=$(jq 'length' "$f" 2>/dev/null || echo 0)
    TOTAL_PRS=$((TOTAL_PRS + c))
done
TOTAL_RELEASES=0
for f in "${RELEASES_DIR}"/*.json; do
    c=$(jq 'length' "$f" 2>/dev/null || echo 0)
    TOTAL_RELEASES=$((TOTAL_RELEASES + c))
done

log "  Total PRs collected:      ${TOTAL_PRS}"
log "  Total releases collected: ${TOTAL_RELEASES}"
KB_SIZE=$(du -sh "${KB_ROOT}" | cut -f1)
log "  KB size now:              ${KB_SIZE}"
log ""
log "Next:"
log "  Search PRs:    rg 'keyword' ${PRS_DIR}/"
log "  Re-index Phase D: cd vector-search && python index.py  (will pick up new dirs)"
