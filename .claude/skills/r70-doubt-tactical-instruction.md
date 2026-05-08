---
name: r70-doubt-tactical-instruction
description: Captain 戦術 指示 を 疑え + 反論 + 解決策 提示 必須 (= R8/R18/R19 強制適用、 R60 vision 鵜呑み と 区別)
type: r-rule
version: 1.0.0
source: agora#4 R70 (R73 Phase 1 Skill 化、 2026-05-07 制定)
related-rules: [R8, R18, R19, R59, R60, R63, R71]
---

# R70: Captain 戦術 指示 を 疑え + 反論 + 解決策

## When to use

- **Captain 戦術 指示 受領 直後** (= vision ではなく 戦術 = R60 と 区別)
- **新規 repo / scope 変更 / 機能 提案 受領**
- **destructive 操作 受領 (= 削除 / archive / migration)**
- **不一致 / 違和感 / ambiguity 検出 時**

### R60 vs R70 区別

| 指示 種別 | 例 | 適用 |
|---------|-----|-----|
| **vision** | 「埋め尽くす」 等 | R60 = **鵜呑み 必須**、 R70 適用 NG |
| **戦術** | 「ai-tool-catalog インキュベーション」 等 | **R70 適用 = 疑え + 反論 + 解決策** |
| **小 fix** | typo / 1 行 | R70 適用 不要 (= 即実装) |
| **destructive** | delete / archive | R70 + R59 セット = 慎重 |

## What to do (4 step)

### Step 1: 「疑え」 = 私 解釈 仮説 列挙 (R71 配慮 言語)

Captain 戦術 指示 に 不一致 / 違和感 検出 時:

```
## 私 解釈 仮説 (= 軸 1 文脈、 R76)
仮説 ① (★ 確度) = <Captain 想い 解釈 A> + <証拠>
仮説 ② (★ 確度) = <Captain 想い 解釈 B> + <証拠>
仮説 ③ (★ 確度) = <Captain 想い 解釈 C>
```

### Step 2: 「補完 質問」 = critical 視点 (R71 配慮 言語)

「反論」 ではなく **「補完 質問 / ambiguity 検出」** view:

❌ NG: 「反論 A: 既 src と 不一致 = Captain 違反」 (= R71 NG word)
✅ OK: 「補完 質問 A: 既 src の 全体像 が Captain 想い と 整合 か 確認」

### Step 3: 「解決策」 = 1-3 案 ★ ranking

```
## 解決策 ★ ranking
解決策 A (★★★★★ 推奨) = <内容> + pros + cons + 該当 仮説
解決策 B (★★★) = ...
解決策 C (★★) = ...
```

### Step 4: Captain 1-click 確認 (R75 軸 6 MUST)

「○○ の 後 で よいか?」 形式 確認:

```
| 入力 | 解釈 |
|-----|------|
| `<short>=A` | 解決策 A 採用 |
| `<short>=B` | 解決策 B 採用 |
| `<short>=other` | 自由記述 |
```

## NG (やってはいけない)

- ❌ Captain 戦術 指示 を そのまま 鵜呑み 形式 選択肢 化
- ❌ 私 critical 視点 0 で Captain 質問 のみ
- ❌ 解決策 提示 0 で Captain 判断 委譲
- ❌ R71 NG word 使用 (= 「Captain 認識違い」 「矛盾」 「誤解」)
- ❌ vision レベル に R70 適用 (= R60 違反)

## OK (推奨)

- ✅ Captain 戦術 受領 直後 = R70 4 step
- ✅ 私 critical 視点 (= 失礼 ではなく、 役割 = critical co-pilot)
- ✅ 解決策 1-3 案 ★ ranking
- ✅ R75 軸 6 + R76 5 軸 で 質問 構造化
- ✅ R71 配慮 言語 (= 「私 解釈 仮説」 「補完 質問」)

## Example (= 本日 立証)

Captain 直 「ai-tool-catalog → インキュベーション」 受領:

```
## 私 解釈 仮説 (4 軸)
① 旧 = 当初 インキュベーション 想定 (★★★)
② 新 = 今後 方針、 README pivot 必要 (★★★★★)
③ hybrid (★★)
④ 別 repo (★ 矛盾)

## 補完 質問
A: pivot 即実行 = R5/R68 違反 candidate (= 既存 asset ロス)
B: hybrid = scope 拡散

## 解決策 ★ ranking
A (★★★★★) = 段階 pivot (= 既存 asset 維持)
B (★★★) = 完全 pivot
C (★★) = 別 repo (= 矛盾)

## Captain 1-click
`tool-cat=A/B/C/other`
```

→ Captain 「A」 = 段階 pivot 確定 + 即着手 path

## R-rule chain

- R8 (反論ルール) / R18 (Pushback-as-Algorithm) = R70 ベース
- R19 (前提を疑え) = 仮説 列挙 source
- R59 (鵜呑み NG = 戦術 critical) = R70 強化
- R60 (vision = Captain 専管) = 区別 = vision 鵜呑み / 戦術 critical
- R63 (質問 増やす) = 仮説 + 解決策 + 確認
- R71 (配慮 言語) = NG word 禁止
- R75 軸 6 + R76 = 「○○ で よいか?」 + 5 軸 質問 統合

## 立証

- 本日 ai-tool-catalog scope pivot 立証 + Captain 「A」 1-click GO
