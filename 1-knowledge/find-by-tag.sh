#!/usr/bin/env bash
# find-by-tag.sh - ラベル / hashtag による KB 検索ヘルパー
#
# 使い方:
#   ./find-by-tag.sh sakura              # #sakura または tags: に含まれる
#   ./find-by-tag.sh sakura migration    # AND 検索 (両方含む)
#   ./find-by-tag.sh -l 1-knowledge      # layer 指定
#   ./find-by-tag.sh --frontmatter sakura # YAML frontmatter のみ検索
#   ./find-by-tag.sh --inline sakura     # 本文 #hashtag のみ
#   ./find-by-tag.sh --issues sakura     # Issues JSON labels (gh)

set -euo pipefail

KB_ROOT="${HOME}/.kb"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE="all"
LAYER_FILTER=""
TAGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --frontmatter) MODE="frontmatter"; shift;;
        --inline) MODE="inline"; shift;;
        --issues) MODE="issues"; shift;;
        -l|--layer) LAYER_FILTER="$2"; shift 2;;
        -h|--help)
            echo "Usage: $0 [--frontmatter|--inline|--issues] [-l LAYER] TAG [TAG...]"
            exit 0;;
        *) TAGS+=("$1"); shift;;
    esac
done

[ ${#TAGS[@]} -eq 0 ] && { echo "ERROR: provide at least 1 tag"; exit 1; }

# Build search roots
ROOTS=()
[ -d "${REPO_ROOT}" ] && ROOTS+=("${REPO_ROOT}")
[ -d "${KB_ROOT}" ] && ROOTS+=("${KB_ROOT}")

# Filter to specific layer
if [ -n "${LAYER_FILTER}" ]; then
    if [ -d "${REPO_ROOT}/${LAYER_FILTER}" ]; then
        ROOTS=("${REPO_ROOT}/${LAYER_FILTER}")
    fi
fi

if [ "${MODE}" = "all" ] || [ "${MODE}" = "frontmatter" ]; then
    echo "=== YAML frontmatter matches ==="
    for tag in "${TAGS[@]}"; do
        echo ""
        echo "Tag: #${tag}"
        for root in "${ROOTS[@]}"; do
            # Match: 'tags: [...includes tag...]' in first 20 lines
            rg --max-count=1 -l --no-heading -A 0 "^tags:.*\b${tag}\b" "${root}" 2>/dev/null | head -20 || true
        done
    done
fi

if [ "${MODE}" = "all" ] || [ "${MODE}" = "inline" ]; then
    echo ""
    echo "=== Inline #hashtag matches ==="
    for tag in "${TAGS[@]}"; do
        echo ""
        echo "Tag: #${tag}"
        for root in "${ROOTS[@]}"; do
            rg --color=always "#${tag}\b" "${root}" 2>/dev/null | head -10 || true
        done
    done
fi

if [ "${MODE}" = "all" ] || [ "${MODE}" = "issues" ]; then
    if [ -d "${KB_ROOT}/issues" ]; then
        echo ""
        echo "=== GitHub Issue labels (from KB) ==="
        for tag in "${TAGS[@]}"; do
            echo ""
            echo "Label: ${tag}"
            for f in "${KB_ROOT}/issues"/*.json; do
                [ -f "$f" ] || continue
                repo=$(basename "$f" .json)
                jq -r --arg t "${tag}" '.[] | select(.labels[]?.name == $t) | "  [\($t)] " + .url + " - " + .title' "$f" 2>/dev/null | head -5 || true
            done
        done
    fi
fi
