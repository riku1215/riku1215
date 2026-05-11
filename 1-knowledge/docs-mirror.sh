#!/usr/bin/env bash
# Phase F+: External documentation mirror for Captain's stack
# Usage: ./docs-mirror.sh [--full]
#
# Mirrors official docs of frequently-referenced tools to ~/.kb/external-docs/
# Useful when GitHub is down OR for offline reference.

set -euo pipefail

KB_ROOT="${HOME}/.kb"
DOCS_DIR="${KB_ROOT}/external-docs"
LOG_FILE="${KB_ROOT}/docs-mirror.log"

FULL=0
[ "${1:-}" = "--full" ] && FULL=1

mkdir -p "${DOCS_DIR}"

log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "${LOG_FILE}"; }

# === Mirror configuration ===
# Format: name|repo|paths (space-separated docs paths within repo)
MIRRORS=(
    "anthropic-skills|anthropics/skills|."
    "vercel-skills|vercel-labs/skills|."
    "vercel-agent-skills|vercel-labs/agent-skills|."
    "claude-code-docs|anthropics/claude-code|docs/"
    "mcp-spec|modelcontextprotocol/specification|docs/"
    "fastmcp|jlowin/fastmcp|docs/"
    "ollama-docs|ollama/ollama|docs/"
    "chromadb-docs|chroma-core/chroma|docs/"
    "llama-index-docs|run-llama/llama_index|docs/"
)

if [ "${FULL}" = "1" ]; then
    MIRRORS+=(
        "astro-docs|withastro/astro|.docs/"
        "nextjs-docs|vercel/next.js|docs/"
        "docker-docs|docker/docs|content/"
        "vercel-docs|vercel/vercel|.docs/"
        "github-docs|github/docs|content/"
    )
fi

i=0
TOTAL=${#MIRRORS[@]}
log "=== docs-mirror: ${TOTAL} repos (FULL=${FULL}) ==="

for entry in "${MIRRORS[@]}"; do
    i=$((i + 1))
    name="${entry%%|*}"
    rest="${entry#*|}"
    repo="${rest%%|*}"
    paths="${rest#*|}"

    target="${DOCS_DIR}/${name}"
    log "  [${i}/${TOTAL}] ${name} (${repo})"

    if [ -d "${target}/.git" ]; then
        # Already cloned, just pull
        (cd "${target}" && git pull --quiet 2>/dev/null) || log "    pull failed"
    else
        # Sparse-checkout only docs paths (efficient)
        if ! gh repo clone "${repo}" "${target}" -- --depth=1 --filter=tree:0 --sparse --quiet 2>/dev/null; then
            log "    clone failed: ${repo}"
            continue
        fi
        # Set sparse-checkout paths
        if [ "${paths}" != "." ]; then
            (cd "${target}" && git sparse-checkout set ${paths} 2>/dev/null) || true
        fi
    fi
done

# === Mirror Anthropic / Vercel docs websites (non-git, fallback) ===
# Skip: would need wget recursive, large traffic. Captain can add as needed.

DOCS_SIZE=$(du -sh "${DOCS_DIR}" | cut -f1)
log "=== docs-mirror done: ${DOCS_SIZE} ==="

echo ""
echo "External docs mirrored at: ${DOCS_DIR}"
echo "Search example: rg 'MCP server' ${DOCS_DIR}/mcp-spec/"
