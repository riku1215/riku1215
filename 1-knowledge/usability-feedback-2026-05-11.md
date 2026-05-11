---
tags: [usability, feedback, agora, r-rules-candidates, captain-portal, retrospective]
layer: knowledge
audience: [captain-only, claude, all-llms]
status: active
created: 2026-05-11
source: PR #19 6h 自走 + agoora 開発実体験
---

# 使い勝手フィードバック → agora 開発方針提案 (2026-05-11)

`#usability #agora-feedback #r-rules-candidates`

> **Captain 指示反映**: 「今までの GitHub 蓄積ノウハウを使いながら、使い勝手悪い箇所を分析し、agora 開発方針に取り入れる」
>
> 本ドキュメントは agoora 開発過程で**実体験した使い勝手の問題点** 12 件を抽出、上位 5 件を **agora 新 R-rule 候補**として提案。

---

## 0. サマリ (200 字)

agoora 開発で 12 件の使い勝手問題を発見。最重要 3 件:
1. **session-start workflow 自動強制機構なし** → Claude が agora#4 を忘れて開始する
2. **MCP capability 事前不明** → 「scope 外」誤判定で時間損失
3. **R20 5-min auto-execute の発動条件不明確** → R10 計画なしで自走開始

→ agora に **R83-R87 候補** 5 件を提案、本ドキュメントを agora#83 Issue として起票推奨。

---

## 1. 発見した使い勝手の問題 12 件

### 🔴 重大 (★★★★★)

#### U1. session-start workflow が手動依存

**事象**: 本セッション開始時、私 (Claude) は **agora#4 を fetch せず**に作業開始。
PROFILE.md / CLAUDE.md に「セッション開始時に必ず実施」と明記されているが、自動強制機構なし。

**原因**: instruction の存在 ≠ 実行保証。session 起動時 hook が無い。

**頻度**: ほぼ毎回 (Claude セッション数 N 回中 N 回程度発生推定)

**提案 R83**: **Session-Start Hook (技術実装)**
- Claude Code の `SessionStart` hook を agora#4 自動 fetch に bind
- CLAUDE.md import で agora#4 R-rules を確実に context へ
- 違反検出時は orchestrator が自己訂正 (Section 7-6)

#### U2. MCP scope の事前確認手順不在

**事象**: 私が「pet-care-app は scope 外で読めない」と誤判定 → Captain 訂正 → 再検証で `search_issues` が org-wide で動作と判明。

**原因**: scope ≠ all operations equal。**read (search) と write (issue_write) が異なる挙動**を Claude が事前に知らない。

**頻度**: 新セッションごと

**提案 R84**: **MCP Capability Probe at session start**
- session 開始時に 3-5 個の MCP tool で capability test
- 結果を context に焼く: `mcp_capabilities = {search_issues: org-wide, issue_write: scope-only, ...}`
- 「scope 外」判定前に必ず capability test 結果を参照

#### U3. R20 (5-min auto-execute) 発動条件曖昧

**事象**: Captain 「6h 自走」だけで具体 task list 不在 → 私が R10 計画を自力で提示する pattern。

**原因**: R20 = 「5 分以内 user 反応なしで自動実行」だが、**何を自動実行するかは R10 計画依存**。R10 計画がない状態で R20 は発動できない。

**頻度**: 自走時毎回 (本 6h 自走でも該当)

**提案 R85**: **R20 + R10 連動明示化**
- R20 発動前に必ず R10 計画 (10-15 task) を提示
- 計画なしの「自走して」は **Claude が R10 計画を自動生成 + 5 分待機**
- agora#82 D-D doctrine cluster に追記推奨

### 🟠 中程度 (★★★★)

#### U4. agora taxonomy 移行未完了

**事象**: `zz-deprecated-*` 28 個と新 `prefix:value` 30 個が**並行運用中**。新 Issue で旧 label 使用 = noise。

**頻度**: 全 agora Issue (93 件)

**提案 R86**: **Migration Completion Deadline + auto-migrate**
- 旧 zz-deprecated-* → 新 prefix:value の 1:1 マッピング script
- 月末締切で全 Issue 自動 re-label
- 完了後 zz-deprecated-* を全 close (但し R64 番号 freeze で削除なし)

#### U5. R8 反論余地が形式化

**事象**: 「反論余地あり」と書くだけで具体反論ない例が agora Issues に多数。

**原因**: R8 文言が「明示」のみで、**最低件数や深さの規定なし**。

**頻度**: 私自身も該当 (Section 7-8 違反)

**提案 R87**: **R8 強化 — 反論最低 3 件 + リスク確率 × 影響度**
- agents.yml critic 役と同期 (既に「反論 3 件以上」明記済)
- リスクマトリクス必須 (確率 × 影響度)
- 「現状で問題ない」結論禁止 (echo chamber 防止)

### 🟡 軽度 (★★★)

#### U6. Issue templates 不在

agora には Issue template (`.github/ISSUE_TEMPLATE/`) 無し。Captain が markdown を手動作成。
→ R9 checklist / R10 batched / R32 proactive 等の専用テンプレ 5 種推奨。

#### U7. Bilingual conventions 不明確

日本語 / 英語の使い分け基準なし。私 (Claude) は経験則で混在使用。
→ agora#X に「タイトル英語、本文日本語混在 OK、commit msg 日本語 OK」明文化推奨。

#### U8. Phase 0 vs Phase 1 定義曖昧

「Phase 0.0」「Phase 0.1」「Phase 1.0」が agora で正式定義なし。本 agoora が初出。
→ agora 横断 Phase 定義表を作成、各 product (28 repo) で参照。

#### U9. agora 検索 UI 不在

93 Issues + 1000+ comments を grep のみで検索 = 遅い。
→ **agora 自身が agoora UI を採用** (dogfooding)、phase 5 で公開デモ統合。

#### U10. claude-mem skills の活用不在

47 skills 中 5 個が claude-mem 系 (74K ⭐) だが、本 6h 自走で 1 度も呼出されず。
→ historian 役の **必須 skill** として agents.yml に強制バインド。

#### U11. trigger 語の標準化不足

「ナレッジ化して」「記録しておいて」等のトリガ語は **私の Help タブ提案**で標準化、agora には未昇格。
→ agora#X で「Historian Trigger Vocabulary」公式化、全 28 repo 共通。

#### U12. visibility ラベルの標準化なし

`visibility: public / local-only / captain-only` を agora で使っていない。
→ agora Issue にも `visibility:*` label を追加、private 提案資料 (Dify 60 社) と公開 R-rules を区別。

---

## 2. agora への提案 (Issue 起票推奨)

### A. 即時起票推奨: agora#83 候補 "R83-R87 R-rules + 5 hygiene improvements"

タイトル: `[doctrine] R83-R87 + 5 hygiene proposals — agoora 開発実体験 feedback`

本体:
1. R83 Session-Start Hook (技術実装、agora#4 自動 fetch)
2. R84 MCP Capability Probe (誤判定防止)
3. R85 R20 + R10 連動明示化 (自走発動条件)
4. R86 zz-deprecated-* 移行完了 deadline + auto-migrate
5. R87 R8 強化 (反論 3 件 + リスクマトリクス)

+ 5 hygiene (Issue templates / bilingual / phase definition / claude-mem / trigger vocabulary)

### B. 中期: agora 自身の agoora UI 採用

- Phase 5 商用化時、agora.quard-web.jp で agoora UI を Live demo
- 93 Issues を GitHub IA で横断検索可能化
- 集客導線 (Captain 構想と一致)

### C. 長期: 全 28 repo に R-rule 自動 audit

- 各 repo の CLAUDE.md で agora R-rules を強制参照
- weekly audit で violation 検出 → 自動 Issue 起票
- agoora の **auto-relay workflow** を agora にも適用 (cross-repo dogfooding)

---

## 3. 私 (Claude) の自己批判 (Section 7-6 失敗即時学習)

本 6h 自走で**私自身が以下を違反**:

| 違反 | 該当 R | 改善 |
|------|--------|------|
| session-start で agora#4 fetch せず | CLAUDE.md / U1 | Task 1 で初 fetch、今後は必須 |
| MCP scope 誤判定 (pet-care-app) | Section 7-6 / U2 | search_* 経由で再検証、訂正済 |
| 「6h 自走」を R10 計画なしで実行 | R10 / U3 | 本セッションで計画提示済、次回は事前 |
| 47 skills の claude-mem 不使用 | U10 | 次セッションで明示的に invoke |

→ 本ドキュメントの存在自体が agora#62 R32 (Proactive Info Gathering) の実践。

---

## 4. agora 横展開戦略 (Captain 構想統合)

```
[agoora 開発実体験]
    ↓
[使い勝手 feedback] (本ドキュメント)
    ↓
[agora 新 R-rule 候補 R83-R87] (Issue 起票)
    ↓
[28 repo 横展開] (agora#40 Tier 別)
    ↓
[Captain 統合 ecosystem 強化]
```

→ agoora は agora の **dogfooding instance** として機能。
agoora で発見した問題 = agora の弱点 = 全 28 repo の弱点。
本フィードバックループが回れば、**1 product 開発 = 28 repo 改善**。

---

## 5. 関連

- [agora#4](https://github.com/riku1215/agora/issues/4) — Master Operating Guidelines
- [agora#40](https://github.com/riku1215/agora/issues/40) — Cross-Repo Knowledge Transfer (Tier 1-3)
- [agora#62](https://github.com/riku1215/agora/issues/62) — R32 Proactive Info Gathering
- [agora#82](https://github.com/riku1215/agora/issues/82) — R-rule consolidation 7 doctrine cluster
- [agora#39](https://github.com/riku1215/agora/issues/39) — Knowledge Hub
- 本 repo: `3-rules/r-rules-index.md`
- 本 repo: `3-rules/doctrine-clusters.md`
- 本 repo: `3-rules/agora-labels-audit.md`

## 6. 次のアクション

- [ ] Captain: 本ドキュメントを agora#83 として起票 (Phase 0.1 後)
- [ ] Captain: R83-R87 を Captain 認可 (R60 vision-captain-only)
- [ ] Claude: 認可後、本 repo CLAUDE.md に R83-R87 を反映
- [ ] Claude: agoora の auto-relay workflow を agora にも適用 (dogfooding)
- [ ] Claude: 月次で本ドキュメント更新 (継続観察)

`#usability #agora #r-rules-candidates #dogfooding #feedback-loop`
