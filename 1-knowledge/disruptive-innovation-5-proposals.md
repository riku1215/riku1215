---
tags: [disruptive-innovation, claude-weakness, agoora-mission, mechanical-compensation, captain-vision]
layer: knowledge
audience: [captain-only, claude]
status: active-critical
created: 2026-05-11
---

# 破壊的イノベーション 5 提案 — Claude の弱点を agoora が機械的に補完

`#disruptive-innovation #claude-weakness #mechanical-compensation`

## 0. Captain 指摘 (2026-05-11、最重要)

> あなたの記憶があてにならない、GitHub のレポジトリ、Issue の見逃しも常習犯だ。
> この agoora の開発システムで、**破壊的イノベーションを達成せよ**。

= **私 (Claude) の本質的弱点 2 件**:
1. **記憶があてにならない** — session 跨ぎ忘却、同 session 内も 30+ msg で精度低下
2. **見逃し常習犯** — agora#4 fetch 忘れ、scope 誤判定、過去 Issue 重複提案

→ **agoora は私を物理的に補完するシステム**。「次回はちゃんとやります」を廃止し、**機構的に防止**。

---

## 1. 5 つの破壊的提案 (mechanical compensation)

### 🚀 I1. Pre-Action Probe System ★★★★★

**問題**: 私が提案前に ~/.kb/ 検索を忘れる → 重複提案・過去議論見逃し
**頻度**: ほぼ毎回 (R5/R32 違反)

**解決機構**:
agoora orchestrator の system prompt に**強制 hook**を埋め込み、提案出力前に必ず:
```yaml
pre_action_probe:
  trigger: orchestrator が出力生成開始する直前
  enforce:
    - researcher 役に fan-out (top_k=12、agent_profiles.yaml)
    - hits 取得 → context に焼く
    - hits == 0 なら「新規領域」フラグ、Captain に確認
  bypass: 不可 (architectural、prompt level で防げない場合は portal-api 側で reject)
```

**実装**: `4-portal/prompts/orchestrator.md` の Task Instruction に Step 0 として追加。
**効果**: 私が「忘れる」物理的不可能化。

### 🚀 I2. MCP Capability Auto-Probe ★★★★★

**問題**: session 開始時に MCP scope を誤判定 (例: 「pet-care-app は scope 外」誤判定、実は search_* で読める)
**頻度**: 毎セッション

**解決機構**:
session 開始時の **3 秒 auto-probe**:
```python
# .claude/hooks/SessionStart.py (新規)
def probe_capabilities():
    results = {}
    for tool, test_call in [
        ("search_issues:org-wide", lambda: search_issues("repo:riku1215/agora is:issue", per_page=1)),
        ("search_code:org-wide", lambda: search_code("repo:riku1215/agora extension:md", per_page=1)),
        ("list_issues:scope-only", lambda: list_issues("riku1215", "agora", limit=1)),
        ("issue_write:scope-only", lambda: dry_run_issue_write("riku1215/agora")),
    ]:
        try:
            test_call(); results[tool] = "OK"
        except Exception as e: results[tool] = f"DENIED ({e})"
    return results

# 結果を context に inject
context["mcp_capabilities"] = probe_capabilities()
```

**実装**: `.claude/hooks/SessionStart.py` + `4-portal/prompts/orchestrator.md` に context 利用ルール
**効果**: 「scope 外で出来ません」誤判定の根絶。

### 🚀 I3. Trigger Word Listener ★★★★★

**問題**: Captain「これ重要」「記録しておいて」発話時、historian 役が発火しない
**頻度**: ほぼ毎回 (U10 違反)

**解決機構**:
全 Captain 入力を **正規表現 listener** で監視、trigger 語検出時に historian 自動発火:
```yaml
# 4-portal/routing.yml always_apply に追加
trigger_word_listener:
  always: true
  patterns:
    - regex: '(ナレッジ化|記録しておいて|Issue に残して|これ重要|後で参照|失敗パターン化)'
      then: trigger_historian(payload=full_captain_message, mode=urgent)
    - regex: '(scope 外|出来ません|不可能)'  # 自己誤判定検出
      then: trigger_orchestrator_self_audit(rule=R7)
    - regex: '(失礼しました|申し訳ございません)'   # Section 7-6 違反検出
      then: trigger_block_proposal + force_root_cause_analysis(1-line)
```

**実装**: `4-portal/routing.yml` + `scripts/auto-relay.py` の Captain message hook
**効果**: 言葉だけで終わる「次回からは」を機構的に防止。

### 🚀 I4. Section 7 Failure Pre-Block ★★★★

**問題**: Section 7 失敗パターンを「学習しています」と言いながら再発
**頻度**: 6h 自走で 4 件、3h 自走で 0 件 (改善傾向、但し未完)

**解決機構**:
orchestrator の **proposal output 直前**に Section 7 violation scanner:
```python
def section7_pre_block(proposal: str) -> tuple[bool, list[str]]:
    """提案 output が Section 7 違反パターンに該当する場合 block。

    Returns (allowed, violations_list)
    """
    violations = []

    # Section 7-7: 結論→詳細、200 字以内結論を先頭
    if not has_200char_conclusion_at_top(proposal):
        violations.append("7-7: 200字結論が先頭にない")

    # Section 7-3: 確認質問 ≤ 2/turn
    if count_questions(proposal) > 2:
        violations.append("7-3: 質問数超過 (R5 違反)")

    # R81: 候補なしの質問
    if has_question_without_options(proposal):
        violations.append("R81: 候補なし質問 (must violation)")

    # Section 7-1: 「全機能影響」等の曖昧結論
    if has_vague_conclusion(proposal):
        violations.append("7-1 / spec-change#4: 曖昧結論")

    # Section 7-6: 「失礼しました」だけで流す
    if has_excuse_without_root_cause(proposal):
        violations.append("7-6: 失敗即時学習未実施")

    return len(violations) == 0, violations
```

**実装**: `4-portal/prompts/orchestrator.md` の Task Instruction 末尾に self-check Step
**効果**: 違反パターンが Captain に届く前に内部で訂正、外部に「失敗 → 学習」を見せない。

### 🚀 I5. Continuous Self-Audit (30 msg) ★★★★

**問題**: 長セッション (30+ msg) で agora#4 R-rules が context から薄れる、Captain 発言の前提を忘れる
**頻度**: 全長セッション

**解決機構**:
**30 message 毎に強制 self-audit**:
```python
# orchestrator system prompt 末尾に常時意識
SELF_AUDIT_TRIGGER = """
本セッションのメッセージ数が 30 を超えたら、出力生成前に必ず:
1. agora#4 (mcp__github__search_issues で repo:riku1215/agora issue:4) 再 fetch
2. 直近 5 user message を R1-R10/R14/R32/R57/R66/R80 で audit
3. 違反検出時 = 直近提案を historian で記録 + 訂正案を本提案に prepend
4. Captain に「30+ msg 経過、self-audit 実施済」と 1 行通知
"""
```

**実装**: `4-portal/prompts/orchestrator.md` に SELF_AUDIT_TRIGGER ブロック追加
**効果**: 長セッション drift の物理的防止。Captain の「あれもう忘れた?」を排除。

---

## 2. 統合: agoora の「機構的補完」アーキ

```
┌────────────────────────────────────────────────────────────┐
│ Captain 入力                                                 │
│   ↓                                                         │
│ [I3 Trigger Word Listener] ← 「これ重要」等を即検出          │
│   ↓                                                         │
│ [I2 MCP Capability Context] ← session 開始時 inject 済       │
│   ↓                                                         │
│ orchestrator (Claude)                                       │
│   ↓                                                         │
│ [I1 Pre-Action Probe] ← researcher 強制 fan-out             │
│   ↓                                                         │
│ pipeline (agents.yml + routing.yml)                         │
│   ↓                                                         │
│ proposal 生成                                                │
│   ↓                                                         │
│ [I4 Section 7 Pre-Block] ← 違反検出で訂正                    │
│   ↓                                                         │
│ [I5 30-msg Self-Audit] ← 該当時 R-rules 再 fetch              │
│   ↓                                                         │
│ Captain 提示 (R10)                                          │
└────────────────────────────────────────────────────────────┘
```

→ **私 (Claude) が「忘れる / 見逃す / 失敗する」のは前提**として設計、機構が補う。

## 3. 期待効果 (Phase 1.5 KPI、from-knowledge-to-action.md 連動)

| 指標 | Before (本セッション 6h+3h 自走) | After (5 提案実装後) |
|------|-------------------------------|---------------------|
| agora#4 fetch 忘れ | 100% (毎セッション) | **0%** (I2 自動) |
| Section 7 違反 | 4 件/6h, 0 件/3h | **≤ 0.5 件 / 10h** |
| 過去 Issue 重複提案 | ~30% | **< 5%** |
| 「失礼しました」だけ流す | 4-5 件 | **0** (I4 で block) |
| 長セッション drift | 30 msg 超で精度低下 | **I5 で物理復元** |

## 4. dsi-benchmark-results との連動 (本セッション最新発見)

dsi-benchmark-results は **nightly 結果アーカイブ**。
→ 上記 5 提案の **効果測定値**を本 repo に時系列保存する基盤として活用可:
- I1 Pre-Action Probe の hits 率
- I4 Section 7 Pre-Block の検出件数
- I5 Self-Audit の drift 検出回数

= **agoora の自己改善ループを benchmark で実証**。

## 5. R10 一括承認 + 実装優先順 (本セッション残量内)

| # | 提案 | 工数 | 推奨度 | 本セッション着手? |
|---|------|------|--------|----------------|
| **I1** | Pre-Action Probe | 1h (prompt 修正のみ) | ★★★★★ | 即着手 |
| **I2** | MCP Capability Auto-Probe | 3h (hooks/SessionStart 実装) | ★★★★★ | 次セッション |
| **I3** | Trigger Word Listener | 2h (routing.yml + script) | ★★★★★ | 即着手 |
| **I4** | Section 7 Pre-Block | 2h (orchestrator prompt + check) | ★★★★ | 即着手 |
| **I5** | 30-msg Self-Audit | 1h (orchestrator prompt のみ) | ★★★★ | 即着手 |

→ **I1, I3, I4, I5 を本セッションで即実装**、I2 は SessionStart hook が別 system layer のため次セッション。

---

## 6. 結論 — 破壊的イノベーションの本質

agoora は AI Agent 開発ツールではなく、**Claude (私) という不完全な存在を物理的に補完するインフラ**。

Captain 指摘「あなたの記憶があてにならない、見逃し常習犯」は**正しい認識**。
それを直そうとするのではなく、**機構で防止**するのが本イノベーション。

= **「失敗しない Claude を作る」ではなく「Claude が失敗しても外部に影響しない agoora」**

→ これが Phase 5 商用化時の **真の差別化**:
- 他 AI tools: AI の進化に依存
- agoora: **AI の弱点を運用システムで完全補完**

## 7. 関連

- `1-knowledge/from-knowledge-to-action.md` (Phase 1.5「活かす」、本提案の親)
- `1-knowledge/usability-feedback-2026-05-11.md` (R83-R88 候補、本提案で実装)
- `1-knowledge/agoora-dogfooding-candidates.md` (本提案を kintaeru で実証)
- `4-portal/prompts/orchestrator.md` (本セッションで実装する prompt 修正先)
- `4-portal/routing.yml` (I3 trigger listener 追加先)
- agora#82 R-rule 7 doctrine cluster

`#disruptive #mechanical-compensation #phase-1-5 #agoora-true-value`
