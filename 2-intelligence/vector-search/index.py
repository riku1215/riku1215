"""
Initial indexing of local KB into ChromaDB.

Reads:
- ~/.kb/issues/*.json (all 46 repos' issues)
- ~/.kb/repos/*/README.md (repo-level docs)

Embeds via Ollama (nomic-embed-text) and stores in
~/.kb/chroma_db/ (persistent).

Run once after Phase A setup.ps1 completes.
Re-run if you want a clean rebuild.
"""
import json
import glob
from pathlib import Path

import chromadb
from llama_index.core import VectorStoreIndex, Document, Settings
from llama_index.vector_stores.chroma import ChromaVectorStore
from llama_index.embeddings.ollama import OllamaEmbedding

KB_ROOT = Path.home() / ".kb"
CHROMA_PATH = KB_ROOT / "chroma_db"
COLLECTION_NAME = "riku1215_kb"

print(f"KB root: {KB_ROOT}")
print(f"ChromaDB: {CHROMA_PATH}")

# Configure embedding (LLM not needed for pure indexing)
Settings.embed_model = OllamaEmbedding(model_name="nomic-embed-text")
Settings.llm = None

# Setup ChromaDB
chroma_client = chromadb.PersistentClient(path=str(CHROMA_PATH))
collection = chroma_client.get_or_create_collection(COLLECTION_NAME)
vstore = ChromaVectorStore(chroma_collection=collection)

docs = []
issue_count = 0
readme_count = 0

# === Index all issues ===
for issue_file in glob.glob(str(KB_ROOT / "issues" / "*.json")):
    repo = Path(issue_file).stem
    try:
        with open(issue_file, encoding="utf-8") as f:
            issues = json.load(f)
    except Exception as e:
        print(f"  Skip {repo}: {e}")
        continue

    for issue in issues:
        body = issue.get("body") or ""
        title = issue.get("title") or ""
        comments = issue.get("comments") or []
        comments_text = "".join(
            f"\n\n--- comment ---\n{c.get('body', '')}" for c in comments
        )

        text = f"# [{repo}#{issue['number']}] {title}\n\n{body}{comments_text}"
        # Trim to avoid token overflow
        text = text[:12000]

        meta = {
            "repo": repo,
            "number": int(issue["number"]),
            "state": issue.get("state") or "unknown",
            "url": issue.get("url") or "",
            "title": (title or "")[:200],
            "source": "issue",
        }
        docs.append(Document(text=text, metadata=meta, doc_id=f"{repo}#{issue['number']}"))
        issue_count += 1

# === Optionally index repo READMEs ===
for readme in glob.glob(str(KB_ROOT / "repos" / "*" / "README.md")):
    repo = Path(readme).parent.name
    try:
        with open(readme, encoding="utf-8") as f:
            content = f.read()[:12000]
        docs.append(Document(
            text=f"# {repo}/README\n\n{content}",
            metadata={"repo": repo, "source": "readme", "path": "README.md"},
            doc_id=f"{repo}/README.md",
        ))
        readme_count += 1
    except Exception:
        continue

print(f"\nIndexing {len(docs)} documents ({issue_count} issues + {readme_count} READMEs)...")
print("This may take 10-30 minutes on CPU. Embedding via Ollama (nomic-embed-text).")
print("(If slow, ensure Ollama is running: 'ollama serve')\n")

# Build index (embeds all docs into ChromaDB)
index = VectorStoreIndex.from_documents(
    docs, vector_store=vstore, show_progress=True
)

final_count = collection.count()
print(f"\n✅ Indexing complete!")
print(f"   Collection: {COLLECTION_NAME}")
print(f"   Documents indexed: {final_count}")
print(f"   Storage: {CHROMA_PATH}")
print(f"\nNext: try query — python ask.py \"your question\"")
