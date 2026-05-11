---
tags: [r9, pre-action-checklist, template, captain-portal, r-rules]
layer: foundation
audience: [claude, all-llms]
status: active
---

# R9 Pre-action Checklist テンプレート

`#r9 #pre-action #checklist`

> orchestrator agent (Claude 主体) が **提案実装前に必ず通過**するチェックリスト。
> 失敗時は提案を出さず、再設計。

## チェック項目 (5 軸)

```yaml
# 提案テンプレ冒頭に貼付

pre_action_checklist:
  R1_numbered:
    description: 提案リストに番号付与済か
    pass: true | false
  R3_token_budget:
    description: 200 字結論を先頭に置いたか
    estimated_tokens: <number>
    pass: <≤ ~500 tokens for short proposals>
  R5_user_burden:
    description: Captain への質問は 2 件以下か
    questions_count: <number>
    pass: <≤ 2>
  R7_disclosure:
    description: 制約 (Claude ができない事項) を冒頭で開示済か
    constraints_disclosed: []
    pass: true | false
  R8_counter_argument:
    description: 反論余地を 1 件以上明示済か
    counter_args_count: <number>
    pass: <≥ 1>
```

## 全 pass しない場合

- 再設計 → 質問数を削減 / 反論追加 / 結論を冒頭に / 制約開示追記
- それでも pass しない → architect 役に R71 plan-first mode で再分析依頼

## R9 + 他 R との連動

| 連動先 R | 動作 |
|---------|------|
| R10 (Batched Auth) | R9 全 pass → R10 形式で Captain 提示 |
| R14 (多 LLM) | R8 反論を critic 別 LLM で生成 |
| R17 (★ ranking) | 提案候補に ★ 推奨度必須付与 |
| R19 (前提疑え) | R7 disclosure に前提リスト含める |
| R71 (plan-first) | 大規模変更時は R9 後 R71 plan 提示 |
| R76 (5 軸質問) | R5 質問は 5 軸構造化 |
| R81 (候補先付) | 質問前に候補リスト提示必須 |

## 提案例 (R9 通過済)

```
## 結論 (200 字)
A 案 ★★★★★ 推奨。理由は B/C より工数半分かつ R8 反論なし。

## 制約 (R7 開示)
- 本セッション scope: riku1215/riku1215 のみ
- agoora repo への直接 write 不可
- Docker daemon 未起動

## 提案 3 案 (R1 番号 + R17 ★)
1. A 案 ★★★★★ (推奨): ...
2. B 案 ★★★ : ...
3. C 案 ★★ : ...

## 反論余地 (R8)
- A 案でも X リスクあり
- B 案を選ぶなら Y も検討推奨

## Captain への質問 (R5 ≤ 2)
1. A 案でよいか
2. (省略可) Y を併用するか
```

## Audit (定期点検)

毎 30 メッセージごとに直近提案を以下で監査:

- [ ] R1 番号付け漏れ
- [ ] R3 結論先頭崩れ (200 字超)
- [ ] R5 質問 3 件以上
- [ ] R7 制約後出し
- [ ] R8 反論なし

違反検出時 → 即訂正 + Section 7-6 (失敗即時学習) で根本原因 1 行明示。

## 関連

- [agora#4](https://github.com/riku1215/agora/issues/4) R9 原典
- `3-rules/r-rules-index.md`
- `3-rules/R10-batched-authorization-template.md`
- `4-portal/protocol.md` §3 各 agent の振舞い規約

`#r9 #pre-action #checklist #orchestrator`
