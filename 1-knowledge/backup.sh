#!/usr/bin/env bash
# Phase E: Daily Backup - Linux/macOS
# Usage:
#   ./backup.sh           # default: keep last 30 daily backups
#   ./backup.sh -k 7      # keep only last 7 days
#   ./backup.sh -o /mnt/x # custom output dir
#
# Recommended: cron daily 02:00

set -euo pipefail

KB_ROOT="${HOME}/.kb"
REPOS_DIR="${KB_ROOT}/repos"
OUTPUT_BASE="${KB_ROOT}/backups"
KEEP=30

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output) OUTPUT_BASE="$2"; shift 2;;
        -k|--keep) KEEP="$2"; shift 2;;
        -h|--help) echo "Usage: $0 [-o OUTPUT] [-k KEEP_DAYS]"; exit 0;;
        *) echo "Unknown: $1"; exit 1;;
    esac
done

[ -d "${REPOS_DIR}" ] || { echo "KB not initialized."; exit 1; }

TIMESTAMP=$(date +%Y-%m-%d)
BACKUP_DIR="${OUTPUT_BASE}/${TIMESTAMP}"

# Idempotent: skip if today's backup exists
if [ -d "${BACKUP_DIR}" ]; then
    echo "Today's backup already exists at ${BACKUP_DIR}"
    exit 0
fi

mkdir -p "${BACKUP_DIR}"
echo "Creating daily bundles in: ${BACKUP_DIR}"

TOTAL=0
SUCCESS=0
FAILED=()

for repo_dir in "${REPOS_DIR}"/*/; do
    [ -d "${repo_dir}/.git" ] || continue
    TOTAL=$((TOTAL + 1))
    name=$(basename "${repo_dir}")
    bundle_file="${BACKUP_DIR}/${name}.bundle"

    echo "  [${TOTAL}] ${name}"
    if (cd "${repo_dir}" && git bundle create "${bundle_file}" --all 2>/dev/null); then
        SUCCESS=$((SUCCESS + 1))
    else
        FAILED+=("${name}")
    fi
done

# Issue JSONs
ISSUES_DIR="${KB_ROOT}/issues"
if [ -d "${ISSUES_DIR}" ]; then
    tar czf "${BACKUP_DIR}/issues-${TIMESTAMP}.tar.gz" -C "${ISSUES_DIR}" . 2>/dev/null
fi

# Feedback DB
FEEDBACK_DB="${KB_ROOT}/feedback.sqlite3"
if [ -f "${FEEDBACK_DB}" ]; then
    cp "${FEEDBACK_DB}" "${BACKUP_DIR}/feedback.sqlite3"
fi

# Retention: delete backups older than $KEEP days
echo ""
echo "Cleaning up backups older than ${KEEP} days..."
find "${OUTPUT_BASE}" -maxdepth 1 -type d -name "????-??-??" -mtime +${KEEP} -print -exec rm -rf {} \; 2>/dev/null || true

SIZE=$(du -sh "${BACKUP_DIR}" | cut -f1)
TOTAL_SIZE=$(du -sh "${OUTPUT_BASE}" | cut -f1)
echo ""
echo "========================================"
echo "  Daily backup complete: ${TIMESTAMP}"
echo "========================================"
echo "  Total stored:    ${TOTAL_SIZE} (${KEEP} days retention)"
echo "  Location:        ${BACKUP_DIR}"
echo "  Repos bundled:   ${SUCCESS} / ${TOTAL}"
echo "  Size:            ${SIZE}"
if [ ${#FAILED[@]} -gt 0 ]; then
    echo "  Failed:          ${FAILED[*]}"
fi
echo ""
echo "Restore example (1 repo):"
echo "  git clone ${BACKUP_DIR}/<repo>.bundle restored-<repo>"
echo ""
echo "Recommended: copy ${BACKUP_DIR} to external SSD or cloud storage monthly"
