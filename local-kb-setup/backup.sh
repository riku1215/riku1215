#!/usr/bin/env bash
# Phase E: Monthly Backup - Linux/macOS
# Usage: ./backup.sh [output_dir]
# Creates git-bundle of all repos for offline backup.

set -euo pipefail

KB_ROOT="${HOME}/.kb"
REPOS_DIR="${KB_ROOT}/repos"
OUTPUT_BASE="${1:-${KB_ROOT}/backups}"

[ -d "${REPOS_DIR}" ] || { echo "KB not initialized."; exit 1; }

TIMESTAMP=$(date +%Y-%m-%d)
BACKUP_DIR="${OUTPUT_BASE}/${TIMESTAMP}"
mkdir -p "${BACKUP_DIR}"

echo "Creating bundles in: ${BACKUP_DIR}"

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

# Archive issue JSONs
ISSUES_DIR="${KB_ROOT}/issues"
if [ -d "${ISSUES_DIR}" ]; then
    tar czf "${BACKUP_DIR}/issues-${TIMESTAMP}.tar.gz" -C "${ISSUES_DIR}" .
    echo "Issues archived: ${BACKUP_DIR}/issues-${TIMESTAMP}.tar.gz"
fi

SIZE=$(du -sh "${BACKUP_DIR}" | cut -f1)
echo ""
echo "========================================"
echo "  Backup complete: ${TIMESTAMP}"
echo "========================================"
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
