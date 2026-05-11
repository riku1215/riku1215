"""
MCP server exposing local KB vector search to Claude Code.

Run:
    python mcp_server.py

Claude Code config (~/.claude/mcp.json or equivalent):
    {
      "mcpServers": {
        "kb-search": {
          "command": "python",
          "args": [
            "C:\\Users\\m\\riku1215\\local-kb-setup\\vector-search\\mcp_server.py"
          ]
        }
      }
    }

Then in Claude Code, use the tool:
    search_kb("会員アカウント乗せ替え", top_k=8)
"""
import json
from pathlib import Path

import chromadb
from llama_index.embeddings.ollama import OllamaEmbedding
from fastmcp import FastMCP

KB_ROOT = Path.home() / ".kb"
CHROMA_PATH = KB_ROOT / "chroma_db"
COLLECTION_NAME = "riku1215_kb"

embed = OllamaEmbedding(model_name="nomic-embed-text")
chroma_client = chromadb.PersistentClient(path=str(CHROMA_PATH))
collection = chroma_client.get_collection(COLLECTION_NAME)

mcp = FastMCP("Local KB Vector Search")


@mcp.tool()
def search_kb(query: str, top_k: int = 8) -> str:
    """
    Search the local GitHub knowledge base (riku1215/* repos + 1000+ issues)
    using semantic vector similarity (nomic-embed-text).

    Returns top-k matching items as JSON with metadata and excerpts.

    Use this BEFORE making proposals to:
    1. Surface related past discussions you might miss
    2. Check for prior decisions that conflict with your plan
    3. Find context for sakura, deploy, R-rules, etc.

    Complements ripgrep (which only does exact text match).
    """
    q_emb = embed.get_text_embedding(query)
    results = collection.query(query_embeddings=[q_emb], n_results=top_k)

    items = []
    for doc_id, meta, doc, dist in zip(
        results["ids"][0],
        results["metadatas"][0],
        results["documents"][0],
        results["distances"][0],
    ):
        items.append({
            "id": doc_id,
            "similarity": round(1.0 - dist, 3),
            "repo": meta.get("repo", ""),
            "title": meta.get("title", ""),
            "url": meta.get("url", ""),
            "state": meta.get("state", ""),
            "excerpt": doc.replace("\n", " ").strip()[:500],
        })

    return json.dumps(items, ensure_ascii=False, indent=2)


@mcp.tool()
def kb_stats() -> str:
    """Return statistics about the local KB."""
    count = collection.count()
    # Optionally compute per-repo breakdown
    all_meta = collection.get(include=["metadatas"])["metadatas"]
    repo_counts = {}
    for m in all_meta:
        r = m.get("repo", "unknown")
        repo_counts[r] = repo_counts.get(r, 0) + 1
    top10 = sorted(repo_counts.items(), key=lambda x: -x[1])[:10]
    return json.dumps({
        "total_documents": count,
        "top_10_repos_by_doc_count": top10,
    }, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    mcp.run()
