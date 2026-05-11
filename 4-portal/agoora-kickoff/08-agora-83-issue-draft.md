# agora#83 起票 draft — R83-R88 + 5 hygiene + DSI integration

> Captain が `gh issue create -R riku1215/agora --body-file <本ファイル>` で起票するための draft。
> 本 6h + 3h 自走から抽出した agora への feedback と R-rule 候補 6 件 + DSI integration 提案。

---

# [doctrine] R83-R88 + 5 hygiene + DSI integration — agoora 開発 9h 実体験 feedback

## 0. 起票背景

riku1215/agoora の Phase 0.0-1.0 開発 (riku1215/riku1215 PR #19、~12,000 行)
を 9h 自走で実施した結果、**agora 本体の改善余地 12 件**を発見。
agoora は agora#40 Cross-Repo Knowledge Transfer の **Tier 2 active member** として、
本 feedback で agora エコシステム全体を強化する。

---

## 1. R83 Session-Start Hook (技術実装)

**問題**: Claude Code セッション開始時、agora#4 を fetch せず作業開始するパターンが**ほぼ毎回**発生。

**証拠**:
- 本 9h 自走でも初回 fetch なし → Task 1 で初 fetch、agora#82 (7 doctrine cluster) を発見
- CLAUDE.md に明記済の workflow が手動依存

**提案**:
- `.claude/hooks/SessionStart.sh` で agora#4 自動 fetch
- CLAUDE.md import に `@agora-4-context.md` 標準化
- 違反検出時は orchestrator が self-訂正

**Cluster**: D-D (Autonomy & Planning)

## 2. R84 MCP Capability Probe

**問題**: Claude が「scope 外で出来ません」と誤判定するパターン。

**証拠**:
- pet-care-app の `search_issues` は実は org-wide で動作するが、初回「scope 外」と誤判定
- search_* と issue_write/list の権限差を Claude が事前認識せず

**提案**:
- session 開始時 3-5 個の MCP tool で capability test 自動実行
- 結果を context に焼く: `mcp_capabilities = {search_issues: org-wide, issue_write: scope-only, ...}`
- 「scope 外」判定前に必ず capability test 結果を参照

**Cluster**: D-D + 新規可能性

## 3. R85 R20 + R10 連動明示化

**問題**: Captain「6h 自走」短文指示 → Claude が R10 計画自力提示 → 「計画なしで auto-execute は不可能」が暗黙化。

**提案**:
- R20 発動前に必ず R10 計画 (10-15 task) を提示
- 「自走して」だけの指示は **Claude が R10 計画を自動生成 + 5 分待機**
- 既存 agora#82 D-D doctrine cluster に正式追記

**Cluster**: D-D (R20/R10 統合)

## 4. R86 Migration Completion Deadline + auto-migrate

**問題**: `zz-deprecated-*` 28 個と新 `prefix:value` 30 個が**並行運用中**。
新 Issue で旧 label 使用 → noise + Claude 混乱。

**提案**:
- 旧 zz-deprecated-* → 新 prefix:value の 1:1 マッピング script
- 月末締切で全 Issue 自動 re-label
- 完了後 zz-deprecated-* を全 close (但し R64 番号 freeze で削除なし)

**実装**: agoora の `scripts/auto-label.py` (PR #19 同梱) で対応可。

**Cluster**: D-F (Quality Gate)

## 5. R87 R8 強化 (反論最低 3 件 + リスク確率 × 影響度)

**問題**: 「反論余地あり」と書くだけで具体反論なし例多数。

**提案**:
- 反論最低 3 件
- リスクマトリクス必須 (確率 × 影響度)
- 「現状で問題ない」結論禁止 (echo chamber 防止)
- agoora の critic agent 既に同基準で動作中 (dogfooding)

**Cluster**: D-G (Pushback / Premise)

## 6. R88 ★ 新規: 「Instructions over Skills」投資原則

**証拠**: skills-strategy#2 (実測、犬猫 PJ 5 ヶ月)
- Instructions (CLAUDE.md) 月効果: 15-45h
- Skills 月効果: 8h
- = **2-6 倍効果差**

**提案**:
- 新 R-rule 候補
- Claude Code 比重: **Instructions 70% / Skills 30%** を全 28 repo で標準化
- 47 skills → Top 15 厳選を agora#X 別 Issue で起票
- per-domain CLAUDE.md (agoora 既実装) を全 repo 横展開

**Cluster**: D-B (Captain Communication) + 新規

## 7. 5 Hygiene 提案

### H1 Issue Templates (`.github/ISSUE_TEMPLATE/`)
- R9 checklist / R10 batched / R32 proactive 専用テンプレ 5 種

### H2 Bilingual Conventions
- タイトル英語、本文日本語混在 OK、commit msg 日本語 OK を明文化

### H3 Phase Definition (横断)
- Phase 0.0 / 0.1 / 1.0 / 2.0 / 5.0 を agora で正式定義、全 28 repo 共通

### H4 claude-mem Skills 強制 bind
- 47 skills 中 5 個 (74K ⭐) が未活用
- historian 役に必須 bind (agoora 実装済)

### H5 Trigger Vocabulary
- 「ナレッジ化して」「記録しておいて」「Issue に残して」「これ重要」「後で参照」「失敗パターン化」
- historian agent 発火語として公式化

---

## 8. ★ DSI Ecosystem 統合提案 (本 9h 自走の最大発見)

dsi-wizard 調査で判明:
- **agoora は dsi-wizard の Web GUI 版** (本質同型)
- **dsi-kit-library** の knowledge hub member として位置付け可能

### 提案
1. agoora を **DSI Ecosystem の Tier 2 active member** として正式認定
2. dsi-wizard と **同 IDE 内連携** (VS Code 拡張 scaffolding 完了、agoora#X で起票準備済)
3. Mixer CLI ↔ portal-api 統合 (`POST /dsi/apply` endpoint、Phase 2)
4. researcher 役に **`tenfold-rd` skill** 追加 (dsi-wizard#13 + class-weaver#113 由来) — agoora 実装済
5. paw-sensor#194 stack に agoora を 6 件目として組込

### 期待効果
- DSI 既存ファンベース継承
- dsi-wizard TypeScript scaffold 再利用 (実装工数半減)
- Phase 5 商用化時に DSI 統一リリース可能

---

## 9. 関連

- riku1215/riku1215 PR #19 (実装本体、~12,000 行)
- riku1215/agoora #1 (起点 Issue + 6 comments)
- agora#4 Master Operating Guidelines
- agora#40 Cross-Repo Knowledge Transfer
- agora#82 R-rule consolidation 7 doctrine cluster
- skills-strategy#2 Instructions > Skills (R88 根拠)
- dsi-wizard #1 Epic, #13 tenfold-rd
- paw-sensor #194 (DSI 提案 stack)
- riku1215/riku1215 1-knowledge/usability-feedback-2026-05-11.md
- riku1215/riku1215 1-knowledge/from-knowledge-to-action.md
- riku1215/riku1215 1-knowledge/dsi-ecosystem-integration.md

## 10. Captain 認可待ち (R60 vision-captain-only)

| # | 項目 | yes/no |
|---|------|--------|
| 1 | R83-R88 を agora R-rules に正式追加 | ? |
| 2 | 5 hygiene H1-H5 を agora roadmap に追加 | ? |
| 3 | DSI Ecosystem 統合 (agoora 認定 + Mixer 連携 + Phase 5 統一リリース) | ? |
| 4 | scripts/auto-label.py を agora にも適用 (zz-deprecated-* 移行) | ? |
| 5 | agoora#1 に本 Issue を comment として link | ? |

`#agora #r-rules #r83 #r88 #dsi-integration #agoora-feedback`
