"""
rebuild.py - Atomic-swap full re-index (ChatGPT R14 サイクル 3 推奨パターン)

ChatGPT 公式制約レビュー:
ChromaDB PersistentClient は同一ローカルパス共有の concurrent writers を許容しない。
完全再 index 時は新パスに作成 → atomic rename で安全に切替えるパターンを推奨。

Layout:
    $HOME/.kb/chroma_current        ← MCP / Streamlit が読む (symlink)
    $HOME/.kb/chroma_build_<TS>     ← 新規 ingest 中 (rebuild.py が書く)
    $HOME/.kb/chroma_<TS>           ← 過去 build (rollback 可能)

Usage:
    python rebuild.py              # フル再 build (~30分 on i7-1355U)
    python rebuild.py --keep 3     # 古い build を 3 世代まで保持
"""
import argparse
import json
import os
import shutil
import time
from datetime import datetime
from pathlib import Path

import chromadb
from llama_index.core import VectorStoreIndex, Document, Settings
from llama_index.vector_stores.chroma import ChromaVectorStore
from llama_index.embeddings.ollama import OllamaEmbedding

KB_ROOT = Path.home() / ".kb"
CURRENT_LINK = KB_ROOT / "chroma_current"
COLLECTION_NAME = "riku1215_kb"


def collect_documents() -> list[Document]:
    """Re-collect all source docs (issues + READMEs)."""
    docs = []
    for issue_file in (KB_ROOT / "issues").glob("*.json"):
        repo = issue_file.stem
        try:
            issues = json.loads(issue_file.read_text(encoding="utf-8"))
        except Exception:
            continue
        for issue in issues:
            body = issue.get("body") or ""
            title = issue.get("title") or ""
            comments_text = "".join(
                f"\n\n--- comment ---\n{c.get('body', '')}" for c in (issue.get("comments") or [])
            )
            text = f"# [{repo}#{issue['number']}] {title}\n\n{body}{comments_text}"[:12000]
            docs.append(Document(
                text=text,
                doc_id=f"{repo}#{issue['number']}",
                metadata={
                    "repo": repo,
                    "number": int(issue["number"]),
                    "state": issue.get("state") or "unknown",
                    "url": issue.get("url") or "",
                    "title": (title or "")[:200],
                    "source": "issue",
                },
            ))
    return docs


def cleanup_old_builds(keep: int):
    """Keep last N chroma_<TS> builds, delete older."""
    builds = sorted(
        [p for p in KB_ROOT.iterdir() if p.is_dir() and p.name.startswith("chroma_") and p.name != "chroma_current"],
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )
    for old in builds[keep:]:
        # Don't delete currently linked one
        if CURRENT_LINK.is_symlink() and old.resolve() == CURRENT_LINK.resolve():
            continue
        print(f"  removing old build: {old.name}")
        shutil.rmtree(old, ignore_errors=True)


def atomic_swap(new_path: Path):
    """Atomically point chroma_current → new_path."""
    tmp_link = KB_ROOT / f".chroma_current.tmp.{os.getpid()}"
    if tmp_link.exists() or tmp_link.is_symlink():
        tmp_link.unlink()
    tmp_link.symlink_to(new_path)
    # os.replace is atomic on POSIX; on Windows requires removing target first
    if CURRENT_LINK.exists() or CURRENT_LINK.is_symlink():
        if os.name == "nt":
            CURRENT_LINK.unlink()
            tmp_link.rename(CURRENT_LINK)
        else:
            os.replace(tmp_link, CURRENT_LINK)
    else:
        tmp_link.rename(CURRENT_LINK)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--keep", type=int, default=2, help="Number of past builds to keep")
    args = p.parse_args()

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    build_dir = KB_ROOT / f"chroma_build_{ts}"
    final_dir = KB_ROOT / f"chroma_{ts}"

    print(f"=== Rebuild start: {ts} ===")
    print(f"Build dir:  {build_dir}")
    print(f"Final dir:  {final_dir}")
    print(f"Symlink:    {CURRENT_LINK}")

    # === Embed ===
    Settings.embed_model = OllamaEmbedding(model_name="nomic-embed-text")
    Settings.llm = None

    client = chromadb.PersistentClient(path=str(build_dir))
    collection = client.get_or_create_collection(COLLECTION_NAME)
    vstore = ChromaVectorStore(chroma_collection=collection)

    docs = collect_documents()
    print(f"\nDocuments: {len(docs)}")
    print("Embedding... (10-30 min on CPU)")

    t0 = time.time()
    _index = VectorStoreIndex.from_documents(docs, vector_store=vstore, show_progress=True)
    elapsed = time.time() - t0
    print(f"\nEmbedding done in {elapsed/60:.1f} min")

    # === Atomic swap (build_dir → final_dir → symlink) ===
    print(f"\nFinalizing: {build_dir.name} → {final_dir.name}")
    build_dir.rename(final_dir)

    print(f"Atomic swap: {CURRENT_LINK} → {final_dir.name}")
    atomic_swap(final_dir)

    print(f"\nCleanup (keep last {args.keep} builds)")
    cleanup_old_builds(args.keep)

    print(f"\n✅ Rebuild complete: {final_dir.name}")
    print(f"Collection count: {collection.count()}")
    print(f"\nReaders (MCP, Streamlit) should be restarted or wait for cache TTL.")


if __name__ == "__main__":
    main()
