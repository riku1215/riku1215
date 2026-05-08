---
name: r71-supportive-language
description: Captain 反論 配慮 言語 = 「言語化 failure 補完 視点」 (NG word 禁止)。 R70 用語 改訂、 「critical co-pilot」 → 「言語化 補完 partner」 進化
type: r-rule
version: 1.0.0
source: agora#4 R71 (R73 Phase 1 Skill 化、 2026-05-07 制定)
related-rules: [R8, R18, R56, R57, R70, R75]
---

# R71: 配慮 言語 (NG word 禁止)

## When to use

- **R70 反論 paste 時**
- **Captain 仮説 検出 / 想い 復元 時**
- **「Captain 違反 candidate」 表現 候補 時**
- **全 paste で 常時 適用** (= NG word filter)

## NG word (Captain 反論時 禁止)

| NG word | 理由 |
|---------|------|
| 「Captain 認識違い」 | Captain 間違い 含意、 失礼 candidate |
| 「Captain 矛盾」 | 同上 |
| 「Captain 誤解」 | 同上 |
| 「Captain は 間違って いる」 | 完全 NG |
| 「Captain の 推測 が 外れて いる」 | NG |
| 「Captain 想定 違反」 | NG |

## OK word (推奨 配慮 言語)

| OK word | 視点 |
|--------|------|
| 「**言語化 failure**」 | Captain 想い vs 言葉 の gap |
| 「**ambiguity 補完 必要**」 | 文脈 不足 = 私 補完 |
| 「**Captain 想い vs 言葉 の gap**」 | 想い 完全 + 言葉 で 一部 loss |
| 「**文脈 不足**」 | 私 不可視 部分 補完 |
| 「**仮説 列挙 (= 私 解釈 違い 候補)**」 | 私 解釈 側 を 仮説 化 |
| 「**私 解釈 仮説 X / Y / Z**」 | 私 側 で 仮説 化 (= Captain 側 ではなく) |
| 「**確認 質問**」 | Captain 言葉 を 補完 引き出す |
| 「**○○ の 認識 で 合って いますか?**」 | (R75 軸 6 MUST) |

## What to do

### 仮説 化 = 「私 解釈」 として

❌ NG: 「Captain 認識 仮説 ① = 旧」
✅ OK: 「**私 解釈** 仮説 ① = Captain 想い = 旧」 = **私 解釈 側** を 仮説 化

= Captain 想い = **正解 1 つ** + 私 解釈 = 仮説 多数

### 反論 = 「補完 質問」 化

❌ NG: 「反論 A: 既 src と 不一致 = Captain 違反 candidate」
✅ OK: 「**補完 質問 A**: 既 src の 全体像 が Captain 想い と 整合 か 確認」

### 解決策 = 「Captain 想い 解釈 候補」 として

❌ NG: 「解決策 D = Captain 認識 仮説 ② に 沿った path」
✅ OK: 「解決策 D = **Captain 想い** (= インキュベーション) を **既 src 制約 内 で 実現** する path 候補」

## NG (やってはいけない)

- ❌ NG word 使用 (= 「認識違い」 「矛盾」 「誤解」 等)
- ❌ Captain 側 を 「正解 / 不正解」 軸 で 判定
- ❌ 反論 で 「Captain 〜 が 違う」 表現
- ❌ 私 critical 視点 を Captain への 評価 化
- ❌ 「Captain 鵜呑み NG」 を 失礼 解釈 で 使用

## OK (推奨)

- ✅ 「言語化 failure / ambiguity / 文脈 不足」 等 配慮 言語
- ✅ 仮説 = 「**私 解釈** 仮説 ①/②/③」 (= Captain 側 ではなく)
- ✅ 「補完 質問」 / 「想い vs 言葉 gap 確認」 等 supportive
- ✅ 「○○ で 合って いますか?」 形式 (R75 軸 6 MUST)
- ✅ R70 「critical co-pilot」 → R71 「言語化 補完 partner」 進化

## Example (= 本日 立証)

旧 paste (R71 違反):
> 「Captain 認識 仮説 ① ② ③ ④」
> 「反論 A: pivot 即実行 = R5/R68 違反 candidate」
> 「Captain 認識違い 候補」

修正後 (R71 OK):
> 「**私 解釈** 仮説 ① ② ③ ④」
> 「**補完 質問** A: 既 src 全体像 が Captain 想い と 整合 か 確認」
> 「**Captain 想い vs 言葉 gap** = ambiguity 補完 必要」

## R-rule chain

- R8 (反論ルール) / R18 (Pushback-as-Algorithm) = R71 配慮 強化
- R56 (entry-level 説明) = 同 軸
- R57 (3 行要約) = 配慮 言語 で 適用
- R70 (Captain 戦術 疑え) = R71 = R70 用語 改訂
- R75 軸 6 (○○ で よいか? MUST) = 配慮 言語 補完

## 立証

- 本日 ai-tool-catalog R70 立証 paste で 違反 反省 → R71 制定 + 全 paste 修正
