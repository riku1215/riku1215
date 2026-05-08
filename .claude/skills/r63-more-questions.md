---
name: r63-more-questions
description: Captain への 質問 増やして 無駄 回避 (R15 拡張 = 全 task 強制 質問 mode)。 推測進行 NG = 質問先行 で 手戻り 防止
type: r-rule
version: 1.0.0
source: agora#4 R63 (R73 Phase 1 Skill 化、 2026-05-07 制定)
related-rules: [R8, R15, R18, R19, R44, R57, R59, R60, R64, R71]
---

# R63: Captain への 質問 増やせ (推測 NG)

## When to use

- **task 受領 直後** (= 全 場合)
- **新規 repo 作成 / scope 設定**
- **共同 PJ commit / 共同者 連絡 path**
- **doctrine / R-rule 制定**
- **Captain 多 message 流し込み 直後**

## What to do

### Q-密度 KPI (1 task 何 件 質問 すべき か)

| task 種別 | 推奨 質問 数 | timing |
|----------|-----------|-------|
| 新規 repo 作成 | 5-8 件 | 命名 / Tier / timing / tech / monetization |
| 既存 PJ Phase 進展 | 3-5 件 | scope / verify / commit 範囲 |
| 共同 PJ commit | 3-5 件 | 共同者 連絡 / 認可 範囲 |
| doctrine / R-rule | 2-3 件 | scope / 28 repo 横展開 |
| bug fix / refactor | 1-2 件 | scope / verify path |
| typo / 1 行 fix | 0 件 | 既認可 範囲 |

### 質問 format (R64 番号一意性 + R71 配慮 言語)

```
## 即/朝 確認 質問 list (★ ranking)

### task A 関連 (★★★★★ 即必要)
1. <質問> = a. <候補A> / b. <候補B> / c. <候補C>
2. ...

### task A 関連 (★★★ 後で OK)
3. ...

GO format: 「1=a」 「1-3 全 yes」 等
```

### 質問 種別 (R59 不確定 領域 全 cover)

1. scope 確認
2. 既存 source location (R5 + R68)
3. 共同者 / 連絡 path
4. 命名 / Tier 配置
5. timing
6. verify path (R34)
7. monetization / cost (R13)
8. 横展開 (28 repo)

### R71 配慮 言語 適用

- 「○○ の 認識 で 合って いますか？」 形式 多用
- 「私 解釈 = X」 提示 で Captain 1 click 確認
- NG word (「認識違い」) 禁止

## NG (やってはいけない)

- ❌ 推測進行 (= 「たぶん こうだろう」 で commit)
- ❌ 質問 0 件 で 大規模 task 着手
- ❌ 質問 全 「★★★★★ 即必要」 化 (= 認知負荷 ↑)
- ❌ Captain 寝てる時 (24-6 時) に 質問 投げる (= R44/R61 違反)
- ❌ 「既知」 「自明」 で skip (= R8 反論 推奨)

## OK (推奨)

- ✅ task 受領直後 = R59 初期判断 + R63 質問 list セット
- ✅ ★ ranking で priority 区別
- ✅ 推測 候補 a/b/c 提示 = Captain 1-click 回答
- ✅ 24-6 時 = 質問 docs/ 蓄積 → 朝 まとめ paste (R61)
- ✅ Captain 短答 mapping 表 (R64) と セット

## Example (= 本日 立証)

朝 GO 8 件 (a-h) → R64 で ① -⑧ rename + 副系 質問 5 件:
1. 24h plan = 5 件 OK? = a/b/c
2. 48h plan = 4 件 OK? = a/b/c
3. 72h plan = 3 件 OK? = a/b/c
4. 優先 入れ替え?
5. Captain 1 day 作業時間 = a. 4h / b. 6h / c. 8h

→ Captain 「1-3 ok」 1-click 回答 = plan 確定

## R-rule chain

- R8 (反論ルール) / R15 (事前質問) = R63 拡張版
- R18 (Pushback-as-Algorithm) = autonomous
- R19 (前提を疑え) = R63 = 前提 質問 化
- R57 (3 行要約) = 質問 list 添付
- R59 (戦術 critical) = 不確定 = 質問
- R64 (番号一意性) = 副系 質問 番号
- R71 (配慮 言語) = 「○○ で 合って いますか？」
