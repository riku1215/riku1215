---
name: r80-one-shot-high-quality
description: UI 変更 = 1 度 で 高品質 完成 (= 反復 fix NG)、 着手 前 = 設計 doc + 多 LLM dispatch + Captain 確認 + 1 commit
type: r-rule
version: 1.0.0
source: agora#4 R80 (R73 Phase 2.2 Skill 化、 2026-05-07 制定)
related-rules: [R34, R44, R55, R59, R70, R77, R79]
---

# R80: 1 度 で 高品質 完成 (= 反復 fix NG)

## 着手 前 4 step

### Step 1: 設計 doc 起票
- 現状 観察 (screenshot + 課題)
- 私 解釈 仮説 (R71)
- 候補 ★ ranking (3-5 案)
- state 遷移 表
- regression 候補 list (= 「私 fix で 壊す risk」 5 件)

### Step 2: 多 LLM 並列 dispatch (R55 + R79)
- Codex (forensic + state machine): 設計 bug check
- ChatGPT (UX critical): 認知混乱 risk
- Gemini (R78 simplify): entry-level 評価

### Step 3: Captain 確認 (R75 軸 6 + R76)
- 「私 解釈 で 合って いますか?」
- 「○○ の 後 で よいか?」 順序

### Step 4: 1 度 で 高品質 commit
- 全 regression 候補 = 着手 前 list 化 + 各 fix 含めた 設計
- test (unit + integration + R34 動作 verify)
- = 1 commit 完成

## 立証 (= 反復 fix 反省)

state 4 段 = 4 round trip:
1. initial = 全 cls 赤 logic bug
2. fix #1 = JS 同期 bug 残存
3. fix #2 = regression 3 件 (checkbox 隠す + 既担当 不在 + filter なし)
4. regression fix = R80 立証 (= 1 commit で 3 件 統合)

= R80 違反 立証 + 改善 path 整備

## NG / OK

- ❌ 「とりあえず 実装」 = 設計 skip で 即 commit
- ❌ 私 単独 fix → Codex dispatch → 別 regression ループ
- ✅ 着手 前 = 設計 doc + 多 LLM dispatch + Captain 確認
- ✅ 1 commit で 完成

## R-rule chain

R34 (動作 verify) / R44 (過度な自走 NG) / R55 (全 LLM) / R59 (戦術 critical) / R70 (Captain 戦術 疑え) / R77 (単独 判断 NG) / R79 (Codex 必須)
