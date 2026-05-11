---
tags: [r10, batched-authorization, template, captain-portal, r-rules]
layer: foundation
audience: [claude, all-llms]
status: active
---

# R10 Batched Authorization テンプレート

`#r10 #batched-authorization #template`

> 提案を**一括承認形式**で Captain に提示するルール。
> 個別承認の繰り返しを避け、Captain の時間を奪わない (R5 強化)。

## 基本形 (yes/no 表)

```markdown
## R10 一括承認

| # | 項目 | yes/no |
|---|------|--------|
| 1 | <タスク 1 名> | ? |
| 2 | <タスク 2 名> | ? |
| 3 | <タスク 3 名> | ? |

→ `yes` (推奨) なら GO、`a/b/c` で部分採用、修正点あれば指摘。
```

## 拡張形 (Stop conditions 込、自走時)

```markdown
## R10 一括承認 + R20 5-min Auto-execute

### 実行タスク
1. <タスク 1>
2. <タスク 2>
3. <タスク 3>

### Stop Conditions (R20 + agora R20)
- 同種エラー 3 回連続 → 停止 + 報告
- ファイル削除/破壊リスク → 停止 + 承認待ち
- token budget > <N> → 停止
- scope 外操作 → スキップ + 後続継続

### 期待成果
- <成果 1>
- <成果 2>

### 期待時間
<推定 ?h>

→ `GO` なら自動実行、5 分以内反応なければ R20 で auto-execute。
```

## Captain 反応パターン

| Captain 入力 | 意味 |
|-------------|------|
| `yes` / `GO` / `AII GO` | 全部承認、即実行 |
| `a` / `1` / `Aから順次` | 順次実行、各 step 後報告 |
| `a&c` | 1 と 3 のみ実行 |
| `(b)` で / `2 以外` | 否定指定、それ以外を実行 |
| `?` (空欄や疑問符のみ) | 説明不足、再提案要求 |
| `何でもよい` | Claude 判断、推奨案で進む |
| `ちょっと待って` | 停止 + 待機 |

## R10 違反パターン (NG 例)

❌ 個別承認の繰り返し:
> 「A をやっていいですか?」「B をやっていいですか?」「C をやっていいですか?」

✓ R10 準拠:
> 「A/B/C を以下の順で実施します。yes/no?」

❌ 質問だけで候補なし (R81 違反も同時):
> 「どうしますか?」

✓ R10 + R81 準拠:
> 「以下 3 案から選んでください: A ★★★★★ / B ★★★ / C ★★」

## R10 + Stop Conditions の運用例 (本 6h 自走時に適用)

```markdown
## R10 6h 自走計画

### タスク 10 件
1. agora#4 fetch + R-rules 抽出
2. agents.yml 拡張
3. portal-config.yml 拡張
4. 1 Issue 起点自動リレー PoC
5. portal-init.ps1 per-domain CLAUDE.md
6. build-indexes.ps1 closed issues
7. Tree-sitter PoC
8. agoora-docker setup
9. CI/CD lint workflow
10. PR #19 整理 + 自走レポート

### Stop Conditions
- 同種エラー 3 回 → 停止
- agora#4 fetch 失敗 → 停止
- ファイル破壊リスク → 停止
- commit 20 超 → consolidate
- scope 外 → skip + continue

### 期待時間
6h 相当 (1 turn 内で集中実行)

→ Captain GO 確認後即着手。
```

## 関連

- [agora#4 R10 原典](https://github.com/riku1215/agora/issues/4)
- [agora#82 D-D Autonomy & Planning Doctrine](https://github.com/riku1215/agora/issues/82)
- `3-rules/r-rules-index.md`
- `3-rules/R9-checklist-template.md`
- `4-portal/protocol.md` §6 運用例

`#r10 #batched-authorization #stop-conditions #r20`
