# コメント 5/6 — UI 進化 (Many-Worlds → GitHub IA 完全模倣)

> 2026-05-11 のセッション内で UI コンセプトが 4 段階で進化した経緯。

## Phase 0: 初期構想 — Many-Worlds メタファー

Captain 発言:
> 「観測が宇宙を創る」ではなく「観測は無数の可能性から一つを選び・分岐する」。
> どこまでもアリの巣のように、無数の分岐、階層で視覚的に直観的に理解できる UI。

参考: NotebookLM 物理学解説 (Many-Worlds Interpretation、Hugh Everett)

→ **コンセプト保持**: 「全分岐保存、選択ではなく分岐」を実装思想として継続。
→ **実装方法は別**: PHP 自動生成ページ案 → 静的 HTML + Cytoscape graph に変更 (反論 R1)

## Phase 1: PHP 案 → 静的 md / HTML 案へ転換

私 (Claude) の反論 6 件 (R8):

| # | 反論 | 強度 |
|---|------|------|
| R1 | PHP は LAMP 必須、LLM 解析難 → 静的 HTML + md | ★★★★★ |
| R2 | 全分岐保存は Semantic Collapse リスク (10K docs 境界) | ★★★★ |
| R3 | Captain 一人で全枝管理は cognitive overload | ★★★★ |
| R4 | Many-Worlds メタファーは美しいが実装指針が曖昧 | ★★★ |
| R5 | GitHub Issue との二重ソース問題 | ★★★ |
| R6 | 「無数分岐」と「視覚的直観性」は両立しない (Mindmap 系限界) | ★★ |

→ Captain 回答:
- Q1 何でもよい (.php 不要採用)
- Q2 具体例見せて → Obsidian Graph View / Cytoscape.js の URL 提示
- Q3 quard-web.jp の階層に準拠
- Q4 historian トリガは明示語 (「ナレッジ化して」「記録しておいて」等)

## Phase 2: quard-web.jp 階層準拠検討

`search_code` 経由で `riku1215/quard-web-jp` を解析 (private repo、Astro 製、47 component + 27 page 確認):

```
src/pages/
├── index.astro
├── overview/
├── products/         ← 24 product
│   ├── agora / ai-financial-office / ai-marketplace / ...
│   ├── classweaver / pet-care-app / mindgate / ...
└── thanks/
src/components/      ← 17 reusable components
├── Hero / Mission / Industries / Services / ServiceDetails
├── Products / Plans / Process / Roadmap / Trust / Quotes
├── FAQ / Resources / Careers / Contact / Footer / Nav
```

→ **agoora 設計反映**:
- agoora を 25 番目 product として登録予定
- Astro stack を参考にした (但し Phase 1 では Astro 不採用、static HTML で軽量化)

## Phase 3: pet-care-app UI 参考 → GitHub IA 完全模倣

Captain 発言:
> https://github.com/riku1215/pet-care-app
> フレームワーク? UI はこちらの方がすっきりしていて、色目とかいいね!

調査結果 (search_code):
- **Java/Spring Boot + React** (private repo description)
- frontend は React 採用
- CSS framework 不明 (tailwind.config / globals.css ヒットせず)
- private なので色目直接取得不可

Captain 最終発言:
> GitHub のシステムをパクッて! その方がマニュアル不要で利用できる。出来る限りまねる!

→ **GitHub IA 完全模倣に方針転換**:

### 模倣項目 (実装済 ✓)

| GitHub 要素 | agoora 実装 |
|-------------|-----------|
| Global header (logo + owner/repo + Private + search + `/` key) | ✓ |
| Repo nav tabs (Code / Issues / Pull requests / Actions / 等) | ✓ |
| Octicons (16x16 SVG icons) | ✓ |
| Counter badge (`Issues 33` 風) | ✓ |
| Issue row (icon + title + #番号 + label + meta) | ✓ |
| Issue detail (state badge + title + sidebar) | ✓ |
| Code tab (file tree + viewer) | ✓ |
| PR list (gear icon + state) | ✓ |
| Actions tab (実行コマンド一覧) | ✓ |
| Insights tab (Cytoscape graph) | ✓ |
| キーボードショートカット (`/`, `g i`, `g p` 等) | ✓ |
| Primer Dark palette (`#0d1117`, `#2f81f7` 等) | ✓ |
| Markdown 描画 (marked.js CDN) | ✓ |
| Sidebar (Labels / Repo / Actions) | ✓ |
| Hash routing SPA (`#/code` `#/issues/42` 等) | ✓ |

### コミット履歴 (UI 進化)

| commit | 内容 |
|--------|------|
| `bf72cda` | 初期統合検索ポータル (タブ式) |
| `37a401c` | GitHub Dark theme palette 適用 |
| `5436332` | **GitHub IA 完全再現** (hash routing + Octicons + sidebar) |
| `90a0f47` | agoora リブランド + 移行プラン |

## 結論

Many-Worlds メタファーは保持 (Cytoscape force graph で表現)、UI/IA は GitHub に完全準拠。
**結果: 「使い方を教える必要がない」+ 「全分岐保存」両立**。

`#r14 #ui-evolution #github-ia #many-worlds #cytoscape`
