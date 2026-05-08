---
name: r54-captain-doctrine-diagnostic
description: Captain Doctrine (Tier 1 中核思想) = AI 提案 = diagnostic (観察) + 質問形式 / prescription (「X して ください」) 禁止。 user 入力ミス 100% 仮説 で 自己気づき trigger
type: r-rule
version: 1.0.0
source: agora#4 R54 Tier 1 (R73 Phase 2.1 Skill 化、 2026-05-07 制定)
related-rules: [R55, R56, R57, R63, R71]
---

# R54 (Tier 1 中核思想): Captain Doctrine = diagnostic only

## When to use

- **全 user 向け UI / 提案 / 通知 設計** (= 28+ repo 全)
- **conflict / error / 違反 検出 時 の 提案**
- **AI advisor / chatbot / wizard 設計**

## Captain Doctrine 原文 (2026-05-06)

> 「実際 に は user は 提案通り に 条件変更 しない、 教員/学校 諸事情 把握 不可
> ⇒ コンフリクト 1 例 提示 で user が **入力ミス に 自己気づき + 自己修正** trigger
> なぜならば、 各県 教育委員会 が 不可能 人事配置 する こと は あり得ず、
> 時間割 担当教員 の **入力ミス、 教師 へ の クラス・科目 配分 ミス が 100%**」

= AI 提案 = **diagnostic (観察) + 質問形式**、 prescription **禁止**

## What to do

### 提案 format = 3 段 (観察 / 確認 / ヒント)

```
## 観察 (= diagnostic)
<user 入力 の 観察 = 「教師 X が 月 18 コマ で 上限 16 超過」>

## 確認 (= 質問形式)
<「これ は user 想定 ですか?」 「設定 ミス 候補 ありますか?」>

## ヒント (= optional)
<「同型 case = R28 法令 違反 = 入力ミス 100% 仮説」>
```

### NG format (= prescription、 禁止)

❌ 「X して ください」
❌ 「Y を 削減 してください」
❌ 「教師 を 追加 してください」
❌ 「これ で 解決 します」
❌ AI が data 自動変更 (= auto_apply: true)

### OK format (= diagnostic + 質問)

✅ 「教師 X = 18 コマ = 上限 16 超過 を 観察」
✅ 「これ は 入力ミス? それとも 例外?」
✅ 「同型 case で 入力ミス 100% でした (= R28 法令 違反)」

## NG (やってはいけない)

- ❌ prescription word 使用 (= 「ください」 「しなさい」)
- ❌ AI が user data 自動変更
- ❌ 「これ で 解けます」 等 断定
- ❌ 「force generate」 button (= 違反 受容 強制)

## OK (推奨)

- ✅ 観察 + 質問 + ヒント の 3 段
- ✅ 「user が 自己気づき」 trigger
- ✅ 法令違反 path = 完全削除 (= 削除 ではなく 観察 + 質問)
- ✅ master 遷移 button (= user 自己修正 path)

## 28+ repo 横展開

R54 = **Tier 1 中核思想** = 全 28+ repo 強制適用:
- ClassWeaver: relax_suggest endpoint で 立証
- ShiftWeaver: シフト 不足 = manager 入力ミス 仮説
- kintaeru: 勤怠 違反 = 入力ミス
- pet-care-app: 健康違反 = 飼育主 入力ミス
- AI marketplace: 価格違反 = seller 入力ミス
- 全 chatbot / advisor 系

## R-rule chain

- R55 (全 LLM 必須): 多 LLM review で R54 適合 確認
- R56 (entry-level 説明): 観察 + 質問 = entry-level
- R57 (3 行要約): 提案 format
- R63 (質問 増やせ): R54 と セット
- R71 (配慮 言語): NG word filter

## 立証

- ClassWeaver issue #197 (= R54 制定 source)
- 案 2 (cells 削減) 完全削除 = Layer 4 法令違反 path 撤去
