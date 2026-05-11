---
tags: [dsi-family, overview, agoora-integration, gap-analysis, captain-portal]
layer: knowledge
audience: [captain-only, claude]
status: active-critical
source: search_repositories user:riku1215 dsi in:name (2026-05-11)
created: 2026-05-11
---

# DSI Family 全 15 Repos Overview + agoora 統合 gap 分析

`#dsi-family #15-repos #gap-analysis #section-7-2`

## 0. Captain 指示 (2026-05-11)

> dsi.. レポを一通りチェックしてみる?

→ 「一通り」= 部分ではなく全件。Section 7-2 セッション文脈完全利用の reinforcement。

## 1. DSI Family 全 15 Repos (本セッション初体系化)

| # | Repo | 役割 | 言語 | Issues | Status | agoora 統合 |
|---|------|------|------|--------|--------|------------|
| 1 | **dsi-kit-library** ★ | Multi-axis specialized AI coding toolkit | Python | **145** | active (Tier 1) | ✓ portal-config |
| 2 | **dsi-wizard** ★ | VS Code Extension (interactive DSI workspace) | TypeScript | 11 | active (Tier 2) | ✓ portal-config |
| 3 | **dsi-copilot-central** | Central .github/copilot-instructions.md hub | - | 2 | on-hold | ✓ 本セッション統合 |
| 4 | **dsi-factory** | DSI Auto-Scaffold Pipeline | Python | 2 | on-hold | ✓ portal-config |
| 5 | **dsi-core** | Generic Skills/Instructions/Templates | - | 2 | on-hold | ✓ portal-config |
| 6 | **dsi-improver** | Two-layer improvement loop (Skills + Pipeline) | Python | 2 | on-hold | ✓ portal-config |
| 7 | **dsi-benchmark-results** | Accumulated benchmark results archive | - | 2 | archived | ✓ portal-config |
| 8 | **dsi-presets-public** | DSI preset: public industry | - | 2 | on-hold | △ "5 個" 集約 |
| 9 | **dsi-presets-retail** | DSI preset: retail | - | 2 | on-hold | △ "5 個" 集約 |
| 10 | **dsi-presets-medical** | DSI preset: medical | - | 2 | on-hold | △ "5 個" 集約 |
| 11 | **dsi-presets-finance** | DSI preset: finance | - | 2 | on-hold | △ "5 個" 集約 |
| 12 | **🆕 dsi-docs** | DSI architecture documentation hub | - | 2 | on-hold | ❌ **未統合** |
| 13 | **🆕 dsi-benchmark** | DSI Benchmark Framework (SWE-bench methodology) | Python | 2 | on-hold | ❌ **未統合** |
| 14 | **🆕 dsi-hypotheses** | DSI pipeline hypothesis tracking (Layer B improvement) | - | 2 | on-hold | ❌ **未統合** |
| 15 | **🆕 dsi-judge-latitude** | LLM-as-Judge integration with Latitude platform | Python | 2 | on-hold | ❌ **未統合** |

## 2. Section 7-2 違反検出 (重大)

**私 (Claude) は本セッション 14h+ 中、4 repos を完全に見落とした**:

| 未発見 repo | 重要度 | 見逃しの影響 |
|------------|--------|------------|
| **dsi-docs** | ★★★★★ | DSI 全体の architecture documentation hub、agoora の DSI 統合理解に必須 |
| **dsi-benchmark** | ★★★★★ | SWE-bench methodology = agoora 効果測定の標準的フレームワーク候補 |
| **dsi-hypotheses** | ★★★★ | Layer B improvement = agoora の improver 役の設計 source |
| **dsi-judge-latitude** | ★★★★ | LLM-as-Judge = reviewer 役の品質保証強化候補 |

**counterfactual** (もし agoora の I1 Pre-Action Probe があれば):
```
session 開始時:
  researcher.fan_out("user:riku1215 dsi in:name")
  → 15 repos 即時取得
  → portal-config.yml dsi_ecosystem 全件登録
  → 4 未統合 repo を Phase 0.0 で検出可能
```

→ 私の **Section 7-2 違反 = I1 機構の必要性証明**。

## 3. dsi-kit-library の 145 Issues (最大資産、未調査)

Tier 1 mature の **dsi-kit-library が 145 Issues**を保有。本セッションで 1 件も
詳細未調査。

ChatGPT が指摘した「失敗 = 進歩のタネ」(skill-baton-hashtag-thesis 連動) の最大
source として、Phase 1.5d-1 で **researcher.tenfold-rd skill で audit 必須**。

予想される高価値 Issues (推測):
- DSI Auto-Scaffold Pipeline 設計議論
- 4 業界 preset (public/retail/medical/finance) の業務特化知見
- Mixer CLI 実装 patterns
- 多軸 specialization (industry × language × scale) の trade-off

## 4. agoora 統合提案 (Phase 1.5)

### 即時統合 (本 commit)

- 本 doc 配置完了 ✓
- portal-config.yml dsi_ecosystem に 4 未統合 repo を **次 commit** で追加 (本 commit は doc のみ)

### 短期 (Phase 1.5d、kintaeru dogfooding 並行)

- **dsi-docs** clone → agoora knowledge base に index (researcher 役の reference)
- **dsi-benchmark** SWE-bench methodology を agoora 効果測定 framework として採用 (Harness Level 4 への進化)
- **dsi-judge-latitude** Latitude platform 統合 → reviewer 役の自動評価機構
- **dsi-hypotheses** Layer B improvement loop → agoora.improver 新役候補

### 中期 (Phase 2-3)

- dsi-kit-library 145 Issues 全件 researcher.tenfold-rd で audit
- 4 presets × Captain 業務領域 (sakura/dify/aomori/audit) を cross-mapping
- agoora が DSI family の **knowledge hub + GUI layer** として正式認定

## 5. portal-config.yml dsi_ecosystem 修正候補 (次 commit)

```yaml
dsi_ecosystem:
  members:
    # === 既存 (修正必要) ===
    dsi-kit-library:        {tier: 1-mature, role: core-cli, issues: 145}
    dsi-wizard:             {tier: 2-active, role: vscode-ide-gui, issues: 11}
    agoora:                 {tier: 2-active, role: web-gui-hub}
    dsi-copilot-central:    {tier: 2-on-hold, role: copilot-instructions-hub, issues: 2}  # ★ 本セッション認定
    dsi-factory:            {tier: 3-on-hold, role: auto-scaffold, issues: 2}
    dsi-improver:           {tier: 3-on-hold, role: improvement-loop, issues: 2}
    dsi-core:               {tier: 3-on-hold, role: generic-skills, issues: 2}

    # === 🆕 本セッションで初認識 (Phase 1.5 統合候補) ===
    dsi-docs:               {tier: 2-on-hold, role: architecture-doc-hub, issues: 2, priority: ★★★★★}
    dsi-benchmark:          {tier: 2-on-hold, role: swe-bench-framework, issues: 2, priority: ★★★★★}
    dsi-hypotheses:         {tier: 2-on-hold, role: layer-b-improvement, issues: 2, priority: ★★★★}
    dsi-judge-latitude:     {tier: 2-on-hold, role: llm-as-judge, issues: 2, priority: ★★★★}

    # === presets (4 個に修正、portal-config では誤って 5 個と記載) ===
    dsi-presets-public:     {tier: 3-on-hold, role: public-industry}
    dsi-presets-retail:     {tier: 3-on-hold, role: retail-industry}
    dsi-presets-medical:    {tier: 3-on-hold, role: medical-industry}
    dsi-presets-finance:    {tier: 3-on-hold, role: finance-industry}

    dsi-benchmark-results:  {tier: 3-archived, role: nightly-archive, issues: 2}
```

総数: **15 repos** (presets 4 個含む、portal-config.yml「5 個」記載は誤り)。

## 6. agoora の真の位置付け (再々定位)

```
[DSI Ecosystem 15 repos]
   ↓ knowledge transfer
[agoora] = Web GUI Hub + Knowledge Aggregator + Failure-Driven Learning
   ↓
[Captain の 28+ repo eco 全体]
```

agoora は **DSI family の 15 repos と他 13+ repos (class-weaver / mindgate / 等) を統合する hub**。

## 7. 関連

- [dsi-kit-library](https://github.com/riku1215/dsi-kit-library) (145 Issues、Tier 1 mature)
- [dsi-docs](https://github.com/riku1215/dsi-docs) ★ 未調査
- [dsi-benchmark](https://github.com/riku1215/dsi-benchmark) ★ 未調査
- [dsi-hypotheses](https://github.com/riku1215/dsi-hypotheses) ★ 未調査
- [dsi-judge-latitude](https://github.com/riku1215/dsi-judge-latitude) ★ 未調査
- `1-knowledge/dsi-ecosystem-integration.md` (本 doc の前段)
- `1-knowledge/dsi-copilot-central-integration.md`
- `4-portal/portal-config.yml` (次 commit で 15 repos 全反映)
- `1-knowledge/disruptive-innovation-5-proposals.md` I1 (本見落とし防止機構)

`#dsi-family #15-repos #section-7-2-violation #i1-needed`
