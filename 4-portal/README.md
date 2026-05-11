---
tags: [portal, captain-portal, quard-web, customer-demo, planned]
layer: portal
audience: [captain-only, customer-demo, public]
status: draft
---

# Layer 4: Portal (Captain Portal Level 3)

`#portal #captain-portal #quard-web #customer-demo`

**役割**: 統合ポータル層 — `quard-web.jp/dashboard` 等の Captain 中央 hub

## 状態

**未実装** — Level 2 (Dify Desktop ハブ化) 完了後に着手予定。

## 想定構成 (将来)

| パス | 内容 |
|------|------|
| `dashboard/` | Astro / Next.js 静的サイト雛形、quard-web.jp/dashboard 用 |
| `api/` | 公開 API (Captain 個人 → 顧客 demo 移行用) |
| `deploy/` | sakura VPS / Vercel deploy 設定 |

## 設計方針

- **入口**: Captain が一日の作業を始める時に開く第一画面
- **検索**: 過去 Issue/PR/コードを横断検索 (KB データソース)
- **ダッシュボード**: kb-stats / 月額ランニング / 進行タスク #4-#11
- **AI ハブ**: Dify ワークフロー / ask-gemini / Claude Code 起動
- **顧客 demo 化**: QUARD ブランド SaaS の前段階

## 前後の層

← `3-interface/` (Streamlit UI、Dify)  
→ `5-product/` (商用 SaaS 化)
