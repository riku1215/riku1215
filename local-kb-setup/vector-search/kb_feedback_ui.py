"""
Phase D-2: KB Search Feedback Web UI (Streamlit)

Based on ChatGPT/Codex review of Gemini's Phase D enhancement suggestion #3.

Stack:
- Streamlit (UI) — Python-only, 30min setup
- SQLite WAL (feedback storage, NOT Chroma metadata)
- ChromaDB read-only (search backend, shared with MCP server)
- nomic-embed-text via Ollama (same embedding as index.py)

Run:
    streamlit run kb_feedback_ui.py

Concurrency model (Codex 推奨):
- Chroma is READ-ONLY here and in MCP server
- Only ingest script (index.py / update.py) writes to Chroma
- Feedback DB is separate SQLite, WAL mode for safe concurrent UI access
"""
import os
import sqlite3
import uuid
import json
from datetime import datetime, timezone
from pathlib import Path

import streamlit as st
import chromadb
from llama_index.embeddings.ollama import OllamaEmbedding

# === Config ===
KB_ROOT = Path.home() / ".kb"
CHROMA_PATH = KB_ROOT / "chroma_db"
DB_PATH = KB_ROOT / "feedback.sqlite3"
COLLECTION_NAME = "riku1215_kb"
EMBEDDING_MODEL = "nomic-embed-text"
RETRIEVER_VERSION = "phase_d_v1"


# === DB helpers ===
def db_connect():
    """Open SQLite with WAL mode."""
    con = sqlite3.connect(str(DB_PATH))
    con.execute("PRAGMA journal_mode = WAL")
    con.execute("PRAGMA synchronous = NORMAL")
    con.execute("""
        CREATE TABLE IF NOT EXISTS feedback(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ts TEXT NOT NULL,
            run_id TEXT NOT NULL,
            query TEXT NOT NULL,
            doc_id TEXT NOT NULL,
            chunk_hash TEXT,
            rank INTEGER,
            distance REAL,
            label INTEGER NOT NULL,
            reason TEXT,
            retriever_version TEXT,
            embedding_model TEXT
        )
    """)
    con.execute("CREATE INDEX IF NOT EXISTS idx_feedback_query ON feedback(query)")
    con.execute("CREATE INDEX IF NOT EXISTS idx_feedback_doc ON feedback(doc_id)")
    return con


def save_feedback(item, label, reason=""):
    con = db_connect()
    con.execute("""
        INSERT INTO feedback
        (ts, run_id, query, doc_id, rank, distance, label, reason, retriever_version, embedding_model)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        datetime.now(timezone.utc).isoformat(),
        st.session_state.run_id,
        st.session_state.query,
        item["id"],
        item["rank"],
        item["distance"],
        label,
        reason,
        RETRIEVER_VERSION,
        EMBEDDING_MODEL,
    ))
    con.commit()
    con.close()


def get_feedback_stats():
    con = db_connect()
    cur = con.execute("""
        SELECT label, COUNT(*) FROM feedback GROUP BY label
    """)
    counts = dict(cur.fetchall())
    con.close()
    return {"useful": counts.get(1, 0), "not_useful": counts.get(0, 0)}


def export_pairs_jsonl(output_path: Path):
    """Export pairwise positive/negative pairs for re-ranker training (Codex 推奨)."""
    con = db_connect()
    cur = con.execute("""
        SELECT p.query, p.doc_id AS pos, n.doc_id AS neg, p.ts, p.embedding_model
        FROM feedback p
        JOIN feedback n
          ON p.query = n.query AND p.run_id = n.run_id
         AND p.label = 1 AND n.label = 0
         AND p.doc_id <> n.doc_id
    """)
    rows = cur.fetchall()
    con.close()
    with open(output_path, "w", encoding="utf-8") as f:
        for query, pos, neg, ts, emb_model in rows:
            f.write(json.dumps({
                "query": query,
                "positive_doc": pos,
                "negative_doc": neg,
                "source": "explicit_feedback",
                "embedding_model": emb_model,
                "ts": ts,
            }, ensure_ascii=False) + "\n")
    return len(rows)


# === Chroma read-only ===
@st.cache_resource
def get_collection():
    client = chromadb.PersistentClient(path=str(CHROMA_PATH))
    return client.get_collection(COLLECTION_NAME)


@st.cache_resource
def get_embedder():
    return OllamaEmbedding(model_name=EMBEDDING_MODEL)


# === UI ===
st.set_page_config(page_title="KB Search Feedback", layout="wide")
st.title("📚 KB Search Feedback (Phase D-2)")
st.caption(f"Chroma: `{CHROMA_PATH}` (read-only) / Feedback: `{DB_PATH}` (WAL)")

# Session state init
st.session_state.setdefault("run_id", str(uuid.uuid4()))
st.session_state.setdefault("query", "")
st.session_state.setdefault("results", [])

# Sidebar stats
with st.sidebar:
    st.header("📊 Stats")
    try:
        stats = get_feedback_stats()
        st.metric("Useful labels", stats["useful"])
        st.metric("Not useful labels", stats["not_useful"])
    except Exception as e:
        st.warning(f"DB not initialized: {e}")

    st.divider()
    st.header("📤 Export")
    if st.button("Export pairs → JSONL"):
        out = DB_PATH.parent / f"pairs_{datetime.now().strftime('%Y%m%d_%H%M')}.jsonl"
        n = export_pairs_jsonl(out)
        st.success(f"Exported {n} pairs → {out.name}")

# Main search UI
col1, col2 = st.columns([4, 1])
with col1:
    query = st.text_input("検索クエリ (日本語 OK)", value=st.session_state.query,
                          placeholder="例: sakura 会員間移行")
with col2:
    top_k = st.number_input("Top K", min_value=3, max_value=20, value=8)

if st.button("🔍 Search", type="primary") and query:
    st.session_state.query = query
    st.session_state.run_id = str(uuid.uuid4())
    try:
        emb = get_embedder()
        q_vec = emb.get_text_embedding(query)
        coll = get_collection()
        res = coll.query(query_embeddings=[q_vec], n_results=int(top_k))
        st.session_state.results = [
            {
                "id": res["ids"][0][i],
                "text": res["documents"][0][i],
                "meta": res["metadatas"][0][i],
                "distance": res["distances"][0][i],
                "rank": i + 1,
            }
            for i in range(len(res["ids"][0]))
        ]
    except Exception as e:
        st.error(f"Search failed: {e}")
        st.session_state.results = []

# Results
for item in st.session_state.get("results", []):
    similarity = 1.0 - item["distance"]
    meta = item.get("meta", {})
    title = meta.get("title", "")
    url = meta.get("url", "")
    repo = meta.get("repo", "")

    with st.container(border=True):
        cols = st.columns([8, 2])
        with cols[0]:
            st.markdown(f"### #{item['rank']} [{item['id']}]({url})")
            if title:
                st.caption(f"📌 {title}")
            st.write(item["text"][:1500])
        with cols[1]:
            st.metric("Similarity", f"{similarity:.3f}")
            if repo:
                st.caption(f"📦 {repo}")

        c1, c2 = st.columns(2)
        if c1.button("👍 役立った", key=f"up_{item['id']}_{item['rank']}"):
            save_feedback(item, 1)
            st.success(f"#{item['rank']} → useful saved")
        if c2.button("👎 役立たない", key=f"down_{item['id']}_{item['rank']}"):
            save_feedback(item, 0)
            st.warning(f"#{item['rank']} → not useful saved")

if not st.session_state.get("results") and st.session_state.query:
    st.info("検索結果なし。クエリを変えて再試行を。")
