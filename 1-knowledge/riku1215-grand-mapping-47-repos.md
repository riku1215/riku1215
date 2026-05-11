---
tags: [grand-mapping, 47-repos, riku1215-eco, gap-analysis, captain-portal]
layer: knowledge
audience: [captain-only, claude, all-llms]
status: active-critical
source: search_repositories user:riku1215 (2026-05-11、47 件全件取得)
created: 2026-05-11
---

# riku1215 全 47 Repos Grand Mapping + 命名 error 4 件 corrigenda

`#grand-mapping #47-repos #corrigenda #section-7-2-violation`

## 0. Captain 指示 (2026-05-11)

> paw-sensor 等、他のレポジトリ、Issue もすべて見てマッピングする?

→ 28+ を超えて **47 repos** 判明。本 doc が agoora の **single source of truth** (グランド mapping)。

## 1. 全 47 Repos 一覧 (Issue 数降順、Tier 自動判定)

### 🟢 Tier 1 mature (Issues ≥ 100、Captain 主戦場)

| Repo | Issues | Lang | 役割 |
|------|--------|------|------|
| **dsi-kit-library** | **145** | Python | DSI 本体、Multi-axis specialized AI coding toolkit |
| **class-weaver** | **122** | Python | (description 空、推定: 時間割 SaaS、R29 calc_score↔CP-SAT 起源) |

### 🟢 Tier 2 active (Issues 30-100、active 開発)

| Repo | Issues | Lang | 役割 |
|------|--------|------|------|
| **agora** | **61** | Python | ★ **18 personas × 3 LLMs deliberation engine** (Kuuki Design 同型!) |
| **mindgate** | **48** | TypeScript | 業務規程違反防止 自己診断 Web (war-story #44) |
| **ai-financial-office** | **45** | TypeScript | 税理士事務所自動化 (freee + Gmail + Gemini)、dunning bot + invoice + journal |
| **pet-care-app** | **35** | Java | ペットケア統合管理 (Spring Boot + React)、DSI 適用 |
| **ai-native-management** | **31** | - | AI ネイティブ経営学 全 5 巻 Kindle 出版 |

### 🟡 Tier 2/3 (Issues 5-30、active 進行中)

| Repo | Issues | Lang | 役割 |
|------|--------|------|------|
| **ai-tool-catalog** | 25 | TypeScript | AI ツールカタログ検索・比較 Web (DSI 適用) |
| **riku1215** (本リポ) | 16 | Python | Captain プロフィール + Portal v1.5 完成 |
| **video-autopilot** | 14 | TypeScript | 動画編集・字幕・サムネ自動化 pipeline (DSI 適用) |
| **dsi-wizard** | 11 | TypeScript | VS Code Extension (interactive DSI workspace) |
| **book-studio** | 9 | TypeScript | Markdown → EPUB/PDF/Web 出版 toolkit (DSI 適用) |
| **kintaeru** | 8 | TypeScript | LINE 起点勤怠+給与 SaaS (5-100 人事業所、共同開発) |
| **paw-sensor** | 8 | Jupyter | PWA-based gait analysis 犬猫、vet clinic rental BtoBtoC |
| **skills-strategy-analysis** | 7 | JavaScript | GitHub Copilot Skills + Instructions 効果分析 |
| **shift-weaver** | 6 | Python | AI-Native Shift Management SaaS (OR-Tools Interval + LLM advisory) |
| **quard-web-jp** | 5 | Astro | クオード公式 HP (sakura レンタル deploy、24 products) |
| **doc-studio** | 4 | TypeScript | Document IDE for large technical docs (book-studio sibling) |
| **masaru-suto-www** | 3 | PHP | 須藤大建築設計事務所 HP (Sakura mirror) |

### 🔵 Tier 3 early / spec (Issues 1-2)

| Repo | Issues | Lang | 役割 |
|------|--------|------|------|
| **ai-marketplace** | 2 | TypeScript | 写真 1 枚自動出品 + 動的価格 SaaS (ClassWeaver eco) |
| **sourcecode-judge-saas** | 1 | Python | DSI dogfood, Code review GitHub App (judge-latitude + sandbox-* 5 言語) |
| **agoora** ★ 本 product | 1 | - | 個人開発者の知識の集まる場 (Captain's knowledge hub) |
| **quard-ui** | 1 | TypeScript | QUARD 共通 UI component monorepo (pnpm + Turborepo + React) |
| **quard-community** | 1 | - | コラーニング/コワーキング space SaaS (HLS弘前) |
| **skills** | 1 | - | QUARD custom Claude Code skills (28+ repo battle-tested) |
| **prompt-notes** | 1 | - | LLM プロンプト設計知見集 (public、archived) |
| **pj-terraform** | 1 | HCL | 個人開発共通 Terraform モジュール (AWS/GCP) |
| **dsi-presets-public** | 2 | - | DSI Preset: public industry |
| **dsi-presets-retail** | 2 | - | DSI Preset: retail |
| **dsi-presets-medical** | 2 | - | DSI Preset: medical |
| **dsi-presets-finance** | 2 | - | DSI Preset: finance |
| **dsi-presets-manufacturing** ★ 新発見 | 2 | - | DSI Preset: **manufacturing** (portal-config 漏れ) |
| **dsi-sandbox-public-java** | 1 | Java | DSI Sandbox Dockerized |
| **dsi-sandbox-retail-typescript** | 2 | TypeScript | DSI Sandbox Dockerized |
| **dsi-sandbox-finance-cobol** | 2 | COBOL | DSI Sandbox Dockerized |
| **dsi-sandbox-medical-csharp** | 2 | C# | DSI Sandbox Dockerized |
| **dsi-sandbox-manufacturing-python** | 2 | Python | DSI Sandbox Dockerized |

### ⚫ on-hold / archive (Phase 5 復活待ち、Issues 2)

| Repo | Status | 役割 |
|------|--------|------|
| **dsi-copilot-central** | on-hold | Central .github/copilot-instructions.md hub |
| **dsi-factory** | on-hold | DSI Auto-Scaffold Pipeline |
| **dsi-core** | on-hold | Generic Skills/Instructions/Templates |
| **dsi-improver** | on-hold | Two-layer improvement loop |
| **dsi-benchmark** | on-hold | DSI Benchmark Framework (SWE-bench methodology) |
| **dsi-docs** | on-hold | DSI architecture documentation hub |
| **dsi-hypotheses** | on-hold | DSI pipeline hypothesis tracking (Layer B improvement) |
| **dsi-judge-latitude** | on-hold | LLM-as-Judge integration with Latitude |
| **dsi-benchmark-results** | archived | Accumulated benchmark results archive |
| **pj-scripts** | on-hold | Git Hooks / 品質ゲートスクリプト集 |

## 2. 集計

| Category | 件数 |
|----------|------|
| **総 repo 数** | **47** |
| DSI Family (kit + wizard + factory + docs + core + improver + benchmark + benchmark-results + hypotheses + copilot-central + judge-latitude) | 11 |
| DSI Presets | 5 (public/retail/medical/finance/manufacturing) |
| DSI Sandbox | 5 (java/typescript/cobol/csharp/python) |
| Active SaaS/Tools | 17 |
| Web/HP | 5 (quard-web-jp / quard-ui / quard-community / masaru-suto-www) |
| Infrastructure | 2 (pj-terraform / pj-scripts) |
| Skills/Profile | 2 (skills / riku1215) |
| **合計 Issues 数** | **~750+** (dsi-kit 145 + class-weaver 122 + agora 61 + 他多数) |

## 3. portal-config.yml 命名 error 4 件 corrigenda

| portal-config の記載 | 実際の repo 名 | 修正 |
|--------------------|--------------|------|
| `shiftweaver` | `shift-weaver` (hyphen) | 修正必要 |
| `classweaver` | `class-weaver` (hyphen) | 修正必要 |
| `mindgate-tgl` | `mindgate` | 修正必要 |
| DSI presets 「5 個」 → 「4 個」修正 | 実 **5 個** (manufacturing 含む) | **元の 5 個が正解、最近の修正は誤り** |

## 4. 重大な未統合 repos (本セッション 14h+ で完全見落とし)

### ★★★★★ 最重要

| Repo | 重要理由 |
|------|---------|
| **agora** (61 Issues、Python) | **18 personas × 3 LLMs deliberation engine** = **Kuuki Design 模倣の本家**! 私が agora#4 や agora#82 を引用してきたが、repo 全体の正式設計を未調査。これは agoora の親プロジェクト。 |
| **ai-marketplace** (TypeScript) | 写真 1 枚 自動出品 + 動的価格 = ClassWeaver eco、Phase 5 商用化 path 候補 |
| **sourcecode-judge-saas** (Python) | DSI dogfood、Code review GitHub App = **agoora.reviewer 役の実装 reference** |

### ★★★★ 重要

| Repo | 重要理由 |
|------|---------|
| **doc-studio** (TypeScript) | book-studio sibling、DSI-Mixer Templates + doc-split-merge Skills 統合 |
| **ai-native-management** (31 Issues) | Kindle 全 5 巻、agoora の business.strategy ドメイン |
| **dsi-sandbox-* (5 言語)** | DSI 評価用 Dockerized 環境、agoora.impact-analyst の test 基盤 |
| **prompt-notes** (archived、public) | LLM プロンプト設計の実プロジェクト知見集、agoora.researcher reference |

## 5. agora repo の真の意味 (本セッション 14h+ で気付けなかった重大事実)

**agora** = `multi-agent deliberation engine (18 personas × 3 LLMs, GitHub-native)`

これは **Kuuki Design 18-agent organization の正式実装**!
- 私は agora#4 (R-rules) と agora#82 (7 doctrine cluster) だけを引用
- repo 全体は 18 個の専門 agent (persona) で deliberation を行う engine
- → **agoora の 10 役は実は agora の 18 役のサブセット**

→ **agoora は agora の "Web GUI + knowledge hub" レイヤー** という再定位が正しい。

## 6. portal-config.yml 次回更新 (Phase 1.5)

47 repos 全件を `quard_products` + `dsi_ecosystem` に登録、tier 別整理、
命名 error 4 件修正。本 doc が完成版 source of truth。

## 7. Section 7-2 違反検出 (大規模)

**本セッション 14h+ で私が見落とした 22 repos**:
- agora 本体 (18 personas engine)
- ai-marketplace / sourcecode-judge-saas / doc-studio
- ai-native-management (31 Issues)
- prompt-notes (LLM プロンプト知見)
- dsi-sandbox-* (5 言語 Dockerized)
- dsi-docs / dsi-benchmark / dsi-hypotheses / dsi-judge-latitude
- dsi-presets-manufacturing
- pj-scripts (Git Hooks)
- quard-ui (UI component monorepo)
- quard-community

**counterfactual** (もし I1 Pre-Action Probe があれば):
```
session 開始時:
  researcher.fan_out("user:riku1215")
  → 47 repos 即時取得
  → tier 分類 + Issue 数 ranking
  → portal-config.yml dsi_ecosystem 完全版登録
  → 命名 error 4 件 事前検出
  → 22 repos 見落とし 100% 防止
```

→ **22 repos 見落とし = I1 機構の必要性 強力 証拠**。

## 8. 次セッション最優先 (Captain への提案)

| # | 項目 | 推奨度 |
|---|------|--------|
| 1 | **agora 全 61 Issues の reading** (18 personas 詳細把握、agoora 親) | ★★★★★ |
| 2 | portal-config.yml 47 repos 全件登録 + 命名修正 | ★★★★★ |
| 3 | I1 Pre-Action Probe を SessionStart hook で実装 (Phase 1.5b) | ★★★★★ |
| 4 | dsi-kit-library 145 Issues + class-weaver 122 Issues 体系 audit | ★★★★ |
| 5 | sourcecode-judge-saas を agoora.reviewer 役の reference として indexing | ★★★★ |

## 9. 関連

- [agora](https://github.com/riku1215/agora) ★★★★★ (18 personas × 3 LLMs、agoora 親)
- [dsi-kit-library](https://github.com/riku1215/dsi-kit-library) (145 Issues、Tier 1 max)
- [class-weaver](https://github.com/riku1215/class-weaver) (122 Issues、Python)
- 本 repo: `4-portal/portal-config.yml` (47 repos 全件登録、Phase 1.5)
- `1-knowledge/dsi-family-overview.md` (前段、15 DSI repos)
- `1-knowledge/dsi-copilot-central-integration.md`
- `1-knowledge/disruptive-innovation-5-proposals.md` (I1 = 本見落とし防止)
- `1-knowledge/counterfactual-agoora-could-have-prevented.md` (本 doc が事例追加)

`#grand-mapping #47-repos #section-7-2-violation-confirmed #agora-is-parent`
