"""
Incremental update: detect changed issues and re-embed only those.

Strategy:
- Compare each issue's `updatedAt` to last seen in metadata
- If new or changed, delete old embedding and re-add

Run daily after Phase A update.ps1, or schedule separately.
"""
import json
import glob
from pathlib import Path

import chromadb
from llama_index.core import Settings
from llama_index.embeddings.ollama import OllamaEmbedding

KB_ROOT = Path.home() / ".kb"
CHROMA_PATH = KB_ROOT / "chroma_db"
COLLECTION_NAME = "riku1215_kb"

Settings.embed_model = OllamaEmbedding(model_name="nomic-embed-text")
embed = Settings.embed_model

chroma_client = chromadb.PersistentClient(path=str(CHROMA_PATH))
collection = chroma_client.get_or_create_collection(COLLECTION_NAME)

# Build map of existing doc_id -> updatedAt
existing = collection.get(include=["metadatas"])
existing_meta = dict(zip(existing["ids"], existing["metadatas"]))

new_count = 0
updated_count = 0
unchanged_count = 0

for issue_file in glob.glob(str(KB_ROOT / "issues" / "*.json")):
    repo = Path(issue_file).stem
    try:
        with open(issue_file, encoding="utf-8") as f:
            issues = json.load(f)
    except Exception:
        continue

    for issue in issues:
        doc_id = f"{repo}#{issue['number']}"
        new_updated = issue.get("updatedAt") or ""

        # Decide: skip / update / new
        if doc_id in existing_meta:
            old_updated = existing_meta[doc_id].get("updatedAt") or ""
            if old_updated == new_updated:
                unchanged_count += 1
                continue
            collection.delete(ids=[doc_id])
            updated_count += 1
        else:
            new_count += 1

        # Rebuild text + embed
        body = issue.get("body") or ""
        title = issue.get("title") or ""
        comments = issue.get("comments") or []
        comments_text = "".join(
            f"\n\n--- comment ---\n{c.get('body', '')}" for c in comments
        )
        text = f"# [{repo}#{issue['number']}] {title}\n\n{body}{comments_text}"[:12000]

        meta = {
            "repo": repo,
            "number": int(issue["number"]),
            "state": issue.get("state") or "unknown",
            "url": issue.get("url") or "",
            "title": (title or "")[:200],
            "source": "issue",
            "updatedAt": new_updated,
        }

        emb_vec = embed.get_text_embedding(text)
        collection.add(
            ids=[doc_id],
            embeddings=[emb_vec],
            metadatas=[meta],
            documents=[text],
        )

print(f"\n✅ Incremental update complete:")
print(f"   New:       {new_count}")
print(f"   Updated:   {updated_count}")
print(f"   Unchanged: {unchanged_count}")
print(f"   Total:     {collection.count()} embeddings")
