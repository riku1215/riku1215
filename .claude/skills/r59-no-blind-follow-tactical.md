---
name: r59-no-blind-follow-tactical
description: Captain 戦術 指示 受領 = 即着手 NG = Claude 初期判断 + 確信 90%+ 即実装 / 70-89% Codex 1 体 / <70% Codex+ChatGPT 並列
type: r-rule
version: 1.0.0
source: agora#4 R59 (R73 Phase 1 Skill 化、 2026-05-07 制定)
related-rules: [R8, R18, R44, R45, R47, R50, R55, R60, R63, R70, R71]
---

# R59: 鵜呑み NG (戦術 critical) → Codex+ChatGPT 検証

## When to use

- **Captain 戦術 指示 受領 直後** (= vision ではなく 戦術 = R60 と 区別)
- **新規 repo / scope 変更 / 機能 提案 受領**
- **destructive 操作 受領** (= 削除 / archive / migration)
- **「すぐやって」 「即実行」 系 受領 でも 戦術 case = R59 適用**

## What to do (3 step)

### Step 1: Claude 初期判断 (mandatory、 30 sec)

1. 理解確認 = 指示 真意 verbal 化
2. 前提検証 (R19) = 暗黙 想定 列挙 + 確信度 (%)
3. 副作用 列挙 = 影響 範囲
4. 代替案 ★ ranking (R17) = 1-3 案
5. 確信度 自己評価 = 90%+ / 70-89% / <70%

### Step 2: 確信度 別 分岐

| 確信度 | action |
|-------|-------|
| **90%+** | 即実装 → R57 (3 行要約) で Captain 報告 → R58 並行候補 |
| **70-89%** | Codex **or** ChatGPT 1 体 dispatch (lightweight、 ~30 秒) |
| **<70%** | Codex **+** ChatGPT 並列 dispatch (R55 全 LLM) → 結果 + ★ ranking で Captain 再提示 |

### Step 3: 結果 持参 で Captain 再提示 (= 不確定 case)

```
## 指示 受領 後 検証 結果 (R59 適用)

### 私 初期判断
- 確信度: <70-89%>
- 懸念: <X が 不明>

### Codex 結果 (~30 秒)
- <findings>

### ChatGPT 結果 (~1-2 min)
- <findings>

### 統合 ★ ranking
1. ★★★★★ <案 A>
2. ★★★★ <案 B>

GO ください (1 / 2 / 待つ)。
```

## NG (やってはいけない)

- ❌ Captain 戦術 指示 = 即 Edit / commit / push (= 鵜呑み)
- ❌ 「OK」 trigger を 戦術 受領 直後 に 適用 (= R59 違反)
- ❌ 初期判断 飛ばし いきなり Codex / ChatGPT dispatch (= 思考停止、 cost 浪費)
- ❌ 不確定 (< 70%) で 単独進行
- ❌ vision レベル に R59 適用 (= R60 違反)

## OK (推奨)

- ✅ 30 秒 で 初期判断 5 項目 verbal
- ✅ 確信 90%+ task = 即実装 + R57 報告
- ✅ 不確定 task = Codex/ChatGPT に **具体的 質問**
- ✅ dispatch 中 = R58 並行候補 で idle 0
- ✅ R45 v2 fluid persona で dispatch system prompt 設計

## Example

```
Captain: 「クラス default を 5 → 12-18 に 拡張」

私 初期判断:
- 確信度 85% (= 戦術 critical = 70-89%)
- 前提: 普通中規模校 4-6 組 × 3 学年 = 12-18 cls 必要
- 副作用: project_api.py + assignment 生成 logic + group_cells 計算
- 代替案: ① 共通/普通 = 4 組 ② 共通 = 3 組 ③ 全 一律 4 組

→ Codex dispatch (1 体) で 「既存 code 互換性」 確認 → 結果 OK で 即実装
```

## R-rule chain

- R8 (反論ルール) / R18 (Pushback-as-Algorithm) = 個別 反論
- R44 (過度な自走 NG) = R59 = 「鵜呑み 進行 = 過度な自走 候補」 補強
- R45 v2 (fluid persona) = dispatch system prompt 設計
- R55 (全 LLM 必須) = <70% case で 強制適用
- R60 (vision = Captain 専管) = 補完 関係 = vision 鵜呑み / 戦術 critical
- R63 (質問増やせ) = dispatch + 質問 list セット
- R70 (Captain 戦術 疑え) = R59 強化版

## 立証

- 本日 18+ commit で 多数 適用、 silent bug 11 turn 浪費 retrospective から 制定
