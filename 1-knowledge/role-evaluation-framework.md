---
tags: [role, evaluation, agent, framework, chatgpt-r88, captain-portal]
layer: knowledge
audience: [captain-only, claude]
status: active
source: ChatGPT Role + Harness 設計回答 (2026-05-11)
---

# Role 評価フレームワーク — 5 評価軸 + 永続化先 + Harness 7 責務

`#role #evaluation #5-axis #persistence-first #harness`

> ChatGPT 2026-05-11 回答由来。
> Role は作って終わりではなく**評価対象**。出力品質を 5 軸で測定し、永続化先 7 種に紐付ける。

## 0. ChatGPT 提唱 Harness 7 責務

1. **Intent Router** — bugfix / feature / review / refactor / doc / architecture 判定
2. **Role Selector** — architect / implementer / reviewer / curator 選定
3. **Context Builder** — Role 別 priority sources から context 構築
4. **Tool Policy** — Role × Tool × risk × approval matrix
5. **Output Contract** — 出力形式固定
6. **Verification Runner** — test / lint / smoke / rollback
7. **Feedback Logger** — Issue / R-rule / feedback.sqlite3 / KB

## 1. 5 評価軸 (各 agent 出力測定)

| # | 軸 | 定義 | 測定 |
|---|-----|------|------|
| 1 | **Precision** | 余計なことを言わないか | feedback「不要」率 |
| 2 | **Recall** | 重要リスクを見逃さないか | 後追い検証「漏れ」率 |
| 3 | **Actionability** | 次の行動に落ちるか | commands 即実行可率 |
| 4 | **Consistency** | 毎回同じ基準で判断 | 同種 input 出力ばらつき |
| 5 | **Reusability** | Issue/R-rule/Skill 転記可能 | **最重要、永続化 success 率** |

## 2. 永続化先 7 種

| # | 永続化先 | 何を入れるか | パス |
|---|--------|------------|------|
| 1 | Issue | 議論・タスク・war-story | GitHub Issue (R66) |
| 2 | R-rule | doctrine 候補 | agora#X / r-rules-index.md |
| 3 | Skill | 再利用 pattern | ~/.agents/skills/ |
| 4 | ADR | 設計判断 | docs/adr/ |
| 5 | KB chunk | 永続データ | ~/.kb/ + ChromaDB |
| 6 | test_case | テストパターン | test/ |
| 7 | checklist | 再利用 checklist | 3-rules/ |

## 3. Harness Level モデル (agoora 現状 Level 3)

| Level | 設計 | agoora |
|-------|------|--------|
| 0 | 手動プロンプト | (脱却済) |
| 1 | Role prompt | (脱却済) |
| 2 | Role + Output Contract | (脱却済、agents.yml output_format) |
| **3** | **Role + Retrieval + Tool Policy** | **✓ 達成 (本 commit で完成)** |
| 4 | Feedback-driven | 未達 (feedback.sqlite3 role/accepted カラム待ち) |
| 5 | Specialist model / re-ranker | Phase G 候補 |

## 4. 関連

- `4-portal/agent_profiles.yaml` (本 commit、placeholder 修復中)
- `4-portal/tool_policy.yaml` (本 commit、Tool risk + permissions)
- `4-portal/context_policy.yaml` (本 commit、Role context selection)
- `4-portal/prompts/*.md`
- ChatGPT 2026-05-11 Role + Harness 設計回答

`#role-evaluation #5-axis #persistence-first #harness-level-3`
