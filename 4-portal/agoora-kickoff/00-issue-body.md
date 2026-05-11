# agoora — 起点 Issue (Vision + 要件定義 + Phase 0.0 開発開始)

> **agoora** = 個人開発者の知識の集まる場 (Captain's knowledge hub)

本 Issue は agoora の **vision + 要件定義 + システム構成 + Phase 0.0 開発開始宣言**。
riku1215/agora R-rules ([agora#4](https://github.com/riku1215/agora/issues/4)) に厳格準拠して開発を進める。

---

## 1. Vision (目指す姿)

### 1-line vision
> **個人開発者が 46+ repo + 1000+ Issue を 1 人で運用するための知識の集積点。LLM × Knowledge × Skills のハーネス設計で、Kuuki Design 18-agent ハイスペック組織の理想に低スペックで迫る。**

### 解決する課題

| 課題 | 現状 | agoora 後 |
|------|------|----------|
| **見落とし → 手戻り** | 過去 Issue/PR 探索に時間、矛盾提案発生 | 1 検索バーで瞬時にベストマッチ |
| **コンテキスト圧縮損失** | セッション跨ぎで毎回 60% 余計説明 | claude-mem + ~/.kb/ で永続記憶 |
| **役割定義の曖昧さ** | 1 つの LLM が全部やる → ハルシネ多発 | 7 役 × 専用プロンプト × retrieval policy |
| **オープンソースの集積** | repo 散在、横断検索難 | 単一 UI で横断 (GitHub IA 完全再現) |
| **商用化の道筋** | プロト止まり | Phase 5 で agoora.jp SaaS 化 |

### 3 つの North Star Metrics

1. **手戻り削減**: 同じ過ち再発率 ≤ 5% (現状 ~30%)
2. **トークン効率**: 1 セッション平均 LLM コスト ≤ ¥100
3. **検索速度**: 過去議論ヒット率 ≥ 70% / 検索 → 結果 1 秒以内

---

## 2. 要件定義

### 2-1. 機能要件 (Functional Requirements)

#### F1. 統合検索
- F1.1 ファイル名 / タイトル / ハッシュタグの fuzzy 全文検索
- F1.2 ChromaDB 経由の意味検索 (role 別 retrieval policy)
- F1.3 visibility フィルタ (public / local-only / captain-only)
- F1.4 GitHub IA 完全再現 (Code / Issues / Pulls / Actions / Knowledge / Skills / Rules / Insights)

#### F2. ハーネス (Agent Orchestration)
- F2.1 7 役 agent 定義 (architect / researcher / coder / reviewer / critic / historian / orchestrator)
- F2.2 階層分岐 routing (12+ ルール decision tree、Dify 代替)
- F2.3 role 別 retrieval policy (top_k / collections / output schema)
- F2.4 R14 多 LLM レビュー強制 (critic は別 LLM、echo chamber 防止)

#### F3. Knowledge
- F3.1 46 repo + 1000+ Issue のローカルミラー (`~/.kb/`)
- F3.2 daily 自動同期 + git-bundle backup (30 日 retention)
- F3.3 GitHub Issue を **agent 間共有メモリ**として運用 (Issue-as-shared-memory)
- F3.4 ハッシュタグ + YAML frontmatter ハイブリッドラベル

#### F4. Skills
- F4.1 47 公式/コミュニティ Skill 統合 (find-skills 互換)
- F4.2 役割ごとに skill を限定 (3-5 個/役、cognitive load 削減)

#### F5. Rules
- F5.1 [agora#4](https://github.com/riku1215/agora/issues/4) R1-R71 + Section 7 失敗パターンを 1 検索で参照
- F5.2 提案前に **R9 Pre-action Checklist** 自動通過
- F5.3 提案後に **R10 Batched Authorization** 形式で Captain 提示

#### F6. Safety (LLM 防波堤)
- F6.1 LLM 出力 shell コマンドは既定 dry-run
- F6.2 `--execute` 明示時のみ実行
- F6.3 破壊操作 (rm -rf / push --force / DELETE) は二重承認

#### F7. UI / UX
- F7.1 GitHub と同じ操作感 (マニュアル不要)
- F7.2 Hash routing SPA、キーボードショートカット (`/`, `g i` 等)
- F7.3 Cytoscape force graph (Many-Worlds メタファー、全枝保存)
- F7.4 dark theme (GitHub Primer 互換)

### 2-2. 非機能要件 (Non-Functional Requirements)

| ID | 項目 | 目標 |
|----|------|------|
| N1 | **ハード** | dynabook i7-1355U / Iris Xe / 32GB / ~zero GPU で完全動作 |
| N2 | **依存** | Python 3.11+ / PowerShell 5+ / git / gh CLI のみ (Docker optional) |
| N3 | **起動速度** | UI 表示 ≤ 3 秒、検索結果 ≤ 1 秒 |
| N4 | **月額コスト** | ¥0 (ローカル) / クラウド LLM 込みで ≤ ¥3,000 |
| N5 | **ライセンス** | MIT (Phase 3 で OSS 化) |
| N6 | **言語** | UI 日本語、コード英語コメント、ドキュメント混在 |
| N7 | **OS** | Windows 11 primary、Linux/macOS secondary |
| N8 | **データ局所性** | 全データローカル、外部送信は明示的 API 経由のみ |

### 2-3. R-rules 準拠要件 (agora#4)

| Rule | 適用 | 強制 |
|------|------|------|
| **R1** 番号付け | 提案リスト全て | orchestrator output_format |
| **R3** トークン量 | 200 字結論先頭 | output_format |
| **R5** user 負担 | 質問 ≤ 2/turn | route 制約 |
| **R7** 制約即時開示 | 私できない事項 | system prompt |
| **R8** 反論余地 | 提案全て | critic agent 必須 |
| **R9** Pre-action Checklist | 実装前 | orchestrator gate |
| **R10** Batched Authorization | Captain 提示 | output_format |
| **R14** 多 LLM レビュー | 設計判断 | critic 別 LLM |
| **R71** Plan-first mode | 大規模変更 | architect 必須 |

---

## 3. システム構成 (Architecture)

### 3-1. レイヤー全景

```
┌─────────────────────────────────────────────────────────┐
│ [Layer 7: Product (Phase 5)]                            │
│   agoora.jp (SaaS) / agora.quard-web.jp (Demo)          │
├─────────────────────────────────────────────────────────┤
│ [Layer 6: UI]                                            │
│   ui-template/ (static HTML + Cytoscape + marked.js)    │
│   portal-api.py (FastAPI bridge、port 8765)             │
├─────────────────────────────────────────────────────────┤
│ [Layer 5: Harness]                                      │
│   agents.yml (7 役)                                      │
│   routing.yml (12 ルール decision tree)                  │
│   agent_profiles.yaml (role 別 retrieval policy)        │
│   route.sh / route.ps1 (dispatcher)                     │
│   protocol.md (R9 → fan-out → cross-review → R10)       │
├─────────────────────────────────────────────────────────┤
│ [Layer 4: Intelligence]                                  │
│   ChromaDB + nomic-embed-text (Phase D)                 │
│   judge.py (retrieval 品質自動評価)                       │
│   Tree-sitter (Phase 2 計画、構造解析)                    │
├─────────────────────────────────────────────────────────┤
│ [Layer 3: Knowledge]                                    │
│   ~/.kb/repos/   (46 repo クローン)                      │
│   ~/.kb/issues/  (1000+ Issue JSON)                     │
│   ~/.kb/prs/     (PR、Phase F)                          │
│   ~/.kb/external-docs/ (mirror、Phase F)                │
├─────────────────────────────────────────────────────────┤
│ [Layer 2: Skills]                                        │
│   ~/.agents/skills/ (47 公式 + コミュニティ)              │
│   find-skills (Vercel、discover/install)                │
├─────────────────────────────────────────────────────────┤
│ [Layer 1: Rules]                                        │
│   PROFILE.md Section 5-9 (R-rules + Section 7)          │
│   agora#4 (1000+ Issue 蓄積、source of truth)            │
├─────────────────────────────────────────────────────────┤
│ [Layer 0: Foundation]                                   │
│   doctor.ps1 (環境チェック)                              │
│   ask-gemini.sh/.ps1 (Gemini API wrapper)               │
│   git-bundle backup + Task Scheduler                    │
└─────────────────────────────────────────────────────────┘
```

### 3-2. データフロー

```
[Captain 入力]
   ↓
[orchestrator (Claude)] — R9 Pre-action Checklist
   ↓
[route.sh] — routing.yml で pipeline 決定
   ↓
[fan-out 並列実行]
   ├─→ researcher (Gemini)  → ~/.kb/ 検索 + 過去議論
   ├─→ architect (Claude)   → 設計 (R8 反論余地)
   ├─→ critic (Grok)        → 反論 (別 LLM 強制)
   ├─→ coder (Claude)       → 実装 (TDD)
   ├─→ reviewer (ChatGPT)   → severity 判定
   └─→ historian (Claude)   → ~/.kb/ + claude-mem 記録
   ↓
[orchestrator] 統合 → R10 Batched Authorization
   ↓
[Captain 承認 + 実行 (Safety Breakwater 経由)]
   ↓
[Result → Issue (Issue-as-shared-memory)]
```

### 3-3. リポジトリ構成 (本 agoora repo)

```
agoora/
├── 0-foundation/        ← doctor.ps1 / ask-gemini
├── 1-knowledge/         ← Phase A-G + prior-art-*.md
├── 2-intelligence/      ← ChromaDB + judge / Tree-sitter (Phase 2)
├── 3-interface/         ← Streamlit feedback / kb_feedback_ui
├── 4-portal/            ← agents.yml / routing.yml / agent_profiles.yaml
│   ├── ui-template/     ← static HTML UI
│   ├── portal-api.py
│   ├── build-indexes.ps1
│   ├── portal-init.ps1
│   ├── route.sh / route.ps1
│   └── agoora-kickoff/  ← 本 Issue 投稿用素材
├── 5-product/           ← Phase 5 SaaS 化準備
└── README.md
```

---

## 4. Phase 0.0 開発開始宣言 (agora#4 準拠)

> riku1215/riku1215 内の作業は **prototype / R&D**。本 `riku1215/agoora` で **Phase 0.0 から本格開発開始**。

### Phase 0.0 = 基盤確認 (今ここ)

- [x] repo 作成 (riku1215/agoora、private)
- [x] 初期 commit (PR #19 から 13 ファイル移管、agoora-kickoff/ 込み)
- [ ] **本 Issue 投稿** (vision + 要件 + 構成)
- [ ] R-rules ([agora#4](https://github.com/riku1215/agora/issues/4)) を CLAUDE.md / PROFILE.md import で固定
- [ ] CI/CD 雛形 (GitHub Actions、初期は lint のみ)
- [ ] ライセンス選定保留 (MIT 候補、Phase 3 で確定)

### Phase 0.1 = R-rules 完全統合

- [ ] agora#4 から R1-R71 を取得、本 repo `3-rules/` に index
- [ ] R9 Pre-action Checklist テンプレ配置
- [ ] R10 Batched Authorization テンプレ配置
- [ ] Section 7 失敗パターン本リポへ転記

### Phase 0.2 = 動作確認 (Captain 実機)

- [ ] portal-api.py 起動成功 (http://127.0.0.1:8765/)
- [ ] build-indexes.ps1 で 6 JSON 生成成功
- [ ] UI で全タブ表示確認 (Code / Issues / Pulls / Actions / Knowledge / Skills / Rules / Insights)
- [ ] route.ps1 で 5 サンプル分岐成功
- [ ] スクショ送付 → 微調整

### Phase 1.0 = 1 Issue 起点自動リレー

- [ ] GitHub Actions × Claude API で `auto-relay` label トリガ実装
- [ ] researcher → architect → coder → reviewer 自動チェイン
- [ ] 結果を同 Issue にコメント、PR 自動生成

### Phase 2.0 以降 (中長期)

- [ ] Tree-sitter 構造解析 PoC (Grok 事例 2,4 反映)
- [ ] impact-analyst agent 追加 (blast radius)
- [ ] feedback.sqlite3 に role カラム + pairwise export
- [ ] re-ranker (BM25 + cross-encoder、5K docs 接近時)

### Phase 5 = 商用化

- [ ] agoora.jp ドメイン取得
- [ ] agora.quard-web.jp デモ deploy (Astro)
- [ ] OSS 化 (MIT、本 repo public)
- [ ] 18-agent 拡張 (Kuuki Design 模倣)

---

## 5. R-rules 運用 (agora#4)

本 repo の全 Issue / PR / commit / コメントは agora#4 の R-rules に従う:

1. **セッション開始時**: agora#4 fetch → context に焼く (CLAUDE.md import 必須)
2. **提案前**: R9 Pre-action Checklist 通過 (R1/R3/R5/R7/R8)
3. **複数案**: ★ 推奨度 + trade-off 表 + 反論余地 (R8)
4. **実装後**: R14 多 LLM cross-review (Grok / Gemini / ChatGPT)
5. **長セッション (30 msg 超)**: agora#4 再 fetch + 直近 5 msg 自己監査

---

## 6. 関連 (riku1215 内)

| Repo / Issue | 関係 |
|--------------|------|
| [riku1215/riku1215 PR #19](https://github.com/riku1215/riku1215/pull/19) | prototype 実装 (~4,500 行)、本リポへ移管済 |
| [riku1215/riku1215 #18](https://github.com/riku1215/riku1215/issues/18) | Phase 1 戦略総括 (本リポの直接の親) |
| [riku1215/agora#4](https://github.com/riku1215/agora/issues/4) | **R-rules 本体** (全運用ルール) |
| [riku1215/agora#39](https://github.com/riku1215/agora/issues/39) | Knowledge Hub (1000+ Issue 蓄積本体) |
| [riku1215/quard-web-jp](https://github.com/riku1215/quard-web-jp) | デモ deploy 先 (Phase 5、`/products/agoora/`) |

---

## 7. 集合知 (本 Issue コメント参照)

R14 多 LLM レビュー履歴 (Phase 0.0 開始前の R&D 段階で実施済):

1. **コメント 1**: Grok prior-art (90 日 X/Reddit 5 事例、Tree-sitter / blast radius 提案)
2. **コメント 2**: Gemini design (Issue 外部脳 + Safety 防波堤 + Phase 1 KPI)
3. **コメント 3**: ChatGPT retrieval (agent_profiles.yaml + 7 step ロードマップ)
4. **コメント 4**: 命名検討 (agora 競合 → agoora、dual-track 戦略)
5. **コメント 5**: UI 進化 (Many-Worlds → GitHub IA 完全模倣)
6. **コメント 6**: 実装サマリ (PR #19 ~4,500 行 + 次タスク)

---

## 8. 次のアクション

- [ ] 本 Issue 投稿後、`agoora` repo の `master/main` で **R-rules 統合 PR #1** 作成
- [ ] `CLAUDE.md` に `@PROFILE.md` + `@agora#4` import 設定
- [ ] Captain Windows で UI 動作確認 → Phase 0.2 完了
- [ ] **MCP scope に agoora 追加** → 新セッションで開発継続

> **Phase 0.0 開始**. agora#4 の R-rules を絶対基準として、ここから始める。

`#agoora #phase-0 #vision #requirements #architecture #r-rules`
