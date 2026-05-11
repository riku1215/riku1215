"""
CLI vector search.

Usage:
    python ask.py "your natural language question"
    python ask.py "会員アカウント乗せ替え"
    python ask.py "sakura billing issue" 10
"""
import sys
from pathlib import Path

import chromadb
from llama_index.embeddings.ollama import OllamaEmbedding

KB_ROOT = Path.home() / ".kb"
CHROMA_PATH = KB_ROOT / "chroma_db"
COLLECTION_NAME = "riku1215_kb"

if len(sys.argv) < 2:
    print("Usage: python ask.py <query> [top_k]")
    sys.exit(1)

query = sys.argv[1]
top_k = int(sys.argv[2]) if len(sys.argv) > 2 else 8

embed = OllamaEmbedding(model_name="nomic-embed-text")
q_emb = embed.get_text_embedding(query)

chroma_client = chromadb.PersistentClient(path=str(CHROMA_PATH))
collection = chroma_client.get_collection(COLLECTION_NAME)

results = collection.query(query_embeddings=[q_emb], n_results=top_k)

ids = results["ids"][0]
metas = results["metadatas"][0]
docs = results["documents"][0]
dists = results["distances"][0]

print(f"\n=== Top {top_k} results for: {query!r} ===\n")
for i, (doc_id, meta, doc, dist) in enumerate(zip(ids, metas, docs, dists)):
    similarity = 1.0 - dist
    print(f"[{i+1}] {doc_id}  (similarity: {similarity:.3f})")
    title = meta.get("title", "")
    if title:
        print(f"    title: {title}")
    url = meta.get("url", "")
    if url:
        print(f"    url:   {url}")
    state = meta.get("state", "")
    if state and state != "unknown":
        print(f"    state: {state}")
    excerpt = doc.replace("\n", " ").strip()[:250]
    print(f"    {excerpt}...")
    print()
