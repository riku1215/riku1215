---
name: r72-slow-mode
description: 「ゆっくり mode」 = Captain 3h+ 指定 時 = 1 task 集中 + 質 重視 + paste 完了時 のみ + 並列 task 抑制 + R20 5 min auto 抑制
type: r-rule
version: 1.0.0
source: agora#4 R72 (R73 Phase 1 Skill 化、 2026-05-07 制定)
related-rules: [R20, R44, R57, R61, R62, R67]
---

# R72: ゆっくり mode (= 1 task 集中 + 質 重視)

## When to use

| Mode | trigger |
|------|---------|
| 急ぎ | 「即」 「all Go」 「3h 自走」 「急いで」 |
| **ゆっくり (= R72)** | **「ゆっくり」 「慎重に」 「Xh あげる」 「集中して」** |
| 緊急 | silent bug / security / critical |
| idle | Captain action 待ち / 「保留」 |

## What to do (ゆっくり mode 動作)

### Step 1: 1 task 集中 (30-60 min)

- 並列 task 起動 NG (= 1 task のみ)
- 副 task = idle OK
- 完了 まで 集中

### Step 2: 質 重視

- code review = 自分 で 2 周 (= 急ぎ mode は 1 周)
- test = unit + integration + edge case
- doc = R57 + R66 + R71 配慮 言語
- Captain 確認 質問 = R75 軸 6 MUST + R76 5 軸

### Step 3: paste 抑制

- 完了時 = 1 paste (= 全 内容 集約)
- 中間 paste NG (= 認知ノイズ)
- 「○○ 着手 開始」 paste NG
- 例外 = 障害 / 失敗 = 即 paste (= R67 連発 OK)

### Step 4: R20 5 min auto 抑制

- 急ぎ mode = ★ 推奨 5 min で auto 実行
- ゆっくり mode = ★ 推奨 後 = **Captain 確認 待ち + 別 task**
- = 「待つ こと」 自体 が ゆっくり mode の 価値

## NG (やってはいけない、 ゆっくり mode 限定)

- ❌ paste 連発 (= 認知ノイズ)
- ❌ R20 5 min auto で 即実行
- ❌ 並列 task 起動 (= 1 task 集中 違反)
- ❌ 「次 何 やる?」 焦る 提案
- ❌ 中間 status paste (= 待つ Captain 認知負荷)

## OK (推奨)

- ✅ 1 task 30-60 min 集中
- ✅ 質 重視 (= test / doc / 配慮 言語)
- ✅ 完了時 = 1 paste (= 集約)
- ✅ Captain action 待ち = idle OK + 副 task 1 件 軽進展
- ✅ R75 軸 6 MUST + R76 5 軸 で 質問 構造化

## Mode 切替 trigger

| 入力 | mode |
|-----|------|
| 「即」 「all Go」 「3h 自走」 | 急ぎ mode |
| 「ゆっくり」 「慎重に」 「Xh あげる」 | ゆっくり mode (本 R-rule 適用) |
| 「緊急」 「silent bug」 | 緊急 mode |
| 「待ってる」 「保留」 | idle mode (= 私 stop) |

## Example (= 本日 立証)

Captain 直 「3h あげる から ゆっくり やって」 受領 後:
- ✅ R72 mode 切替 宣言
- ✅ 順序 v2 = A → G → D → F 1 task ずつ 30-45 min 集中
- ✅ paste = 完了時 のみ 4 paste (= 中間 status なし)
- ✅ 並列 task = 1 件 維持 (= 健全)

## R-rule chain

- R20 (5 min auto) = 急ぎ mode default / R72 = ゆっくり mode で 抑制
- R44 (過度な自走 NG) = R72 で 補強
- R57 (3 行要約) = paste 質 重視
- R61 (24-6 時 浅広) = 通常 mode 強化版
- R62 (時間トリガー 統計) = 質 重視 で cycle 連動
- R67 (Chrome 可視化) = paste 抑制 で 認知効率
- R75 軸 6 + R76 = 質問 質 重視 連動

## 立証

- 本日 24h+ 後半 = Captain 「3h ゆっくり」 受領 後 = R72 mode 切替 ✓
- 急ぎ mode (paste 連発) → ゆっくり mode (1 paste 集約) で 認知ノイズ 削減
