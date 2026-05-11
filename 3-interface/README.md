# Layer 3: Interface

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

## Captain Portal レベル

| Level | 状態 | 内容 |
|-------|------|------|
| Level 1 | ✓ 現状 | 分散ツール (kb_feedback_ui + CLI scripts) |
| Level 2 | ⏳ 待機 | Dify Desktop ハブ化 (dify_sync.py 未実装) |
| Level 3 | 🎯 将来 | `quard-web.jp/dashboard` 商用 portal (4-portal/ で構築) |

## 前後の層

← `2-intelligence/` (AI)  
→ `4-portal/` (Captain Portal、商用化)
