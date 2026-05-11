"""Captain Portal API — FastAPI ChromaDB bridge + 静的 UI 配信

Usage:
    python portal-api.py
    python portal-api.py --port 8765 --host 127.0.0.1

エンドポイント:
    GET  /                      静的 UI (index.html)
    GET  /indexes/<name>.json   インデックス JSON (build-indexes.ps1 生成物)
    GET  /search?q=...&role=...&k=10  ChromaDB セマンティック検索
    GET  /search/keyword?q=...  ripgrep ライク全文検索
    GET  /healthz               ヘルスチェック

設計方針:
- ChromaDB が無くても静的 UI + JSON 配信は動作 (graceful degradation)
- ChromaDB あれば /search で意味検索利用可
- agent_profiles.yaml の role 別 retrieval policy 適用 (ChatGPT C1)
- 全レスポンス UTF-8、CORS 許可 (localhost のみ)

tags: [captain-portal, api, fastapi, chromadb, harness]
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
from pathlib import Path
from typing import Any

try:
    from fastapi import FastAPI, HTTPException, Query
    from fastapi.middleware.cors import CORSMiddleware
    from fastapi.responses import FileResponse, JSONResponse
    from fastapi.staticfiles import StaticFiles
except ImportError:
    raise SystemExit("Install: pip install fastapi uvicorn[standard]")

try:
    import yaml
except ImportError:
    yaml = None  # agent_profiles.yaml 読込不可、default policy 使用

try:
    import chromadb
except ImportError:
    chromadb = None  # 意味検索無効、静的 UI のみ

PORTAL_ROOT = Path(os.environ.get("PORTAL_ROOT", Path.home() / "Portal"))
KB_ROOT = Path(os.environ.get("KB_ROOT", Path.home() / ".kb"))
UI_DIR = Path(__file__).parent / "ui-template"
INDEX_DIR = PORTAL_ROOT / "indexes"
PROFILES_PATH = Path.home() / ".kb" / "config" / "agent_profiles.yaml"

app = FastAPI(title="Captain Portal API", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost", "http://127.0.0.1", "http://localhost:8765"],
    allow_methods=["GET"],
    allow_headers=["*"],
)


def load_profiles() -> dict[str, Any]:
    if yaml is None or not PROFILES_PATH.exists():
        return {}
    try:
        with open(PROFILES_PATH, encoding="utf-8") as f:
            return yaml.safe_load(f) or {}
    except Exception:
        return {}


def get_chroma_collection():
    if chromadb is None:
        return None
    current_path_file = KB_ROOT / "current_path.txt"
    if not current_path_file.exists():
        return None
    try:
        chroma_path = Path(current_path_file.read_text(encoding="utf-8").strip())
        if not chroma_path.exists():
            return None
        client = chromadb.PersistentClient(path=str(chroma_path))
        # collection 名は rebuild.py 既定の "kb_chunks" を仮定
        return client.get_collection("kb_chunks")
    except Exception:
        return None


@app.get("/healthz")
def healthz() -> dict[str, Any]:
    return {
        "ok": True,
        "portal_root": str(PORTAL_ROOT),
        "kb_root": str(KB_ROOT),
        "chromadb_available": chromadb is not None,
        "chroma_collection": get_chroma_collection() is not None,
        "profiles_available": yaml is not None and PROFILES_PATH.exists(),
        "indexes": sorted(p.name for p in INDEX_DIR.glob("*.json")) if INDEX_DIR.exists() else [],
    }


@app.get("/indexes/{name}.json")
def get_index(name: str) -> JSONResponse:
    if not name.isalnum() and not all(c.isalnum() or c == "-" or c == "_" for c in name):
        raise HTTPException(400, "invalid index name")
    path = INDEX_DIR / f"{name}.json"
    if not path.exists():
        raise HTTPException(404, f"index '{name}' not built. Run build-indexes.ps1 first.")
    return JSONResponse(content=json.loads(path.read_text(encoding="utf-8")))


@app.get("/search")
def search_semantic(
    q: str = Query(..., min_length=1),
    role: str = Query("default"),
    k: int | None = None,
) -> dict[str, Any]:
    """ChromaDB セマンティック検索 (role 別 retrieval policy 適用)."""
    coll = get_chroma_collection()
    if coll is None:
        raise HTTPException(503, "ChromaDB unavailable. Run rebuild.py first or install chromadb.")

    profiles = load_profiles()
    policy = profiles.get(role, profiles.get("default", {}))
    top_k = k or policy.get("top_k", 8)
    collections = policy.get("collections", ["all"])
    output_schema = policy.get("output_schema", ["summary", "citations"])

    try:
        results = coll.query(query_texts=[q], n_results=top_k)
    except Exception as e:
        raise HTTPException(500, f"chroma query failed: {e}")

    hits = []
    docs = results.get("documents", [[]])[0]
    metas = results.get("metadatas", [[]])[0]
    dists = results.get("distances", [[]])[0]
    ids = results.get("ids", [[]])[0]
    for i, (doc, meta, dist, _id) in enumerate(zip(docs, metas, dists, ids)):
        hits.append({
            "rank": i + 1,
            "id": _id,
            "score": 1.0 - dist,  # similarity
            "text": doc[:600],
            "source": meta.get("source", "") if meta else "",
            "chunk_hash": meta.get("chunk_hash", "") if meta else "",
        })
    return {
        "query": q,
        "role": role,
        "policy": {"top_k": top_k, "collections": collections, "output_schema": output_schema},
        "hits": hits,
        "total": len(hits),
    }


@app.get("/search/keyword")
def search_keyword(q: str = Query(..., min_length=1), limit: int = 50) -> dict[str, Any]:
    """ripgrep ライク全文検索 (~/.kb/ 配下)."""
    if not KB_ROOT.exists():
        raise HTTPException(404, "KB root not initialized")
    try:
        rg_path = "rg"
        out = subprocess.run(
            [rg_path, "--json", "-i", "--max-count", str(limit), q, str(KB_ROOT / "repos")],
            capture_output=True, text=True, timeout=10, encoding="utf-8", errors="replace",
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return {"query": q, "hits": [], "error": "ripgrep unavailable or timeout"}

    hits = []
    for line in out.stdout.splitlines():
        try:
            ev = json.loads(line)
            if ev.get("type") == "match":
                data = ev.get("data", {})
                hits.append({
                    "path": data.get("path", {}).get("text", ""),
                    "line": data.get("line_number"),
                    "text": data.get("lines", {}).get("text", "")[:300],
                })
        except Exception:
            continue
        if len(hits) >= limit:
            break
    return {"query": q, "hits": hits, "total": len(hits)}


@app.get("/")
def serve_index() -> FileResponse:
    idx = UI_DIR / "index.html"
    if not idx.exists():
        raise HTTPException(404, "UI not deployed. Run portal-init.ps1 first.")
    return FileResponse(idx, media_type="text/html; charset=utf-8")


# UI assets (style.css / search.js)
if UI_DIR.exists():
    app.mount("/ui", StaticFiles(directory=str(UI_DIR)), name="ui")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    try:
        import uvicorn
    except ImportError:
        raise SystemExit("Install: pip install uvicorn[standard]")
    print(f"Captain Portal API: http://{args.host}:{args.port}")
    print(f"  UI:       http://{args.host}:{args.port}/")
    print(f"  Health:   http://{args.host}:{args.port}/healthz")
    print(f"  Semantic: http://{args.host}:{args.port}/search?q=test&role=architect")
    uvicorn.run(app, host=args.host, port=args.port, log_level="info")


if __name__ == "__main__":
    main()
