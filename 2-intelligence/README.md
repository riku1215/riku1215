---
tags: [intelligence, phase-d, phase-d-3, llm-review, vector-search]
layer: intelligence
audience: [captain-only, claude]
status: active
---

# Layer 2: Intelligence

`#intelligence #phase-d #phase-d-3 #llm-review`

**役割**: AI 層 — ベクトル検索、Gemini 相談、自動評価による「賢い検索」

## ファイル

| ファイル | 役割 |
|---------|------|
| `ask-gemini.sh` / `.ps1` | Gemini API 経由で独立評価・意見聴取 (R14 多LLMレビュー) |
| `post-kb-claude-instructions.md` | KB稼働後の Claude.ai 「Claudeへの指示」テンプレ |
| `vector-search/` | ChromaDB + Ollama + LlamaIndex によるベクトル検索 (Phase D) |

## vector-search/ 内訳

| ファイル | 役割 |
|---------|------|
| `index.py` | 初回 embedding (1000 issue + 46 README) |
| `update.py` | 増分更新 |
| `ask.py` | CLI 意味検索 |
| `mcp_server.py` | Claude Code 統合 MCP server |
| `judge.py` | Gemini で retrieval 品質自動評価 (Phase D-3) |
| `kbignore.py` | .kbignore パターンマッチャ |
| `feedback_schema.sql` | フィードバック DB スキーマ |
| `requirements.txt` | Python 依存 |

## 使い方

```bash
# Gemini 相談
./ask-gemini.sh "案A'' の妥当性を評価して"

# ベクトル検索
cd vector-search
pip install -r requirements.txt
python index.py            # 初回 (10-30分)
python ask.py "会員アカウント乗せ替え"
python judge.py "sakura" 8 # Gemini 自動評価
python mcp_server.py       # Claude Code 統合
```

## 前後の層

← `1-knowledge/` (データ)  
→ `3-interface/` (UI 層、Streamlit UI + Dify 統合)
