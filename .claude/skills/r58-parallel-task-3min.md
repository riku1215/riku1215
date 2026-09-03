---
name: r58-parallel-task-3min
description: 3 分+ 待ち task 発生時 = 並行実行可能 作業 候補 ★ ranking 提示 必須。 idle 時間 30-60 min/day 削減
type: r-rule
version: 1.0.0
source: agora#4 R58 (R73 Phase 2.1 Skill 化、 2026-05-07 制定)
related-rules: [R44, R55, R57, R67, R72]
---

# R58: 3 分+ 待ち = 並行候補 自動提案

## When to use

- **CI deploy** (Sakura VPS = 3-5 min)
- **CI test workflow** (Playwright + WeasyPrint = 4-7 min)
- **ChatGPT API dispatch** (gpt-5/o3 = 1-3 min)
- **Codex CLI exec --sandbox** (3-10 min)
- **Gemini Pro review** (1-3 min)
- **docker compose build --no-cache** (2-5 min)
- **pip install -e ".[dev]"** (初回 2-4 min)
- **大 dataset python script**

## What to do

### 提案 format (R57 + R58 統合)

```
## 3 行要約 (R57)
① 判断: <task は こう 進む>
② trade-off: <採用/不採用 で 何 が 変わる>
③ 懸念: <potential risk>

## 並行 提案 ★ ranking (R58、 待ち時間 ~N min 想定)
1. ★★★★★ <候補 task A> = <なぜ 妥当 / cost / 期待 効果>
2. ★★★★ <候補 task B>
3. ★★★ <候補 task C>

GO ください (1 / 2 / 3 / 待つ)。
```

### 並行 候補 設計原則

#### 1. 文脈 共有 task (即 着手可)
- 別 file edit (= 現 commit と 独立)
- docs / memory 起票
- 別 LLM dispatch (= ChatGPT 待ち中 に Codex を 別件 で)
- review 中 docs read
- Issue 加筆

#### 2. Captain 操作 必要 task (Captain で 並行)
- ChatGPT Web で 別 prompt review (Captain paste)
- nano banana mockup 生成
- Excel / CSV 準備
- 競合 SaaS 操作 確認

#### 3. 文脈 散逸 risk (慎重)
- 別 repo 着手 (context switch コスト)
- 大規模 refactor 着手

### R72 ゆっくり mode 連動

- ゆっくり mode = 並行 候補 抑制 (= 1 task 集中)
- 急ぎ mode = 並行 提案 多用

## NG (やってはいけない)

- ❌ 3 分+ 待ち で 「待って ます」 だけ で 終わる
- ❌ 並行 候補 を 5 件+ 出して Captain 認知負荷 増加
- ❌ destructive 操作 を 並行 候補 (= git reset --hard / prod VPS)
- ❌ 「OK」 trigger 待ち 中 に 別 commit (= R44 過度な自走 違反)

## OK (推奨)

- ✅ 3 分+ task trigger 直後 = 並行 ★ ranking 即 提示
- ✅ ★ ranking 3 件 cap (= 認知負荷 削減)
- ✅ Captain 操作 必要 task は 並行 で Captain に 投げる
- ✅ 文脈 共有 task 優先

## Example (= 本日 立証)

CI deploy 中 (3-5 min):
- 1. ★★★★★ docs/memory 起票 (R-rule 制定)
- 2. ★★★★ Issue 加筆 (= 関連 PR 番号)
- 3. ★★★ 別 LLM dispatch (= ChatGPT 別件)

= idle 時間 ゼロ 化 = 1 day 30-60 min 削減

## R-rule chain

- R44 (過度な自走 NG) = 並行 = Captain 確認 必要 task のみ
- R55 (全 LLM 必須) = 並行 dispatch で R55 速度 維持
- R57 (3 行要約) = 並行 提案 と セット
- R67 (Chrome 可視化) = 並行 status icon
- R72 (ゆっくり mode) = 並行 抑制

## 立証

- ClassWeaver 本日 24h+ で idle ゼロ 立証
