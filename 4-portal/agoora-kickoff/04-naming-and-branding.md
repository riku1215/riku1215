# コメント 4/6 — 命名検討 (agoora 採用経緯)

> 2026-05-11 夜の決定経緯。Captain × Claude × ドメイン取得可能性の協議結果。

## 候補リスト (★ 推奨度付き)

| # | 名前 | 由来 | 反論 | ★ |
|---|------|------|------|----|
| 1 | **agoora.jp** (Captain 案) | agora 拡張、覚えやすい | 既存 riku1215/agora repo と spelling 混同 | ★★★★ |
| 2 | agora.quard-web.jp | 既存 agora ブランド継承 + QUARD 統合 | agora.jp 単独取得 difficult | ★★★★★ |
| 3 | helm.quard-web.jp | 「舵」= Captain 隠喩 | やや抽象的 | ★★★★ |
| 4 | nexus.quard-web.jp | 結節点、46 repo の交差点 | "Nexus" は商品名で氾濫 | ★★★ |
| 5 | everett.dev | Many-Worlds 提唱者 Hugh Everett | 物理学知らないと意味不明 | ★★ |
| 6 | repolens.jp | repo を読む眼鏡 | 機能寄り、ブランド弱い | ★★★ |
| 7 | multiverse.quard-web.jp | Many-Worlds 完全実装 | ハイテク響き、SEO 弱い | ★★ |
| 8 | captain.quard-web.jp | Captain Portal そのまま | 一般化困難 | ★★ |

## Captain 決定打 (2026-05-11 夜)

> **agora はライバル多し / agoora は空いている**

→ ドメイン取得可能性が決定打。**`agoora`** 採用確定。

## Dual-track 戦略 (Captain 提案)

> agora.quard-web.jp → デモ版

| URL | 役割 | Phase |
|-----|------|-------|
| `agoora.jp` | **SaaS 本サイト** (個人 → 法人版、Kuuki Design 模倣) | 5 |
| `agora.quard-web.jp` | **公開デモ** (集客導線、QUARD 既存ブランド傘下、25 番目 product として登録) | 5 |
| `github.com/riku1215/agoora` | **OSS repo** (本リポ、Phase 3 で public 化検討) | 2-3 |
| `%USERPROFILE%\Portal\99-portal-ui\index.html` | **Captain ローカル本体** | 1 (現在) |

## ブランディング

- **プロダクト名**: agoora (内部コード名 Captain Portal は残置)
- **タグライン**: 個人開発者の知識の集まる場
- **ロゴ**: 六角形 + 内側コア (ナレッジハブ + α、`⬡` モチーフ)
- **カラー**: GitHub Primer 互換 (`#2f81f7` blue + `#a371f7` purple)

## 商標 / ドメイン状況 (2026-05-11 時点)

| ドメイン | 状況 |
|---------|------|
| agoora.jp | 空き ★ Phase 5 取得予定 |
| agoora.com | 要確認 |
| agoora.dev | 要確認 (技術者向け派生) |
| agora.quard-web.jp | sub-domain なので自由 |

## quard-web.jp 既存 24 products との位置付け

quard-web.jp の `src/pages/products/` 配下 24 個:
agora / ai-financial-office / ai-marketplace / ai-native-management / ai-tool-catalog / book-studio / classweaver / doc-studio / dsi-factory / dsi-kit-library / dsi-wizard / kintaeru / kuod-hp / masaru-suto-www / mindgate / paw-sensor / pet-care-app / prompt-notes / quard-community / quard-ui / shiftweaver / sourcecode-judge-saas / video-autopilot

→ **agoora を 25 番目 product として追加** (Phase 5):
`https://quard-web.jp/products/agoora/` (公式 product page)
`https://agora.quard-web.jp` (専用 sub-domain でデモ起動)

`#r14 #naming #branding #agoora #dual-track`
