---
name: r55-all-llm-mandatory
description: ざっくり 実装 段階 でも 全 LLM (ChatGPT + Codex + Gemini) 活用 必須。 後 手戻り 削減 + 修正 依頼時 経緯把握 で ベスト 回答 期待値 上昇
type: r-rule
version: 1.0.0
source: agora#4 R55 (R73 Phase 2.1 Skill 化、 2026-05-07 制定)
related-rules: [R45, R45-v2, R47, R50, R59, R74, R77]
---

# R55: 全 LLM (ChatGPT + Codex + Gemini) 必須

## When to use

- **ざっくり 実装** (rough first iteration) 段階
- **詳細 設計 / commit + push 段階**
- **silent bug / regression 調査**
- **大規模 refactor / breaking change**
- **新規 repo 設計**

= ★全 段階 で 適用★ (= 「後 で」 「Phase B で」 等 skip NG)

## What to do

### 4 LLM 並列 review pipeline (R45 v2 fluid persona)

```
Plan 作成 (Claude)
    ↓
3 LLM 並列 dispatch:
- Codex (engineer persona): 即実装 + critical review
- Gemini (designer/中堅 persona): UX + 色覚多様性 + pre-check
- ChatGPT API (CTO persona): 設計 + 営業 + 技術負債
    ↓
全 verdict 統合 (Claude COO)
    ↓
Captain 提示 + GO + commit + push
```

### dispatch 簡素化

| LLM | dispatch 方法 |
|-----|-------------|
| Codex | `codex exec --sandbox read-only "<prompt>" < /dev/null` |
| ChatGPT API | `python scripts/dispatch_<task>.py` (gpt-4o or gpt-4o-mini) |
| Gemini | `python scripts/dispatch_gemini.py` (gemini-2.0-flash-exp) |

### R45 v2 fluid persona 適用

各 dispatch system prompt = task 起点 で persona swap:
- silent bug = Codex 探偵 + Gemini 監査 + ChatGPT DevOps
- UX 設計 = Gemini designer + Codex frontend eng + ChatGPT PM
- 営業 戦略 = ChatGPT 営業 VP + Codex 価格 calc + Gemini LP designer
- ... (= R45 v2 mapping 表 参照)

## NG (やってはいけない)

- ❌ 「ChatGPT は Phase B で 後 回し」 (= R55 違反、 本日 反省 source)
- ❌ Codex のみ で 完了
- ❌ Gemini のみ で 完了
- ❌ 「自明」 「small fix」 で skip

## OK (推奨)

- ✅ ざっくり 実装 でも 4 LLM 並列 必須
- ✅ R45 v2 persona swap で 質 ↑
- ✅ dispatch script template 化 (= R73 Phase 1 連動)
- ✅ R74 (= GitHub Blog / Conference) と セット = 外向き 知見 補完

## Example (= 本日 立証)

silent bug 完全解消 (issue #196):
- Codex (探偵): CSP 'unsafe-eval' 欠落 検出
- Gemini (監査): bind mount 案 v1 棄却 (= 重大欠陥 3 件 検出)
- ChatGPT (DevOps): A1 (--no-cache + R48 verify) 推奨
- Claude (統合): 4 LLM verdict で commit + push + R49 立証

= R55 立証 = 4 LLM = 単 LLM では 不可能 だった

## R-rule chain

- R45 (役割分担) → R45 v2 (fluid persona) で 強化
- R47 (外部 LLM 生成 = Codex review 必須)
- R50 (Gemini pre-check 必須)
- R59 (鵜呑み NG = 戦術 critical) = 不確定 = 多 LLM dispatch
- R74 (GitHub Blog / Conference sweep) = 外向き 補完
- R77 (私 単独 判断 NG) = 不確定 case で R55 強制

## 立証

- ClassWeaver issue #197 (= 「ChatGPT skip 反省」 = R55 制定 source)
- 本日 24h+ で ChatGPT API 5 dispatch + Codex 1 + Gemini 多数 = 立証 完了
