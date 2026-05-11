---
tags: [tree-sitter, structural-search, intelligence, phase-2, grok-prior-art]
layer: intelligence
audience: [captain-only, claude]
status: poc
---

# 2-intelligence/structural-search — Tree-sitter 構造解析 PoC

`#tree-sitter #structural-search #blast-radius #phase-2`

> agents.yml の **structural-analyzer** + **impact-analyst** 役を駆動するエンジン。
> Grok prior-art 事例 2 (codebase-memory-mcp) + 事例 4 (Repowise) 反映。

## 役割

embedding (ChromaDB) では拾えない **共有 util 関数の被参照数 / 依存グラフ / blast radius** を抽出。
agoora researcher / structural-analyzer / impact-analyst 役のデータソース。

## ファイル

| ファイル | 役割 | 状態 |
|---------|------|------|
| `requirements.txt` | 依存パッケージ | ✓ PoC |
| `analyze.py` | 単一 repo の AST 解析 + 関数定義/呼出抽出 | ✓ PoC |
| `blast_radius.py` | 関数の被参照解析 (impact-analyst 用) | ✓ PoC |
| `graph_builder.py` | NetworkX で dependency graph 構築 | Phase 2 |
| `mcp_server.py` | MCP server (FastMCP) | Phase 2 |

## クイックスタート

```powershell
cd 2-intelligence/structural-search
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt

# 単一 repo を解析
python analyze.py "$env:USERPROFILE\.kb\repos\classweaver" --language python

# 出力例 (JSON):
# {
#   "functions": [
#     {"name": "calc_score", "file": "scoring.py", "line": 42},
#     {"name": "solve_cpsat", "file": "solver.py", "line": 88}
#   ],
#   "calls": [
#     {"from": "solver.py::solve_cpsat", "to": "scoring.py::calc_score"}
#   ]
# }

# blast radius (関数の被参照数)
python blast_radius.py --function "calc_score" --repo "$env:USERPROFILE\.kb\repos\classweaver"
```

## サポート言語

`tree-sitter-language-pack` 経由で 64 言語:
- Python ★ (Phase 2.0 PoC 第一弾)
- TypeScript / JavaScript ★ (agoora UI 自体)
- Java (pet-care-app backend)
- Astro / Vue (quard-web-jp)

## Grok prior-art 統合

| 事例 | 採用要素 |
|------|---------|
| 事例 2 codebase-memory-mcp | Tree-sitter + 64 言語、構造クエリ |
| 事例 4 Repowise | dependency graph + blast radius、PR 前必須 |

## agents.yml への接続

```yaml
structural-analyzer:
  skills:
    - tree-sitter-query    # ← 本 PoC の analyze.py
    - graph-cypher         # ← 本 PoC の graph_builder.py

impact-analyst:
  skills:
    - dep-graph-query
    - blast-radius-calc    # ← 本 PoC の blast_radius.py
```

## 関連

- [agora#4 R-rules](https://github.com/riku1215/agora/issues/4)
- 本 repo: `4-portal/agents.yml`
- 本 repo: `1-knowledge/prior-art-2026-05-11.md` Grok 5 事例
- [PROFILE.md Section 8](../../PROFILE.md) Phase 2 計画
- Grok 事例 2: https://github.com/codebase-memory-mcp (参考)
- Grok 事例 4: pip install repowise (参考)
