#!/usr/bin/env bash
# ask_gemini.sh - Quick consultation with Gemini for decision support
#
# Usage:
#   ./ask_gemini.sh "your question or decision context"
#   ./ask_gemini.sh -m gemini-2.5-flash "lighter query"
#   echo "long question" | ./ask_gemini.sh -
#
# Trigger pattern (per PROFILE.md Section 7-10):
#   1. 進め方で迷ったとき (path ambiguity)
#   2. 複数の選択肢があるとき (multi-option decision)
#   3. 客観的な意見が欲しいとき (need objective opinion)

set -euo pipefail

MODEL="gemini-2.5-pro"

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--model) MODEL="$2"; shift 2;;
        -h|--help)
            echo "Usage: $0 [-m MODEL] <question>"
            echo "       echo 'question' | $0 -"
            echo "Default model: gemini-2.5-pro"
            echo "Available: gemini-2.5-pro, gemini-2.5-flash, gemini-2.5-flash-lite"
            exit 0;;
        -) QUESTION=$(cat); shift;;
        *) QUESTION="${QUESTION:-}$1 "; shift;;
    esac
done

QUESTION=$(echo "${QUESTION:-}" | sed 's/[[:space:]]*$//')
if [ -z "${QUESTION}" ]; then
    echo "ERROR: No question provided" >&2
    exit 1
fi

# Load API key
if [ -f /tmp/gemini.env ]; then
    source /tmp/gemini.env
fi
if [ -z "${GEMINI_API_KEY:-}" ]; then
    echo "ERROR: GEMINI_API_KEY not set" >&2
    echo "Set: export GEMINI_API_KEY=AIza..." >&2
    exit 1
fi

# System prompt for objective consultation
SYSTEM='あなたは Captain (個人事業主、AI戦略コンサル兼AI駆動アプリ開発者、46 GitHub repo + 1000+ Issue 単独運用) の意思決定を助ける独立コンサルタントです。

回答原則:
- 結論を先頭 200 字以内で明示
- ★ 推奨度 (5段階) または 確信度 (%) を付与
- 反論余地・代替案を明示 (R8)
- Codex 形式併用可: ① 判断 / ② trade-off / ③ 懸念
- Captain 提示案に追従しない (独立判断を出す)
- 不明点は逆質問

評価対象は Claude の提案 / Captain の判断 / 業務上の選択肢など多岐。'

# Build JSON payload safely
PAYLOAD=$(python3 -c "
import json, sys
print(json.dumps({
    'systemInstruction': {'parts': [{'text': '''$SYSTEM'''}]},
    'contents': [{'role': 'user', 'parts': [{'text': '''$QUESTION'''}]}],
    'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 4096,
    }
}, ensure_ascii=False))
")

# Call Gemini
RESPONSE=$(curl -sS --max-time 60 \
    -X POST "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}" \
    -H 'Content-Type: application/json' \
    -d "${PAYLOAD}")

# Extract text
echo "${RESPONSE}" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'error' in data:
        print('ERROR:', data['error'].get('message'), file=sys.stderr)
        sys.exit(1)
    cand = data.get('candidates', [{}])[0]
    parts = cand.get('content', {}).get('parts', [])
    for p in parts:
        print(p.get('text', ''))
    usage = data.get('usageMetadata', {})
    print(f'\n---', file=sys.stderr)
    print(f'Model: ${MODEL}', file=sys.stderr)
    print(f'Tokens: prompt={usage.get(\"promptTokenCount\")}, output={usage.get(\"candidatesTokenCount\")}', file=sys.stderr)
except Exception as e:
    print('Parse error:', e, file=sys.stderr)
    print('Raw:', sys.stdin.read()[:500], file=sys.stderr)
"
