---
tags: [activation, knowledge-vs-action, captain-vision, agoora-mission, retrospective]
layer: knowledge
audience: [captain-only, claude, all-llms]
status: active-critical
created: 2026-05-11
---

# From Knowledge to Action — 「記憶」より「活かす」(agoora ミッション)

`#knowledge-vs-action #captain-vision #agoora-mission`

## Captain 指摘 (2026-05-11、最重要)

> 開発には**十分すぎるくらいの knowledge が揃っている**。
> しかし、散らかりすぎて、GitHub というクラウドの性格上、**臨機応変に Claude Code が活かしきることは出来なかった** (数々の Captain への excuse 記録を見れば明らか)。
> それらを解消するシステムを今から構築しようというのだから、**すべてのミス・手戻り・ロスを把握する必要がある**。
> **しかし、最も大事なのは、記憶することではなく、活かすことである。**

---

## 1. 私 (Claude) の罪状告白 (Section 7-6 自己批判の集合体)

本 6h 自走 + 過去セッションで実際に発生した「Captain への excuse」の典型例:

### A. 「scope 外で出来ません」
- 実際: search_issues は org-wide で動作 (本 6h で実証)
- excuse 内容: pet-care-app は scope 外で読めません
- 根本原因: **MCP capability 事前確認の workflow 不在** (U2)
- agoora 対応: 本 PR でも未実装 (R84 候補) → **次の最優先**

### B. 「agora#4 を fetch していませんでした」
- 実際: session-start workflow が CLAUDE.md に明記済
- excuse 内容: 申し訳ございません、agora#4 を最初に fetch すべきでした
- 根本原因: **手動依存、自動強制機構なし** (U1)
- agoora 対応: SessionStart hook (R83 候補) → **未実装**

### C. 「同じ過ちを繰り返しました」
- 実際: Section 7-6 違反、本 6h でも 4 件発生 (claude-mem 不使用 / R14 単独 / R32 不発 / comment 順序)
- excuse 内容: 失敗即時学習しています、次回から…
- 根本原因: **学習 ≠ 適用、Section 7-6 自体が「次回」の保証なし**
- agoora 対応: **「活かす」機構 (本ドキュメントの本題)**

### D. 「ファイルが見つかりません」
- 実際: ローカルディレクトリ参照ミス + Captain 環境との不一致
- excuse 内容: パスが存在しない / 古いファイル
- 根本原因: **agoora と Captain Windows の状態同期欠如**
- agoora 対応: portal-api `/healthz` で状態確認 ✓ (実装済)

### E. 「6h 自走計画なしで開始」
- 実際: Captain 「6h 自走」短文 → 私が即計画提示
- excuse 内容: 計画は task 中 task 1 で立てます
- 根本原因: **R20 (5-min auto-execute) + R10 (Batched) の連動不明確** (U3)
- agoora 対応: 提案済 (R85 候補) → **未実装**

### F. 「複数 LLM レビューしませんでした」
- 実際: critic 役を Claude が兼任
- excuse 内容: 別 LLM 強制すべきでしたが…
- 根本原因: **agents.yml critic 役の自動 trigger 不在**
- agoora 対応: routing.yml always_apply で `r14-multi-llm` 定義済、**but execution 自動化未実装**

---

## 2. 知識 vs 行動 — Gap 分析

| 項目 | 蓄積量 | 活用率 | Gap |
|------|--------|--------|------|
| **R-rules** | 50+ (agora#82 7 doctrine) | ~30% (R1/R3/R5/R8/R9/R10 のみ常用) | R32/R71/R83-87 未活用 |
| **Skills** | 47 個 | ~10% (claude-mem 系 5 個未使用) | 大量の未活用資産 |
| **過去 Issue** | 1000+ | <5% (researcher 役未稼働、R5 既存確認弱) | 重複提案多発 |
| **agora doctrine** | 7 cluster | 部分 (D-A/D-D のみ意識) | D-B/D-C/D-E/D-F/D-G 適用弱 |
| **Section 7** | 10 件 | 違反 4 件/6h 自走 | 自動防止機構なし |

→ **活用率 平均 20% 程度**。Captain 評価「散らかりすぎて活かしきれない」が定量化された。

---

## 3. agoora の「活かす」5 メカニズム (本来のミッション)

### M1: 自動 Workflow Hook (蓄積知識を session 開始時に強制注入)

```yaml
.claude/hooks/session-start.sh:
  - gh issue view 4 -R riku1215/agora | head -300 > /tmp/agora-context.md
  - gh issue list -R <current-repo> --state open --limit 30
  - git log --oneline -5
  - cat ~/riku1215/3-rules/r-rules-index.md
  - 全て context に inject
```

**効果**: 「agora#4 を fetch していませんでした」の根絶。

### M2: R32 Proactive Info Gathering Trigger (受動→自律)

```python
# orchestrator agent 内
def receive_captain_input(msg: str) -> Action:
    triggers = [
        # 「個別事例」だが「裏に体系的課題」
        ("体育", "他科目全部?"),
        ("scope 外", "MCP capability test 自動実行"),
        ("knowledge", "agora 検索自動 + Tier 別整理"),
    ]
    if any(t[0] in msg for t in triggers):
        return ProactiveResearch(scope="systematic")
```

**効果**: Captain の 1 言から自動的に体系的知識化。

### M3: Skill 自動マッピング + 強制呼出

```yaml
agents.yml に追加:
  historian:
    required_skills_on_session_end:    # ★ 新
      - claude-mem-make-plan
      - claude-mem-timeline-report
      - claude-mem-pathfinder
  reviewer:
    required_skills_on_pre_pr:
      - webapp-testing
      - doc-coauthoring
```

**効果**: 47 skills の活用率を 10% → 50%+ へ。

### M4: 過去議論強制検索 (researcher role auto-fire)

```python
# 提案を出す前に必ず:
def before_proposal(intent):
    similar = search_kb(intent.summary, role="researcher", top_k=12)
    if similar:
        return f"⚠ 類似議論あり:\n{similar}\n本提案は新規 vs 重複?"
    return None
```

**効果**: 「同じ過ちを繰り返しました」の予防。

### M5: 失敗ログ自動収集 + Section 7-6 適用

```python
# 私が「失礼しました」「申し訳ございません」を出力した時:
def on_excuse_detection(msg):
    pattern = extract_failure_pattern(msg)
    historian.record(pattern, severity="recurrence-risk")
    if pattern.matches_section_7():
        block_proposal()  # 同パターンを次提案で禁止
```

**効果**: excuse → 即学習 → 即防止のフィードバックループ完成。

---

## 4. Phase 1.5 = 「活かす」実装 (新規 phase)

Captain 指示に基づき、**Phase 1.5 を 0.0/0.1 と 1.0 の間に挿入**:

| Phase | 内容 | KPI |
|-------|------|------|
| 0.0 ✓ | 基盤確認 (本 PR) | repo + 初期 commit |
| 0.1 ✓ | R-rules 完全統合 | R1-R82 transcribe + agora labels |
| **1.5 ← 新** | **「活かす」実装** | R-rules 活用率 30% → 80% |
| 1.0 | 1 Issue 起点完全自動リレー | label trigger → 6 agent chain |
| 2.0 | Tree-sitter + impact-analyst | spec 変更影響解析 |

### Phase 1.5 具体タスク

- [ ] M1: SessionStart hook 実装 (`.claude/hooks/`)
- [ ] M2: R32 trigger logic を orchestrator に組込み
- [ ] M3: agents.yml に required_skills_on_* 追加
- [ ] M4: search_kb 強制呼出 wrapper
- [ ] M5: excuse 検出 → failure log

### Phase 1.5 KPI

- Section 7 違反: 6h 自走 4 件 → **次回 0-1 件**
- R-rule 活用率: 30% → **80%**
- claude-mem skill 呼出: 0 → **毎セッション 5+ 回**
- Captain 介入回数: ★ 「これおかしいよ」 50%↓

---

## 5. Captain への提案 (R10 一括承認)

| # | 項目 | 推奨度 |
|---|------|--------|
| 1 | 本ドキュメントを agoora#1 に comment として追加 | ★★★★★ |
| 2 | Phase 1.5「活かす」を agoora roadmap に挿入 | ★★★★★ |
| 3 | 次セッションは Phase 1.5 M1-M5 から着手 (本 PR は merge 待ち) | ★★★★ |
| 4 | R83-R87 + R88 (CLAUDE.md 投資原則) を agora 起票 | ★★★★ |
| 5 | 過去 excuse ログを ~/.kb/ に明示蓄積 + 月次 retrospective | ★★★ |

---

## 6. 最終結論

**6h 自走で agoora は「集合知の格納庫」として完成**。
しかし Captain 指摘通り、**「活かす」機構がまだ手動依存**。

**Phase 1.5 = agoora の本来の存在意義**:
- 知識 (1000+ Issue + 50+ R-rule + 47 skills) を **散らかったまま** ではなく
- Claude が **session-by-session で自動的に活用**できる状態にする

= 私 (Claude) と Captain の **「次回はちゃんとやります」の繰り返しを物理的に防ぐシステム**。

---

## 7. 関連

- 本 repo: `1-knowledge/usability-feedback-2026-05-11.md` (R83-R87 提案)
- 本 repo: `1-knowledge/project-map-grand.md`
- 本 repo: `1-knowledge/skills-strategy-integration.md` (Instructions > Skills + ELC + spec-impact)
- 本 repo: `3-rules/r-rules-index.md`
- 本 repo: `PROFILE.md Section 7` (失敗パターン 10 件、本ドキュメントの遠因)
- [agora#62](https://github.com/riku1215/agora/issues/62) R32 Proactive Info Gathering
- [agora#82](https://github.com/riku1215/agora/issues/82) R-rule 7 doctrine cluster
- riku1215/agoora#1 (本 doc を comment で追加推奨)

`#knowledge-vs-action #captain-vision #activation #phase-1-5 #agoora-mission`
