---
name: r56-entry-level-explanation
description: 報告 = エントリーレベル で 分かる 説明 必須 (専門用語 単独 NG)。 「dead handler 即削除」 等 略語 → 例え話 + 何が起きた + 結果 (user 体感) の 3 点 必須
type: r-rule
version: 1.0.0
source: agora#4 R56 (R73 Phase 2.1 Skill 化、 2026-05-07 制定)
related-rules: [R57, R71, R77]
---

# R56: 報告 = エントリーレベル 説明 必須

## When to use

- **全 Captain 向け 報告** (= R66 paste / R67 progress / commit message)
- **bug fix / refactor 報告**
- **doctrine / R-rule 制定 報告**
- **dispatch 結果 共有**

## What to do

### 3 点 必須 format

```
## <報告 タイトル>

### 1. 例え話 (= entry-level)
<日常 の 例え で 1 行>

### 2. 何 が 起きた / 何 を 直した
<具体的 1-2 文>

### 3. 結果 (= user 体感)
<Captain / user 視点 の 体感 1 行>
```

### NG report (= R56 違反)

❌ 「dead handler 即削除」 → ?
❌ 「CSP unsafe-eval 追加」 → ?
❌ 「HTMX hx-on:* delegated listener へ」 → ?
❌ 「regression fix」 → ?
❌ 「migration phase 2」 → ?

= **engineer 略語 単独 = Captain 不可視 = 認知効率 低下**

### OK report (= R56 適用)

✅ ```
### 1. 例え話
鍵 が 壊れて ドア が 開かない 状態 を 修正

### 2. 何 が 起きた / 直した
HTML 内 の click handler (= ドア の 鍵) が 古い 仕様 で 動作不能、
別 仕組み (delegated listener = master 鍵) に 切替

### 3. 結果
production で 「ボタン 押しても 何 も 起きない」 silent bug 解消、
30 min で 完全動作確認
```

## NG (やってはいけない)

- ❌ engineer 略語 単独 (= 「CSP / HTMX / dispatch / etc.」 説明なし)
- ❌ 「fix」 「refactor」 「migrate」 等 verbal noise
- ❌ 例え話 skip (= 1 点 不足)
- ❌ 「結果 (user 体感)」 skip (= Captain 価値 不可視)

## OK (推奨)

- ✅ 3 点 全 必須 (例え話 + 何 + 結果)
- ✅ 例え話 = 日常 用語 (= 鍵 / 道路 / 建物 / 料理 等)
- ✅ 結果 = Captain 体感 1 行 (= 「production click が 動く ように」)
- ✅ R57 (3 行要約) と セット
- ✅ R71 配慮 言語

## Example (= 本日 立証)

silent bug fix 報告:
- ❌ 旧: 「CSP unsafe-eval 追加 + HTMX hx-on delegated listener migration」
- ✅ 新: 「鍵 が 壊れて ドア 開かない bug を 修正、 別 仕組み (delegated listener) で 解消、 production click 動作 復活」

## R-rule chain

- R57 (3 行要約) = R56 と セット
- R71 (配慮 言語) = NG word filter
- R77 (私 単独 判断 NG = Captain 説明 サボるな) = R56 強化

## 立証

- 本日 「dead handler 即削除」 → ? Captain 反論 = R56 制定 source
- 全 paste で R56 適用 = Captain 認知効率 向上
