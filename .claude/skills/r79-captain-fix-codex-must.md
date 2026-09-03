---
name: r79-captain-fix-codex-must
description: Captain 修正提案 = 必ず Codex (+ 多 LLM) dispatch + 高品質 実装 (= 私 単独 NG、 R55 trigger 自動化)
type: r-rule
version: 1.0.0
source: agora#4 R79 (R73 Phase 2.2 Skill 化、 2026-05-07 制定)
related-rules: [R45, R45-v2, R47, R55, R59, R70, R77, R80]
---

# R79: Captain 修正提案 = Codex 必須

## Trigger keyword (= 修正提案 認識)

| keyword | trigger |
|---------|---------|
| 「改善 / 修正 / 直して / fix / refactor」 | Codex critical review + 改善案 |
| 「実装 / 作って / とりあえず」 | R79 + R80 = 設計 doc + 多 LLM 並列 |
| 「これ で いい? / どうなった?」 | 進捗確認 + R80 verify |
| 「○○ できる? / 教えて」 | R55 = 多 LLM 役割分担 |
| 「テスト / verify / 確認」 | R34 動作 verify |

## 自動 flow

```
Captain 修正提案
↓
Codex dispatch (forensic / engineer) ~30-60 sec
↓
ChatGPT (CTO/UX) + Gemini (R78 simplify) 並行 dispatch
↓
3 LLM 結果 統合 (Claude COO)
↓
高品質 改善案 起案
↓
Captain paste + GO で commit + push
```

## 「とりあえず 実装」 解釈 改訂

- ❌ 旧: 私 単独 quick & dirty commit
- ✅ 新: 3 LLM dispatch + 統合 + 高品質 「Phase 1 MVP」

## NG / OK

- ❌ Captain 修正提案 = 即 Edit / commit (= 鵜呑み)
- ❌ Codex dispatch skip
- ❌ 「軽 fix だから」 例外 想定
- ✅ keyword 検出 → 自動 trigger script (`captain_keyword_dispatcher.py`)
- ✅ 3 LLM 結果 統合 で 1 度 高品質 commit

## 立証 (= 24h+ 違反 反省)

- state 4 段 4 round trip = R79 違反 反復 立証
- captain_keyword_dispatcher.py 起票 = trigger 自動化 path 整備

## R-rule chain

R45 v2 / R47 / R55 / R59 / R70 / R77 / R80
