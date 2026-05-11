#!/usr/bin/env bash
# kb-stats.sh - KB size monitoring (Grok レビュー結果: 10K docs で Semantic Collapse 警告)
# Usage: ./kb-stats.sh [--json]

set -euo pipefail

KB_ROOT="${HOME}/.kb"
ISSUES_DIR="${KB_ROOT}/issues"
PRS_DIR="${KB_ROOT}/prs"
RELEASES_DIR="${KB_ROOT}/releases"

# Thresholds (Grok レビュー結果に基づく)
SAFE_THRESHOLD=5000      # 安全ゾーン上限
WARN_THRESHOLD=8000      # 警告 (re-ranker 検討開始)
CRITICAL_THRESHOLD=10000 # Stanford 論文の Semantic Collapse 境界

# Count docs
issue_count=0
pr_count=0
release_count=0

if [ -d "${ISSUES_DIR}" ]; then
    for f in "${ISSUES_DIR}"/*.json; do
        [ -f "$f" ] || continue
        c=$(jq 'length' "$f" 2>/dev/null || echo 0)
        issue_count=$((issue_count + c))
    done
fi

if [ -d "${PRS_DIR}" ]; then
    for f in "${PRS_DIR}"/*.json; do
        [ -f "$f" ] || continue
        c=$(jq 'length' "$f" 2>/dev/null || echo 0)
        pr_count=$((pr_count + c))
    done
fi

if [ -d "${RELEASES_DIR}" ]; then
    for f in "${RELEASES_DIR}"/*.json; do
        [ -f "$f" ] || continue
        c=$(jq 'length' "$f" 2>/dev/null || echo 0)
        release_count=$((release_count + c))
    done
fi

repo_count=$(ls -1 "${KB_ROOT}/repos" 2>/dev/null | wc -l)
total_docs=$((issue_count + pr_count + release_count))
kb_size=$(du -sh "${KB_ROOT}" 2>/dev/null | cut -f1)

# Determine status
if [ "${total_docs}" -lt "${SAFE_THRESHOLD}" ]; then
    status="SAFE"
    advice="Phase D ベクトル検索は最適に動作中"
elif [ "${total_docs}" -lt "${WARN_THRESHOLD}" ]; then
    status="GROWING"
    advice="re-ranker 導入を計画開始推奨 (5K 突破)"
elif [ "${total_docs}" -lt "${CRITICAL_THRESHOLD}" ]; then
    status="WARN"
    advice="re-ranker 必須 (Phase H 着手)、または KB チャンク分割検討"
else
    status="CRITICAL"
    advice="Semantic Collapse 領域 (Stanford 論文)、即 re-ranker / hybrid search 導入"
fi

if [ "${1:-}" = "--json" ]; then
    cat <<EOF
{
  "kb_root": "${KB_ROOT}",
  "kb_size": "${kb_size}",
  "repo_count": ${repo_count},
  "issues": ${issue_count},
  "prs": ${pr_count},
  "releases": ${release_count},
  "total_docs": ${total_docs},
  "status": "${status}",
  "thresholds": {"safe": ${SAFE_THRESHOLD}, "warn": ${WARN_THRESHOLD}, "critical": ${CRITICAL_THRESHOLD}},
  "advice": "${advice}"
}
EOF
else
    cat <<EOF
========================================
  KB Stats - $(date +%Y-%m-%d\ %H:%M)
========================================
  KB root:        ${KB_ROOT}
  KB size:        ${kb_size}
  Repos:          ${repo_count}

  Document counts:
    Issues:       ${issue_count}
    PRs:          ${pr_count}
    Releases:     ${release_count}
    TOTAL:        ${total_docs}

  Status: ${status}

  Thresholds (Grok レビュー: Stanford Semantic Collapse 論文):
    < ${SAFE_THRESHOLD}:    SAFE   (ベクトル検索最適)
    < ${WARN_THRESHOLD}:    GROWING (re-ranker 計画推奨)
    < ${CRITICAL_THRESHOLD}: WARN   (re-ranker 必須)
    >= ${CRITICAL_THRESHOLD}: CRITICAL (Semantic Collapse 領域)

  Advice: ${advice}
========================================
EOF
fi
