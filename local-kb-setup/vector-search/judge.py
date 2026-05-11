"""
judge.py - Auto-evaluate retrieval quality using Gemini API

Grok Q3 (2026-05-11) 5 事例分析より:
"事例2 (sliamh21, r/ClaudeAI): judge LLM で retrieval 品質を自動学習"

ChromaDB query 結果 (top-k) を Gemini に評価依頼:
- 各結果が query にどれだけ関連しているか (0-10 score)
- "useful_for_query" / "tangentially_related" / "unrelated" 分類
- 結果を feedback.sqlite3 の auto_judge テーブルに記録
- Phase D-2 Streamlit UI が表示する base となるシグナル

これにより、Captain が 👍/👎 手動評価できない時も
裏で retrieval 品質モニタリング継続。

Usage:
    python judge.py "query string" [top_k]
    python judge.py --batch queries.txt   # 一括評価
"""
import json
import os
import sqlite3
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path

import chromadb
import requests
from llama_index.embeddings.ollama import OllamaEmbedding

KB_ROOT = Path.home() / ".kb"
CHROMA_PATH = KB_ROOT / "chroma_db"
DB_PATH = KB_ROOT / "feedback.sqlite3"
COLLECTION_NAME = "riku1215_kb"
GEMINI_MODEL = "gemini-2.5-flash"  # cost-optimal, quality enough
GEMINI_KEY = os.environ.get("GEMINI_API_KEY", "")


def ensure_judge_table():
    """Create auto_judge table in same feedback.sqlite3 (WAL safe)."""
    con = sqlite3.connect(str(DB_PATH))
    con.execute("PRAGMA journal_mode = WAL")
    con.execute("""
        CREATE TABLE IF NOT EXISTS auto_judge(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ts TEXT NOT NULL,
            run_id TEXT NOT NULL,
            query TEXT NOT NULL,
            doc_id TEXT NOT NULL,
            rank INTEGER,
            distance REAL,
            score INTEGER,
            classification TEXT,
            judge_reason TEXT,
            judge_model TEXT
        )
    """)
    con.execute("CREATE INDEX IF NOT EXISTS idx_judge_query ON auto_judge(query)")
    con.execute("CREATE INDEX IF NOT EXISTS idx_judge_score ON auto_judge(score)")
    con.commit()
    return con


def judge_with_gemini(query: str, results: list) -> list:
    """Call Gemini to evaluate each result. Returns list of (score, classification, reason)."""
    if not GEMINI_KEY:
        raise RuntimeError("GEMINI_API_KEY not set. source /tmp/gemini.env")

    # Build batched prompt (1 Gemini call evaluates all top-k)
    items_text = ""
    for i, r in enumerate(results, 1):
        excerpt = r["text"][:500].replace("\n", " ")
        items_text += f"\n[Result {i}] id={r['id']}, distance={r['distance']:.3f}\n{excerpt}\n"

    prompt = f"""Captain (個人事業主、46 GitHub repo + 1000+ Issue 単独運用) のための
ローカル KB 検索結果を評価してください。

【Query (検索クエリ)】
{query}

【Top-K Results】{items_text}

各 Result を以下の JSON 配列で評価:
[
  {{
    "rank": 1,
    "score": 0-10 (10=完全に役立つ、0=完全に無関係),
    "classification": "useful_for_query" | "tangentially_related" | "unrelated",
    "reason": "判定理由を1文で"
  }},
  ...
]

JSON のみ返答、他のテキスト不要。"""

    url = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent?key={GEMINI_KEY}"
    body = {
        "contents": [{"role": "user", "parts": [{"text": prompt}]}],
        "generationConfig": {"temperature": 0.2, "responseMimeType": "application/json"},
    }
    resp = requests.post(url, json=body, timeout=60)
    resp.raise_for_status()
    data = resp.json()

    text = data["candidates"][0]["content"]["parts"][0]["text"]
    judgments = json.loads(text)
    return judgments


def judge_query(query: str, top_k: int = 8) -> dict:
    """Search + auto-judge + persist. Returns summary."""
    embed = OllamaEmbedding(model_name="nomic-embed-text")
    q_emb = embed.get_text_embedding(query)

    chroma_client = chromadb.PersistentClient(path=str(CHROMA_PATH))
    collection = chroma_client.get_collection(COLLECTION_NAME)
    res = collection.query(query_embeddings=[q_emb], n_results=top_k)

    results = []
    for i in range(len(res["ids"][0])):
        results.append({
            "id": res["ids"][0][i],
            "text": res["documents"][0][i],
            "meta": res["metadatas"][0][i],
            "distance": res["distances"][0][i],
            "rank": i + 1,
        })

    judgments = judge_with_gemini(query, results)

    # Persist
    con = ensure_judge_table()
    run_id = str(uuid.uuid4())
    ts = datetime.now(timezone.utc).isoformat()
    for r, j in zip(results, judgments):
        con.execute("""
            INSERT INTO auto_judge
            (ts, run_id, query, doc_id, rank, distance, score, classification, judge_reason, judge_model)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            ts, run_id, query, r["id"], r["rank"], r["distance"],
            j.get("score"), j.get("classification"), j.get("reason"),
            GEMINI_MODEL,
        ))
    con.commit()
    con.close()

    # Summary
    useful = sum(1 for j in judgments if j.get("classification") == "useful_for_query")
    tangential = sum(1 for j in judgments if j.get("classification") == "tangentially_related")
    unrelated = sum(1 for j in judgments if j.get("classification") == "unrelated")
    avg_score = sum(j.get("score", 0) for j in judgments) / max(len(judgments), 1)

    return {
        "query": query,
        "top_k": top_k,
        "useful": useful,
        "tangential": tangential,
        "unrelated": unrelated,
        "avg_score": round(avg_score, 2),
        "run_id": run_id,
    }


def main():
    if len(sys.argv) < 2:
        print("Usage: python judge.py <query> [top_k]")
        print("       python judge.py --batch queries.txt")
        sys.exit(1)

    if sys.argv[1] == "--batch":
        with open(sys.argv[2], encoding="utf-8") as f:
            queries = [line.strip() for line in f if line.strip() and not line.startswith("#")]
        print(f"Batch judging {len(queries)} queries...")
        for q in queries:
            summary = judge_query(q, top_k=8)
            print(f"  '{q}' → useful={summary['useful']} avg={summary['avg_score']}")
    else:
        query = sys.argv[1]
        top_k = int(sys.argv[2]) if len(sys.argv) > 2 else 8
        summary = judge_query(query, top_k=top_k)
        print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
