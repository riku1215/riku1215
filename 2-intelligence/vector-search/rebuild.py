"""
rebuild.py - Full re-index with current_path.txt swap (ChatGPT R14 サイクル 4)

ChatGPT 公式制約レビュー (Windows 配慮版):
ChromaDB PersistentClient は同一ローカルパス共有の concurrent writers を許容しない。
Windows ではディレクトリ rename がプロセス保持中に失敗するため、symlink ではなく
current_path.txt 方式で safe に切替える。

Layout:
    $HOME/.kb/current_path.txt      ← 現在の chroma path を記述
    $HOME/.kb/chroma_build_<TS>     ← 新規 ingest 中 (rebuild.py が書く)
    $HOME/.kb/chroma_<TS>           ← 完成 build
    Readers (MCP / Streamlit) は current_path.txt を起動時 or TTL 切れ時に再読込

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
CURRENT_PATH_FILE = KB_ROOT / "current_path.txt"
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


def get_current_path() -> Path | None:
    """Read current chroma path from current_path.txt."""
    if CURRENT_PATH_FILE.exists():
        path_str = CURRENT_PATH_FILE.read_text(encoding="utf-8").strip()
        if path_str:
            return Path(path_str)
    return None


def cleanup_old_builds(keep: int):
    """Keep last N chroma_<TS> builds, delete older. Never delete current."""
    current = get_current_path()
    builds = sorted(
        [p for p in KB_ROOT.iterdir()
         if p.is_dir() and p.name.startswith("chroma_") and not p.name.startswith("chroma_build_")],
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )
    for old in builds[keep:]:
        if current and old.resolve() == current.resolve():
            continue
        print(f"  removing old build: {old.name}")
        shutil.rmtree(old, ignore_errors=True)


def atomic_write_current_path(new_path: Path):
    """Atomically update current_path.txt (Windows-safe via temp file + rename)."""
    tmp = KB_ROOT / f".current_path.tmp.{os.getpid()}"
    tmp.write_text(str(new_path), encoding="utf-8")
    # os.replace is atomic on both POSIX and Windows for regular files
    os.replace(tmp, CURRENT_PATH_FILE)


def main():
    """Transactional rebuild (Gemini サイクル 5 推奨 #2).

    On any failure: clean up build_dir, do NOT update current_path.txt,
    previous build remains active (rollback by default).
    """
    p = argparse.ArgumentParser()
    p.add_argument("--keep", type=int, default=2, help="Number of past builds to keep")
    args = p.parse_args()

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    build_dir = KB_ROOT / f"chroma_build_{ts}"
    final_dir = KB_ROOT / f"chroma_{ts}"
    log_file = KB_ROOT / "rebuild.log"

    def log(msg, level="INFO"):
        ts_log = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        line = f"[{ts_log}] [{level}] {msg}"
        print(line)
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(line + "\n")

    log(f"=== Rebuild start: {ts} ===")
    log(f"Build dir:  {build_dir}")
    log(f"Final dir:  {final_dir}")
    log(f"Current path file: {CURRENT_PATH_FILE}")

    # === Transactional rebuild ===
    try:
        # Embed
        Settings.embed_model = OllamaEmbedding(model_name="nomic-embed-text")
        Settings.llm = None

        client = chromadb.PersistentClient(path=str(build_dir))
        collection = client.get_or_create_collection(COLLECTION_NAME)
        vstore = ChromaVectorStore(chroma_collection=collection)

        docs = collect_documents()
        log(f"Documents collected: {len(docs)}")
        if len(docs) == 0:
            raise RuntimeError("No documents found. Run setup.ps1/.sh first.")

        log("Embedding... (10-30 min on CPU)")
        t0 = time.time()
        _index = VectorStoreIndex.from_documents(docs, vector_store=vstore, show_progress=True)
        elapsed = time.time() - t0
        log(f"Embedding done in {elapsed/60:.1f} min, docs={collection.count()}")

        # Finalize (only on success)
        log(f"Finalizing: {build_dir.name} -> {final_dir.name}")
        build_dir.rename(final_dir)

        log(f"Updating current_path.txt -> {final_dir.name}")
        atomic_write_current_path(final_dir)

        log(f"Cleanup (keep last {args.keep} builds)")
        cleanup_old_builds(args.keep)

        log(f"=== Rebuild complete: {final_dir.name} ===")
        log(f"Collection count: {collection.count()}")

        print(f"\n✅ Rebuild succeeded: {final_dir.name}")
        print(f"\nReaders (MCP, Streamlit) should:")
        print(f"  - Streamlit: click 'Clear Chroma cache' button, or wait 1 hour for TTL")
        print(f"  - MCP server: restart process to re-read current_path.txt")
        return 0

    except KeyboardInterrupt:
        log("Interrupted by user, cleaning up build_dir", "WARN")
        if build_dir.exists():
            shutil.rmtree(build_dir, ignore_errors=True)
        return 130

    except Exception as e:
        log(f"REBUILD FAILED: {e}", "ERROR")
        log(f"Previous build remains active (rollback by default)")
        # Clean up partial build_dir
        if build_dir.exists():
            log(f"Cleaning up incomplete build_dir: {build_dir.name}")
            shutil.rmtree(build_dir, ignore_errors=True)
        # final_dir might exist if rename succeeded but current_path update failed
        if final_dir.exists() and CURRENT_PATH_FILE.exists():
            current = CURRENT_PATH_FILE.read_text(encoding="utf-8").strip()
            if current != str(final_dir):
                log(f"Cleaning up unused final_dir: {final_dir.name}")
                shutil.rmtree(final_dir, ignore_errors=True)
        print(f"\n❌ Rebuild failed: {e}")
        print(f"   Check log: {log_file}")
        print(f"   Previous build (current_path.txt) remains untouched.")
        return 1


if __name__ == "__main__":
    import sys
    sys.exit(main() or 0)
