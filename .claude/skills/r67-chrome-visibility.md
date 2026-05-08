---
name: r67-chrome-visibility
description: Chrome 複数モニター 自走 可視化 (R66 拡張 = live progress)。 各 phase 完了 で agora master Issue comment paste + Chrome 8 tab URL list 提示
type: r-rule
version: 1.0.0
source: agora#4 R67 (R73 Phase 1 Skill 化、 2026-05-07 制定)
related-rules: [R30, R44, R57, R63, R65, R66]
---

# R67: Chrome 複数モニター Live Progress 可視化

## When to use

- **session 開始時** = Chrome 8 tab URL list 提示
- **commit + push 完了** = ✅ comment paste
- **dispatch 開始 / 完了** = 🔄 / ✅ paste
- **Captain 待ち 移行** = ⏸ comment (= 私 idle 状態 明示)
- **障害 / 失敗** = 🔴 即 paste (= 例外、 連発 OK)

## What to do

### Step 1: Chrome 複数モニター URL list 提示

| tab | URL 種別 | 用途 |
|-----|---------|------|
| 1 (主) | agora master Issue (= #73 等) | live progress hub |
| 2-4 | 各 PJ Issue | 個別 PJ 進捗 |
| 5 | Multi-Project Kanban | 全 repo 進捗 |
| 6 | 朝報告 doc | 詳細 |
| 7 | agora#4 | R-rule 累積 |
| 8 | GitHub Actions | CI live log |

### Step 2: 各 phase 完了 で master Issue paste

| event | comment format |
|-------|---------------|
| commit + push | ✅ <task> = commit `<hash>` push 済 + URL |
| dispatch 開始 | 🔄 <task> dispatch 開始 (~N min) + task ID |
| dispatch 完了 | ✅ <task> dispatch 結果 = <主要 抽出> + file link |
| Captain 待ち | ⏸ <task> = Captain action <X> 待ち |
| 障害 / 失敗 | 🔴 <task> 失敗 = <理由>、 代替案 ★ ranking |
| 3h cycle 経過 | 📊 <累積 統計> + 次 phase plan |

### Step 3: paste 頻度 (R44 + R67 balance、 R72 ゆっくり mode 連動)

- **小 commit** (1-5 min) = 5-10 commit ごと まとめ paste (= 連発 NG)
- **中 task** (30 min-2h) = 開始 + 完了 = 2 paste
- **大 task** (2h+) = 開始 + 30 min 中間 + 完了 = 3 paste
- **Captain 待ち** = 必ず ⏸ paste 1 度 (= idle 状態 明示)
- **R72 ゆっくり mode** = 完了時 のみ 1 paste (= 中間 paste 削減)

## Status icon 規律

| icon | 意味 |
|------|------|
| ✅ | 完了 |
| 🔄 | 進行中 |
| ⏸ | Captain 待ち / idle |
| 🔴 | 失敗 / 障害 |
| 📊 | 統計 / 累積 報告 |
| ⚠ | warning / 反省 / 違反 候補 |
| 🆕 | 新規 制定 / 新 候補 |
| 🌅 | 朝報告 / morning |
| 🌙 | 夜間自走 / night |
| 🐢 | ゆっくり mode (R72) |

## NG (やってはいけない)

- ❌ silent 自走 (= Captain Chrome 何 も 見えない、 R44 過度な自走 candidate)
- ❌ 大量 paste 連発 (= 1-2 min ごと、 認知ノイズ)
- ❌ 抽象 paste (= 「進行中」 のみ で 詳細 なし)
- ❌ task 完了 で paste skip (= R66 違反)
- ❌ Chrome URL list 提示 skip

## OK (推奨)

- ✅ session 開始時 = 8 tab URL 提示
- ✅ 各 phase 完了 で **status icon + 1-2 文** paste
- ✅ 並列 task = 番号 + icon で 同時 状態 把握 (= ① ② ③ ✅ 🔄 ⏸)
- ✅ Captain 待ち = ⏸ 明示 (= idle 隠さない)
- ✅ 3h cycle (R62 連動) で 累積統計 paste

## Example (= 本日 立証)

```
🔄 ④ ShiftWeaver test 進行中 (~2 h)
✅ ⑧ R62 schtasks command 提示 完了
⏸ ⑤ Captain Issue #29 paste 待ち
🔄 (副) R62 6h dispatch background (~2 min)
```

## R-rule chain

- R30 (発見=即 Issue) = R67 ベース
- R44 (過度な自走 NG) = silent 自走 抑制
- R57 (3 行要約) = paste format
- R63 (質問 増やす) = ⏸ paste で 連動
- R65 (24/48/72h plan) = progress 化
- R66 (md→Issue paste) = 静的 補完

## 立証

- agora#73 = 本 R-rule 立証 hub (= 朝 GO 8 件 + live progress)
- 24h+ で 30+ progress paste 累積 = Captain 1-click 把握 path
