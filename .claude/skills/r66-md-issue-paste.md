---
name: r66-md-issue-paste
description: md Doc 作成 = Issue 必須 paste / link (Captain 可視化 + 好判断 連動)。 Captain 経営者視点 = GitHub Issue 主 channel = file system navigation しない 前提
type: r-rule
version: 1.0.0
source: agora#4 R66 (R73 Phase 1 Skill 化、 2026-05-07 制定)
related-rules: [R30, R44, R56, R57, R63, R65, R67]
---

# R66: md Doc → Issue 必須 paste / link

## When to use

- **plan doc** 作成時 (24/48/72h plan, roadmap 等) = 全文 paste
- **retrospective / report** 作成時 = 全文 paste + 関連 link
- **memory / R-rule 制定 時** = summary paste + agora#4 link
- **dispatch 結果** (ChatGPT / Codex review) = 主要 抽出 paste + file link
- **draft / 起草** (本文 / 章) = link + summary paste

## What to do

### Step 1: md doc 作成 = 同 turn で Issue paste / link

| md doc 種別 | Issue 反映 形式 | priority |
|------------|---------------|---------|
| plan doc | 全文 paste | ★★★★★ 必須 |
| retrospective | 全文 paste + link | ★★★★★ 必須 |
| memory / R-rule | summary paste + agora#4 link | ★★★★ 必須 |
| dispatch 結果 | 主要 抽出 + file link | ★★★ 推奨 |
| draft | link + summary | ★★★ 推奨 |
| debug / log | file link のみ | ★★ 任意 |

### Step 2: paste 場所 (= Issue 選定)

| doc 内容 | paste Issue |
|---------|-----------|
| 朝 GO list / 24/48/72h plan | agora master Issue (= agora#73 等) |
| 該当 repo 関連 | repo Issue |
| 多 repo 横断 | agora#4 / agora#59 |
| 章 / 本文 | 各 章 sub Issue |

### Step 3: paste format 規律

- **TL;DR 3 行** 先出し (R57 連動)
- **★ ranking** 必須 (R17)
- **番号 一意性** (R64)
- **GO format 例** (= 1-click 回答 path)
- **table 多用** (= 経営者 table 視覚)

## NG (やってはいけない)

- ❌ docs/ に md 起票 で Issue paste skip (= Captain 不可視)
- ❌ commit message のみ で plan / 戦略 共有 (= git log 詳読 しない 想定)
- ❌ debug log を 全 paste (= 認知ノイズ)
- ❌ 同 内容 を 複数 Issue に 重複 paste
- ❌ markdown table を `| | |` raw で paste (= GitHub 自然 render 確認)

## OK (推奨)

- ✅ md 起票 = **同 turn** で Issue paste / link
- ✅ paste body 先頭 = TL;DR 3 行 + ★ ranking
- ✅ master Issue (= agora#73 等) に link 集約 + 詳細 = 各 sub Issue
- ✅ Issue label で 検索性 (`plan`, `roadmap`, `R-rule` 等)

## Example (= 本日 立証)

24/48/72h plan doc 起票 (= `class-weaver/docs/plans/2026_05_07_24_48_72h_plan.md`):
1. md doc 作成 (= class-weaver repo)
2. agora#73 (= 朝 GO 集約 hub) に **全文 paste**
3. CT (Captain Tab 1) で Chrome 1-click 把握

## R-rule chain

- R30 (発見=即 Issue) = R66 拡張
- R44 (過度な自走 NG) = silent doc 進行 抑制
- R57 (3 行要約) = paste 先頭
- R63 (質問 増やせ) = paste 末尾 質問 list
- R65 (24/48/72h plan) = plan = R66 必須
- R67 (Chrome 可視化) = R66 静的 + R67 動的 = 補完

## 立証

- 本日 24h+ で plan / retrospective / dispatch 結果 多数 paste
- 「12+ doc 不可視」 状態 (= R66 制定 前) → 「全 paste / link」 状態 へ 改善
