---
name: r57-3line-summary
description: 全 GO 待ち / Captain 提示 で 「3 行要約 (判断 / trade-off / 懸念)」 必須。 Captain 5 sec で 判断 起点 化、 1 cycle 30→25 min 短縮
type: r-rule
version: 1.0.0
source: agora#4 R57 (R73 Phase 1 Skill 化、 2026-05-07 制定)
related-rules: [R63, R64, R66, R67, R70, R71, R72]
---

# R57: 3 行要約 必須 (Captain 認知効率)

## When to use

- **全 GO 待ち 提示時** (= Captain 判断 必要 場面)
- **大 plan 起票 / 構造変更 提案**
- **複数 path 提示時** (= ★ ranking と セット)
- **commit + push 報告**
- **memory / R-rule 制定 報告**

## What to do (3 step)

```
## 3 行要約 (R57)
① 判断: <task は こう 進む / 私 解釈 = X>
② trade-off: <採用/不採用 で 何 が 変わる>
③ 懸念: <potential risk / 不確定要素>
```

= **3 行 以内** で 判断起点 + 影響 + risk を Captain 5 sec で 把握可能 化

## NG (やってはいけない)

- ❌ 4 行 以上 (= 認知ノイズ)
- ❌ 抽象的 (= 「進める」 「考える」 等 verbal noise)
- ❌ trade-off 抜け (= 採用 / 不採用 軸 必須)
- ❌ 懸念 抜け (= risk 隠蔽 NG)

## OK (推奨)

- ✅ 各行 1 文 / 数値 / 具体的
- ✅ 「① ② ③」 全角丸数字 で 番号付き (R64)
- ✅ ★ ranking と セット (= R17)
- ✅ 配慮 言語 (R71、 = 「私 解釈 = X」)

## Example

```
## 3 行要約 (R57)
① 判断: クラス chip 既担当 = オレンジ + 持ち時数 6 段階 (オーバー/多め/適正/少なめ/少ない/担当なし) 採用 (確信 85%)
② trade-off: 採用 → UX 直感化 + 5→6 段階 細分 / 不採用 → 曖昧 残存
③ 懸念: 6 段階 閾値 (適正=10-15) は 私 仮設定、 Captain 修正 候補
```

## R-rule chain

- R63 (質問 増やせ) と セット = 3 行 後 に 確認 質問
- R64 (番号一意性) = 「①②③」 主系
- R66 (md→Issue paste) = 全 paste で 適用
- R67 (Chrome 可視化) = comment paste で 適用
- R70 (Captain 戦術 疑え) = 反論 paste で 適用
- R71 (配慮 言語) = OK word 適用
- R72 (ゆっくり mode) = paste 質重視

## 立証

- ClassWeaver issue #197 (本 R-rule 制定 source)
- Captain Driven Iteration model = 30 min cycle で 1 サイクル 内 3-5 回 適用
