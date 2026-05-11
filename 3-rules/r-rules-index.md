---
tags: [r-rules, agora, doctrine, captain-portal, 3-rules, phase-0-1]
layer: foundation
audience: [captain-only, claude, all-llms]
status: active
source: riku1215/agora#4 + #82 (R-rule consolidation)
fetched: 2026-05-11
---

# R-rules 全体 index (riku1215/agora 由来、2026-05-11 fetch)

`#r-rules #doctrine #agora-source`

> 出典: [agora#4 Master Operating Guidelines](https://github.com/riku1215/agora/issues/4) +
> [agora#82 R-rule consolidation 7 doctrine cluster](https://github.com/riku1215/agora/issues/82)
> 本 index は agoora repo 内で R-rules を即時参照可能にするための再構成。

## 0. 概要

- **R-rule 総数**: R5-R82 (~50 active rules)
- **7 Doctrine Cluster** に統合 (agora#82 ★★★★★ 提案、Captain 採用前提)
- **17 Independent** ルール (cluster 不要、単独)
- Section 7 失敗パターン (PROFILE.md 由来、10 件)

## 1. 7 Doctrine Cluster (agora#82)

### D-A. Multi-LLM Dispatch Doctrine ★ Primary: **R55**

| Rule | 内容 |
|------|------|
| **R55** | 全 LLM 必須 (forward review) |
| R45 v2 | fluid persona (LLM 役割 swap) |
| R59 | 鵜呑み NG = Claude 初期判断 → Codex/ChatGPT 検証 (sideways) |
| R70 | Captain 戦術指示疑え + 反論 + 解決策 |
| R77 | Claude 単独判断 NG + Captain 指示 + 多 LLM |
| R79 | Captain 修正提案 = Codex (+ 多 LLM) dispatch + 高品質 |
| R82 | 実行後 多 LLM 分析 (backward review) |

**agoora 適用**: `agents.yml` の critic 役は別 LLM 強制 + `routing.yml` always_apply で R14 強制。

### D-B. Captain Communication / Entry-level ★ Primary: **R56**

| Rule | 内容 |
|------|------|
| **R56** | entry-level 説明 (例え話 + 何が起きた + 結果) |
| R71 | 言語化 failure 補完視点 (NG 用語禁止) |
| R78 | Gemini = 分かりやすい文章化ルーティーン |

**agoora 適用**: orchestrator output_format に 200 字結論 + entry-level 例え話必須。

### D-C. Question Quality ★ Primary: **R76**

| Rule | 内容 |
|------|------|
| **R76** | 質問 = 5 軸構造化 |
| R63 | 質問増やして無駄回避 |
| R81 | **候補を提案せずに質問しない (must)** |

**agoora 適用**: orchestrator が Captain に質問する際は **候補リスト先付け + ★ 推奨度**。

### D-D. Autonomy & Planning ★ Primary: **R65**

| Rule | 内容 |
|------|------|
| **R65** | 24/48/72h plan |
| **R10** | batched authorization |
| **R16** | autonomous run mode |
| **R20** | 5-min timeout auto-execute |
| R44 | (詳細確認要) |
| R61 | 夜間浅く広く |
| R72 | ゆっくり mode |

**agoora 適用**: `protocol.md §11 Phase 1 KPI`、`route.sh` の Safety Breakwater、6h 自走時の自動執行。

### D-E. Visibility & Reporting ★ Primary: **R57**

| Rule | 内容 |
|------|------|
| **R57** | 3-line 要約 |
| **R66** | md doc → Issue paste |
| R67 | Chrome 複数モニター自走可視化 |

**agoora 適用**: protocol.md §9 Issue-as-shared-memory = R66 完全実装。

### D-F. Quality Gate ★ Primary: **R80**

| Rule | 内容 |
|------|------|
| **R80** | 1 度で高品質完成 (= 反復 fix NG) |
| **R27** | 5-gate Definition of Done |
| R34 | 実操作 verify |
| R49 | console first (silent bug) |
| R50 | Captain 指示前 Gemini pre-check |

**agoora 適用**: reviewer agent の severity 判定、CI/CD lint workflow。

### D-G. Pushback / Premise ★ Primary: **R19**

| Rule | 内容 |
|------|------|
| **R19** | Question the Premise |
| **R8** | 反論ルール (R8 反論余地) |
| **R18** | Pushback-as-Algorithm |
| R60 | Vision = Captain 専管 (鵜呑み必須) |
| R75 | Captain 抽象 → Claude スキーム化 |

**agoora 適用**: critic agent の必須行動 (反論最低 3 件)、R8 always_apply。

## 2. Independent Rules (17 件、cluster 不要)

| Rule | 内容 | agoora 適用 |
|------|------|-----------|
| R5 | 既存確認 (重複 NG) | researcher 役の必須 fan-out |
| R7 | 知識前提 NG = 制約即時開示 | orchestrator 冒頭 |
| R11 | 個人情報範囲 | visibility: captain-only ラベル |
| R12 | nano banana mockup | UI モックパターン |
| R13 | 固定費延期 | 月額管理 |
| R14 | 多 AI 協調 | (D-A と同期) |
| R15 | Captain 事前質問 | proactive 確認 |
| R17 | ★ ranking | 全提案で必須 |
| R22 | 資料受領 destination | historian agent |
| R23 | Conflict-Prevention Rampart | reviewer の severity gate |
| R24 | Cross-Session 整合 | claude-mem |
| R25 | Post-merge verify | CI/CD |
| R26 | 教室数 (固有) | class-weaver 専用 |
| R28 | 高校 scope (固有) | class-weaver 専用 |
| R29 | calc_score↔CP-SAT (固有) | class-weaver 専用 |
| R30 | 発見即 Issue 化 | historian + Issue-as-memory |
| R31 | v2 commit cadence | git workflow |
| R32 | Proactive Info Gathering | (agora#62 詳細、自走 trigger) |
| R33 | cross-check 即 fix | reviewer loop |
| R35 | Stuck → Issue Patrol | orchestrator |
| R64 | 番号一意性 (R-rule 番号 freeze) | 本 index の不変条件 |
| R68 | 内容重複確認 | researcher |
| R69 | new repo private | agoora は private ✓ |
| R74 | GHA blog sweep | Phase 5 商用 |

## 3. Section 7 失敗パターン (PROFILE.md 由来、10 件)

agoora の Section 7 として継承:

| # | パターン | 防止策 |
|---|---------|--------|
| 7-1 | 観察精度の徹底 | UI 要素逐一読取、曖昧判断禁止 |
| 7-2 | セッション文脈の完全利用 | 既出情報再確認禁止、対話チャネル自体が情報 |
| 7-3 | 推察優先、確認は最小化 | 確認質問 ≤ 2/turn |
| 7-4 | 制約即時開示 (R7 強化) | 冒頭で物理的不可操作を明示 |
| 7-5 | 焦点ロック | 最優先課題から逸脱しない |
| 7-6 | 失敗即時学習 | 根本原因 1 行明示、「失礼しました」だけで流さない |
| 7-7 | 出力分量の節度 | 結論→詳細、表/見出し機械的並べ NG |
| 7-8 | 自信度と反論余地 | ★ 推奨度または確信度 (%) 付与 |
| 7-9 | ツール利用の効率 | 並列実行可能なツール呼出は 1 メッセージで束ねる |
| 7-10 | 外部 LLM 相談プロトコル | (R14 多 LLM レビューの一形態) |

## 4. agoora ハーネスへのマッピング

### agents.yml × R-rules
| agent | 該当 R |
|-------|-------|
| orchestrator | R5/R7/R9/R10/R57/R65/R76/R81 |
| researcher | R5/R30/R32/R66/R68 |
| architect | R8/R17/R19/R75 |
| critic | R8/R14/R18/R19/R55/R59/R82 |
| coder | R27/R34/R49/R80 |
| reviewer | R23/R25/R27/R33/R50 |
| historian | R22/R24/R30/R66 |

### routing.yml × Cluster
- `urgent-bypass` → D-D (R20 auto-execute)
- `new-feature` → D-A + D-G (R14 + R8 必須)
- `strategy-decision` → D-G + D-B (R19 + R56)
- `bug-fix` → D-F (R27/R80)

## 5. セッション開始時の自動ワークフロー (agora#4 由来)

毎セッション最初に必ず実施:

```bash
# 1. agora#4 を fetch — global Instruction (R1〜R82) を context に焼く
gh issue view 4 -R riku1215/agora 2>&1 | head -300

# 2. 本 repo の open issue 上位 30 を一覧
gh issue list -R riku1215/<repo> --state open --limit 30 \
  --json number,title --jq '.[] | "#\(.number) \(.title)"'

# 3. 直近 5 コミット
git log --oneline -5

# 4. R10 (Batched Authorization) フォーマットで作業計画提示 → user 合意取得
```

**長セッション時 (30 メッセージ超)**:
- agora#4 再 fetch
- 直近 5 メッセージを R-rules に照らして自己監査

## 6. 関連

- [agora#4](https://github.com/riku1215/agora/issues/4) — Master Operating Guidelines (本 index の原典)
- [agora#82](https://github.com/riku1215/agora/issues/82) — R-rule consolidation 7 doctrine cluster
- [agora#62](https://github.com/riku1215/agora/issues/62) — R32 Proactive Info Gathering 詳細
- [agora#40](https://github.com/riku1215/agora/issues/40) — Cross-Repo Knowledge Transfer Protocol
- [agora#39](https://github.com/riku1215/agora/issues/39) — Knowledge Hub
- 本 repo: `3-rules/doctrine-clusters.md` (cluster 詳細)
- 本 repo: `3-rules/R9-checklist-template.md`
- 本 repo: `3-rules/R10-batched-authorization-template.md`
- 本 repo: `PROFILE.md Section 7` (失敗パターン詳細)

`#agoora #r-rules #doctrine #captain-portal #phase-0-1`
