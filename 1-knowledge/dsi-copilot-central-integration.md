---
tags: [dsi-copilot-central, multi-llm-workflow, agoora-integration, past-session-memory, captain-portal]
layer: knowledge
audience: [captain-only, claude]
status: active-critical
source: dsi-copilot-central#1 #2 + 過去セッション記憶 cross-check
created: 2026-05-11
---

# dsi-copilot-central 統合 + 過去セッション記憶 cross-check

`#dsi-copilot-central #multi-llm #6-stage-workflow #past-session-memory`

## 0. Captain 指示 (2026-05-11)

> こちら (dsi-copilot-central) も参考に。
> 過去のセッションの記憶とも照合しながら。

→ 2 重指示: (a) dsi-copilot-central 分析、(b) 過去セッション記憶を本 PR に cross-reference。

## 1. dsi-copilot-central 6 Stage Workflow (最重要発見)

dsi-copilot-central#2 で agoora pipeline の**先行設計**が既存:

| Stage | LLM/Tool | 入出力 | agoora 対応 |
|-------|---------|--------|-----------|
| 1. 設計 | Claude session | 仕様書 + sub-issue 群 | ✓ architect 役 |
| 2. **PR 自動生成** | **GHCP Coding Agent** | issue → PR | ⚠ **agoora 未対応** |
| 3. **比較 PR 並列** | **Codex Cloud** | 同 issue → 別 PR | ⚠ **agoora 未対応** |
| 4. PR review | @claude GitHub Action | diff コメント | ✓ auto-relay.yml |
| 5. 対話・設計議論 | VSCode Chat (GPT-5.5) | 設計議論 | ✓ agoora-vscode |
| 6. 統合 (merge 判断) | Claude session | merge 判断 | ✓ orchestrator |

### 🚨 agoora の重大な見落とし

**Stage 2-3 並列 PR 生成機構**が agoora の auto-relay.yml に欠落:
- agoora 現状: 1 stream (orchestrator → researcher → architect → ...) の linear pipeline
- dsi-copilot-central: 同 issue から 2 並列 PR (GHCP vs Codex) で品質比較

→ R14 多 LLM dispatch の **PR-level 実装**。
→ agoora routing.yml は agent-level R14 のみ、PR-level 並列未実装。

## 2. 過去セッション記憶 cross-check

### 統合済 (本 PR で integrated、16 件)

agora#4/#40/#59/#62/#82、ai-financial-office#89、class-weaver#113、
skills-strategy#2/#4/#10、mindgate#44、pet-care-app#52、paw-sensor#194、
dsi-wizard#13、skills/multi-llm-review、skills/label-migration、kintaeru#1

### 未統合 (Phase 1.5 で追加)

| 資産 | 提案統合先 | 推奨度 |
|------|----------|-------|
| **dsi-copilot-central#2 Stage 2 GHCP 並列 PR** | routing.yml auto-relay branch_parallel option | ★★★★★ |
| **dsi-copilot-central#2 Stage 3 Codex Cloud 比較 PR** | coder 役の variant (claude-coder / codex-coder) | ★★★★★ |
| dsi-benchmark-results | agoora 効果測定永続化先 | ★★★ |

## 3. agoora routing.yml 拡張提案 (Phase 1.5d-2)

```yaml
- id: parallel-pr-generation
  description: dsi-copilot-central#2 Stage 2-3 反映、品質比較用 PR 並列生成
  when:
    keywords: [比較, 並列, parallel, ベンチマーク]
    or:
      - label: parallel-pr
      - confidence_threshold: critical-decision
  then:
    pipeline:
      - orchestrator
      - researcher
      - architect
      - critic
      - parallel:
          - {coder: claude, output: PR-claude}
          - {coder: codex,  output: PR-codex}
          - {coder: ghcp,   output: PR-ghcp}
      - impact-analyst
      - reviewer (3 PR 比較)
      - orchestrator (best PR 選定)
    flag: needs_captain_final_approval
```

## 4. Section 7-2 違反検出 (本セッション 14h+)

| Issue | 発見タイミング | 違反 | counterfactual |
|-------|--------------|------|---------------|
| dsi-copilot-central 存在 | Captain 指摘で初認識 | 7-2 セッション文脈不完全 | 過去 ~/.kb/ 検索で発見可能 |
| Stage 2-3 並列 PR pattern | 本 doc 作成時 | 7-2 + 7-7 重要発見見落とし | I1 Pre-Action Probe で防止可 |
| 16/4 統合/未統合の整理不足 | 本 doc で初体系化 | 7-7 出力分量 | historian 自動 cross-check で防止 |

→ **本 doc 自体が counterfactual の実演** (I1 で防げた見落とし)。

## 5. Phase 1.5 必須タスク追加

| Task | 優先 |
|------|------|
| I1 Pre-Action Probe 実装 (全 28 repo 自動 fan-out) | ★★★★★ |
| dsi-copilot-central 6 Stage → routing.yml integration | ★★★★★ |
| 未調査 12 repo の体系的 audit (researcher.tenfold-rd で 1 セッション 1 repo) | ★★★★ |

## 6. 関連

- [dsi-copilot-central#1](https://github.com/riku1215/dsi-copilot-central/issues/1)
- [dsi-copilot-central#2](https://github.com/riku1215/dsi-copilot-central/issues/2) 6 Stage Workflow
- `4-portal/routing.yml` (本 PR 後に parallel-pr-generation 追加候補)
- `1-knowledge/disruptive-innovation-5-proposals.md` (I1 = 本見落とし防止機構)
- `1-knowledge/counterfactual-agoora-could-have-prevented.md` (本 doc 自体が新事例)

`#dsi-copilot-central #cross-check #section-7-2 #past-session-memory`
