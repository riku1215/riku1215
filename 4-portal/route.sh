#!/usr/bin/env bash
# route.sh - Captain Portal 階層分岐 dispatcher (Dify 代替)
#
# Usage:
#   ./route.sh "pet-care-app PR #52 の CI 失敗を直して"
#   ./route.sh --dry-run "新機能を追加したい"
#   ./route.sh --rule new-feature "..."   # 明示指定
#
# routing.yml の rules を上から評価し、match した pipeline を表示。
# 実 LLM 呼出はせず、Claude (本セッション) が手動で pipeline を実行する想定。
# Phase 2 で各 agent を実呼出する shell automation に拡張可能。
#
# tags: [captain-portal, routing, dispatcher, harness]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROUTING_YML="$SCRIPT_DIR/routing.yml"
AGENTS_YML="$SCRIPT_DIR/agents.yml"
LOG_FILE="${HOME}/.kb/routing.log"

DRY_RUN=0
FORCE_RULE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=1; shift ;;
        --rule)    FORCE_RULE="$2"; shift 2 ;;
        -h|--help)
            cat <<EOF
Usage: $0 [--dry-run] [--rule RULE_ID] "<task description>"

Examples:
  $0 "pet-care-app PR #52 の CI 失敗を直して"
  $0 --dry-run "新機能を追加したい"
  $0 --rule strategy-decision "Phase 2 で hi-spec マシン買うべき?"

Rules defined in: $ROUTING_YML
Agents defined in: $AGENTS_YML
EOF
            exit 0 ;;
        *) break ;;
    esac
done

if [[ $# -lt 1 ]]; then
    echo "Error: task description required. See $0 --help" >&2
    exit 1
fi

INPUT="$*"
INPUT_LOWER="$(echo "$INPUT" | tr '[:upper:]' '[:lower:]')"

# === 簡易 keyword matcher (YAML パーサ非依存、bash 完結) ===
match_keywords() {
    local keywords=("$@")
    for kw in "${keywords[@]}"; do
        if [[ "$INPUT_LOWER" == *"$kw"* ]] || [[ "$INPUT" == *"$kw"* ]]; then
            return 0
        fi
    done
    return 1
}

determine_rule() {
    if [[ -n "$FORCE_RULE" ]]; then
        echo "$FORCE_RULE"
        return
    fi

    # Level 0: explicit mention
    if match_keywords "@architect" "@researcher" "@coder" "@reviewer" "@critic" "@historian"; then
        echo "explicit-mention"; return
    fi

    # Level 1: urgent
    if match_keywords "緊急" "急ぎ" "今すぐ" "urgent" "asap"; then
        echo "urgent-bypass"; return
    fi

    # Level 2: task type
    if match_keywords "バグ" "bug" "fix" "不具合" "エラー" "error" "落ちる" "失敗" "直し"; then
        echo "bug-fix"; return
    fi
    if match_keywords "リファクタ" "refactor" "再構成"; then
        echo "refactor"; return
    fi
    if match_keywords "新規" "追加" "作って" "実装" "feature" "build" "create"; then
        echo "new-feature"; return
    fi
    if match_keywords "戦略" "経営" "方針" "判断" "決定" "strategy" "decide" "買うべき"; then
        echo "strategy-decision"; return
    fi
    if match_keywords "調査" "過去" "先行" "事例" "research" "prior"; then
        echo "research-investigation"; return
    fi
    if match_keywords "レビュー" "review" "確認して" "チェック"; then
        echo "review-only"; return
    fi
    if match_keywords "deploy" "デプロイ" "リリース" "release" "公開"; then
        echo "deploy"; return
    fi
    if match_keywords "knowledge" "kb" "同期" "記憶"; then
        echo "kb-sync"; return
    fi

    # Level 3: pure question
    if [[ "$INPUT" == *"?"* ]] || [[ "$INPUT" == *"？"* ]]; then
        if ! match_keywords "実装" "作って" "fix" "deploy"; then
            echo "pure-question"; return
        fi
    fi

    # Level 99: default
    echo "default"
}

get_pipeline() {
    local rule="$1"
    case "$rule" in
        explicit-mention)        echo "orchestrator → <mentioned> → orchestrator" ;;
        urgent-bypass)           echo "orchestrator → coder → orchestrator (post-review flag)" ;;
        bug-fix)                 echo "orchestrator → researcher → coder → reviewer → historian → orchestrator" ;;
        new-feature)             echo "orchestrator → researcher → architect → critic → coder → reviewer → historian → orchestrator" ;;
        refactor)                echo "orchestrator → researcher → architect → critic → coder → reviewer → historian → orchestrator" ;;
        strategy-decision)       echo "orchestrator → researcher → architect → critic → orchestrator" ;;
        research-investigation)  echo "orchestrator → researcher → orchestrator" ;;
        review-only)             echo "orchestrator → reviewer → critic → orchestrator" ;;
        deploy)                  echo "orchestrator → researcher → reviewer → coder → historian → orchestrator" ;;
        kb-sync)                 echo "orchestrator → historian → orchestrator" ;;
        pure-question)           echo "orchestrator → researcher → orchestrator" ;;
        default)                 echo "orchestrator → researcher → architect → critic → orchestrator" ;;
        *)                       echo "unknown rule: $rule" ;;
    esac
}

RULE=$(determine_rule)
PIPELINE=$(get_pipeline "$RULE")
HASH=$(echo "$INPUT" | sha256sum | cut -c1-8)
TS=$(date '+%Y-%m-%d %H:%M:%S')

echo "================================================"
echo "  Captain Portal Router"
echo "================================================"
echo "  Input    : $INPUT"
echo "  Hash     : $HASH"
echo "  Matched  : $RULE"
echo "  Pipeline : $PIPELINE"
echo "================================================"

if [[ $DRY_RUN -eq 0 ]]; then
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$TS] hash=$HASH rule=$RULE pipeline=\"$PIPELINE\" input=\"$INPUT\"" >> "$LOG_FILE"
    echo "  Logged   : $LOG_FILE"
fi

echo ""
echo "Next: Claude (orchestrator) executes the pipeline above."
echo "      Each agent's role / LLM / skills: see $AGENTS_YML"
