---
tags: [interface, phase-d-2, streamlit, dify, captain-portal]
layer: interface
audience: [captain-only, claude, customer-demo]
status: active
---

# Layer 3: Interface

`#interface #phase-d-2 #streamlit #dify`

**役割**: UI 層 — Captain と KB / AI の対話インターフェース

## 含まれるもの

| ファイル | 役割 |
|---------|------|
| `kb_feedback_ui.py` | Streamlit Web UI for KB search + フィードバック (Phase D-2、Codex 推奨設計) |
| (未実装) `dify_sync.py` | Dify Desktop 統合 (Captain Portal Level 2、Q-A 待ち) |

## 使い方

```bash
# Streamlit UI 起動
cd 3-interface
streamlit run kb_feedback_ui.py
# → http://localhost:8501
```

## UX 摩擦回避 (Gemini Q1 レビュー反映)

**重要**: Streamlit Web UI は **main UX ではない**。
1000 docs 規模ローカル RAG が「2週間で使わなくなる」最大要因は UX 摩擦
(立ち上げ遅い、UI もっさり、直接貼った方が早い)。

→ **Main UX = Claude Code 内 MCP server 呼出** (ゼロクリック起動)  
→ Streamlit UI = **分析専用** (フィードバック確認・統計、09:00 一括)

詳細: `1-knowledge/risks-and-mitigations.md` R4 セクション

## Captain Portal レベル

| Level | 状態 | 内容 |
|-------|------|------|
| Level 1 | ✓ 現状 | 分散ツール (kb_feedback_ui + CLI scripts) |
| Level 2 | ⏳ 待機 | Dify Desktop ハブ化 (dify_sync.py 未実装) |
| Level 3 | 🎯 将来 | `quard-web.jp/dashboard` 商用 portal (4-portal/ で構築) |

## 前後の層

← `2-intelligence/` (AI)  
→ `4-portal/` (Captain Portal、商用化)
