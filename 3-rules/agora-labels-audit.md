---
tags: [agora, labels, audit, taxonomy, captain-portal, r-rules]
layer: foundation
audience: [captain-only, claude, all-llms]
status: active
source: riku1215/agora (search_issues 3 queries、2026-05-11 fetch)
coverage: 65/93 Issues (~70%)
---

# riku1215/agora ラベル監査 (2026-05-11)

`#agora #labels #taxonomy #audit`

> 全 93 Issues 中 65 件サンプリング (Issue #1-#32 + #66-#104 + 一部中間) で抽出した
> ラベル全種類 (65 unique)。**新旧 taxonomy 移行中**であることが判明。

## 0. 概要 (200 字)

agora は 93 Issues、ラベル 65 unique。**Prefix 構造化 taxonomy (`type:` `area:` `phase:` 等) への移行**が進行中で、旧 flat ラベル (`zz-deprecated-*` 28 個) は移行候補として open のまま retained。最も使用される現役ラベル: `status:done` (57)、`phase:01` (42)、`type:doc` (34)、`type:milestone` (34)、`type:research` (24)。

## 1. 新 Taxonomy (prefix:value 構造、30 labels)

### `type:*` — Issue タイプ (8 labels)

| ラベル | 件数 | 色 | 説明 |
|--------|-----|----|----|
| `type:doc` | 34 | `#0075CA` 青 | Documentation change |
| `type:milestone` | 34 | `#2B8BDA` 青 | Phase milestone tracker |
| `type:research` | 24 | `#A050A0` 紫 | Research / investigation |
| `type:decision` | 12 | `#8B5CF6` 紫 | Decision needed / ADR |
| `type:retro` | 6 | `#D4A72C` 黄 | Retrospective / war-story / post-mortem |
| `type:epic` | 3 | `#5319E7` 紫 | Parent issue grouping sub-issues |
| `type:strategy` | 1 | `#7BB0F5` 青 | Strategic plan (forward-looking) |
| `type:refactor` | 1 | `#D4C5F9` 薄紫 | Refactor / tech-debt cleanup |

### `area:*` — 領域 (10 labels)

| ラベル | 件数 | 色 | 説明 |
|--------|-----|----|----|
| `area:llm` | 9 | `#F472B6` 桃 | LLM integration (Gemini/Claude/OpenAI) |
| `area:arch` | 8 | `#2188FF` 青 | Architecture / framework / language |
| `area:test` | 8 | `#C2E0C6` 緑 | Testing strategy / QA |
| `area:ops` | 3 | `#2EA44F` 緑 | Deployment / monitoring / production |
| `area:ui` | 2 | `#F9D0C4` 桃 | UI / UX / a11y / i18n |
| `area:infra-runtime` | 2 | `#0DB7ED` 水 | Docker / Compose / K8s |
| `area:algorithm` | 2 | `#6F42C1` 紫 | Solver / scoring / heuristics |
| `area:data` | 2 | `#C7D2FE` 薄青 | Data model / DB / SQL |
| `area:infra-vps` | 2 | `#1F6FEB` 青 | VPS / server hosts (sakura-vps 等) |
| `area:integration` | 1 | `#C7D2FE` 薄青 | Cross-repo integration |

### `phase:*` — Phase (5 labels)

| ラベル | 件数 | 色 |
|--------|-----|----|
| `phase:01` | 42 | `#0E8A16` 緑 |
| `phase:09` | 8 | `#FBCA04` 黄 |
| `phase:02` | 4 | `#FBCA04` 黄 |
| `phase:04` | 2 | `#FBCA04` 黄 |
| `phase:00` | 1 | `#F9D71C` 黄 (Conceptualization) |

### `status:*` — 状態 (1 label)

| ラベル | 件数 | 色 | 説明 |
|--------|-----|----|----|
| `status:done` | 57 | `#22C55E` 緑 | Completed (kept open as knowledge) |

### 他 prefix (6 labels)

| ラベル | 件数 | 色 | 説明 |
|--------|-----|----|----|
| `triage:invalid` | 10 | `#E4E669` 黄 | DEFAULT for zero-label issues |
| `agent:claude` | 1 | `#8B5CF6` 紫 | Claude — Orchestrator/Architect |
| `doctrine:must` | 1 | `#B60205` 赤 | Must-comply directive (Captain) |
| `doctrine:instruction` | 1 | `#5319E7` 紫 | Declarative rule (always/never) |
| `priority:p0` | 1 | `#B60205` 赤 | Critical / blocking |
| `domain:cross` | 1 | `#6E7781` 灰 | Cross-domain (general) |

## 2. 旧 Taxonomy (`zz-deprecated-*`、28 labels)

**全て移行候補** (新 prefix taxonomy で代替済または代替予定):

| 旧ラベル | 件数 | → 新ラベル候補 |
|---------|-----|----------------|
| `zz-deprecated-done` | 57 | `status:done` |
| `zz-deprecated-phase-1` | 42 | `phase:01` |
| `zz-deprecated-research` | 24 | `type:research` |
| `zz-deprecated-documentation` | 21 | `type:doc` |
| `zz-deprecated-milestone` | 18 | `type:milestone` |
| `zz-deprecated-branch-point` | 16 | `type:decision` |
| `zz-deprecated-decision-log` | 12 | `type:decision` |
| `zz-deprecated-skill` | 11 | `type:doc` (skill 文書化) |
| `zz-deprecated-instruction` | 9 | `doctrine:instruction` |
| `zz-deprecated-llm` | 8 | `area:llm` |
| `zz-deprecated-phase-9` | 8 | `phase:09` |
| `zz-deprecated-architecture` | 6 | `area:arch` |
| `zz-deprecated-benchmark` | 6 | `type:research` |
| `zz-deprecated-war-story` | 6 | `type:retro` |
| `zz-deprecated-phase-2` | 4 | `phase:02` |
| `zz-deprecated-epic` | 3 | `type:epic` |
| `zz-deprecated-deployment` | 3 | `area:ops` |
| `zz-deprecated-ux` | 2 | `area:ui` |
| `zz-deprecated-docker` | 2 | `area:infra-runtime` |
| `zz-deprecated-language` | 2 | `area:arch` |
| `zz-deprecated-framework` | 2 | `area:arch` |
| `zz-deprecated-phase-4` | 2 | `phase:04` |
| `zz-deprecated-algorithm` | 2 | `area:algorithm` |
| `zz-deprecated-database` | 2 | `area:data` |
| `zz-deprecated-testing` | 2 | `area:test` |
| `zz-deprecated-vps` | 2 | `area:infra-vps` |
| `zz-deprecated-lessons-learned` | 1 | `type:retro` |
| `zz-deprecated-tech-debt` | 1 | `type:refactor` |

## 3. プレフィックスなし (7 labels)

| ラベル | 件数 | 色 | 説明 |
|--------|-----|----|----|
| `udp` | 7 | `#7057FF` 紫 | UDP 開発方法論 (cross-cut concept) |
| `knowledge` | 3 | `#1F6FEB` 青 | Cross-repo knowledge |
| `kuod-hp` | 2 | `#FF6B9D` 桃 | kuod-hp HP design knowledge |
| `design-system` | 2 | `#F2C14E` 黄 | UI design pattern |
| `review-needed` | 1 | `#d93f0b` 朱 | レビュー要 |
| `readability` | 1 | `#06B6D4` 水 | Text readability improvements |
| `shape-variety` | 1 | `#A855F7` 紫 | Shape diversity UI pattern |

→ 統一推奨: `udp` → `doctrine:udp`、`knowledge` → `type:research`、その他は domain 別整理

## 4. agoora repo への適用提案 ★ 推奨度

### A. agoora repo の初期ラベル設計 ★★★★★

agora の **新 taxonomy をそのまま採用**:

```bash
# Captain Windows で実行
gh label create -R riku1215/agoora "type:doc"        --color "0075CA" --description "Documentation change"
gh label create -R riku1215/agoora "type:milestone"  --color "2B8BDA" --description "Phase milestone tracker"
gh label create -R riku1215/agoora "type:research"   --color "A050A0" --description "Research / investigation"
gh label create -R riku1215/agoora "type:decision"   --color "8B5CF6" --description "Decision needed / ADR"
gh label create -R riku1215/agoora "type:retro"      --color "D4A72C" --description "Retrospective / war-story"
gh label create -R riku1215/agoora "type:epic"       --color "5319E7" --description "Parent issue grouping sub-issues"
gh label create -R riku1215/agoora "type:strategy"   --color "7BB0F5" --description "Strategic plan / direction"
gh label create -R riku1215/agoora "type:refactor"   --color "D4C5F9" --description "Refactor / tech-debt"

gh label create -R riku1215/agoora "area:llm"        --color "F472B6" --description "LLM integration"
gh label create -R riku1215/agoora "area:arch"       --color "2188FF" --description "Architecture / framework"
gh label create -R riku1215/agoora "area:test"       --color "C2E0C6" --description "Testing strategy / QA"
gh label create -R riku1215/agoora "area:ops"        --color "2EA44F" --description "Deployment / monitoring"
gh label create -R riku1215/agoora "area:ui"         --color "F9D0C4" --description "UI / UX / a11y / i18n"
gh label create -R riku1215/agoora "area:infra-runtime" --color "0DB7ED" --description "Docker / Compose / K8s"
gh label create -R riku1215/agoora "area:algorithm"  --color "6F42C1" --description "Solver / scoring"
gh label create -R riku1215/agoora "area:data"       --color "C7D2FE" --description "Data model / DB / SQL"
gh label create -R riku1215/agoora "area:integration" --color "C7D2FE" --description "Cross-repo integration"

gh label create -R riku1215/agoora "phase:00" --color "F9D71C" --description "Phase 0: Conceptualization"
gh label create -R riku1215/agoora "phase:01" --color "0E8A16" --description "Phase 1"
gh label create -R riku1215/agoora "phase:02" --color "FBCA04" --description "Phase 2"
gh label create -R riku1215/agoora "phase:05" --color "FBCA04" --description "Phase 5"

gh label create -R riku1215/agoora "status:done"     --color "22C55E" --description "Completed (kept open as knowledge)"
gh label create -R riku1215/agoora "priority:p0"     --color "B60205" --description "Critical / blocking"
gh label create -R riku1215/agoora "triage:invalid"  --color "E4E669" --description "Not actionable"

gh label create -R riku1215/agoora "agent:claude"    --color "8B5CF6" --description "Claude — Orchestrator/Architect"
gh label create -R riku1215/agoora "agent:gemini"    --color "4285F4" --description "Gemini — Researcher/Critic"
gh label create -R riku1215/agoora "agent:grok"      --color "1DA1F2" --description "Grok — Realtime/Counter"
gh label create -R riku1215/agoora "agent:chatgpt"   --color "10A37F" --description "ChatGPT — Technical detail"

gh label create -R riku1215/agoora "doctrine:must"        --color "B60205" --description "Must-comply (Captain)"
gh label create -R riku1215/agoora "doctrine:instruction" --color "5319E7" --description "Declarative rule"

gh label create -R riku1215/agoora "auto-relay"      --color "FF6B35" --description "1 Issue 起点自動リレー trigger"
```

### B. agora 既存 zz-deprecated-* を整理 ★★★

新 taxonomy に統合済の旧ラベルは `gh label delete` で削除可能 (但し agora は scope 外、別タスク)。

### C. 共通ラベルガイド (cross-repo) ★★★

riku1215/agora#40 (Cross-Repo Knowledge Transfer) で全 28 repo に統一ラベル展開済の知見:

> 共通: phase-1〜10, done, war-story, decision-log, instruction, skill, research, benchmark, branch-point, udp, lessons-learned, epic
> インフラ: vps, sakura-vps, infrastructure, deployment, production, docker, nginx, ssl, domain, backup, monitoring
> カテゴリ: algorithm, llm, ux, data-model, tech-debt, strategy, ui-polish

→ これも新 prefix 形式へ移行推奨。

## 5. agoora 内 markdown frontmatter への反映

本 repo の全 markdown frontmatter `tags:` field では:

- `type:*` `area:*` `phase:*` `status:*` の prefix を尊重
- 新規 markdown 作成時に該当 prefix tag を最低 3 つ付与
- 旧 flat tag (例: `r-rules`, `harness`) も併用可 (移行猶予)

## 6. 未取得 Issue 範囲 (R7 開示)

**サンプリング限界**: 93 Issues 中 65 件取得、未取得 28 件 (#2, #9, #38-#46, #47-#65 の一部):
- context window 制約で 3 query x 30 件 = 90 件相当だが overlap あり
- 未取得範囲に新規ラベルが存在する可能性 ≤ 20%
- 完全リスト取得は新セッション (agora MCP scope 拡張) で `gh label list -R riku1215/agora` 推奨

## 関連

- [agora#40](https://github.com/riku1215/agora/issues/40) Cross-Repo Knowledge Transfer (ラベル展開実績)
- [agora#39](https://github.com/riku1215/agora/issues/39) Knowledge Hub
- [agora#62](https://github.com/riku1215/agora/issues/62) R32 Proactive Info Gathering
- [agora#82](https://github.com/riku1215/agora/issues/82) R-rule consolidation
- 本 repo: `3-rules/r-rules-index.md`
- 本 repo: `3-rules/doctrine-clusters.md`
- 本 repo: `.kb-labels.yml` (ローカル開発ラベル定義)

`#agora #labels #taxonomy #audit #captain-portal`
