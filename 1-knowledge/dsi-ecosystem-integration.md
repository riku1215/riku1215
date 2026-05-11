---
tags: [dsi, ecosystem, agoora, dsi-wizard, dsi-kit-library, strategic-repositioning, captain-portal]
layer: knowledge
audience: [captain-only, claude, all-llms]
status: active-critical
created: 2026-05-11
source: dsi-wizard + dsi-kit-library + paw-sensor#194 (search_issues + search_code 経由)
---

# DSI Ecosystem 統合 + agoora 戦略的再定位 (2026-05-11)

`#dsi #ecosystem #agoora-repositioning #strategic`

## 0. サマリ (200 字)

**agoora は単独 product ではなく、DSI (Domain-Specialized Instruction) エコシステムの新規 member**。dsi-wizard (VS Code GUI) と本質的同型構造、dsi-kit-library (本体 CLI/lib) と連携可能。Captain の「インパクト発見」指摘通り、agoora を DSI 流派の **Web GUI 版** + **knowledge hub** として再定位することで、既存 28 repo エコシステムと完全統合可能。

## 1. DSI とは

**DSI = Domain-Specialized Instruction**

業界 × 言語 × 規模を選ぶだけで、プロジェクトに以下を自動配置:
- Skills (`.claude/skills/`)
- Instructions (`copilot-instructions.md` / `CLAUDE.md`)
- Templates
- YAML 設定 (`*.dsi.yaml`)

→ skills-strategy#2 で実証された「Instructions が Skills より 2-6 倍効く」を**業種横展開する基盤**。

## 2. DSI Ecosystem 全体図

```
┌───────────────────────────────────────────────────────────┐
│                                                            │
│       [Tier 1 mature] DSI 本体                             │
│       ┌─────────────────────────────────────┐              │
│       │ dsi-kit-library  (CLI/Library)      │              │
│       │   Mixer: dsi_mixer.py --config yaml │              │
│       │   Presets: business/lang/scale 5x5  │              │
│       └────────┬────────────────────────────┘              │
│                │                                            │
│       ┌────────┴────────────┐                              │
│       ↓                     ↓                              │
│  [Tier 2 active]      [Tier 2 active] ★ 新規              │
│  ┌──────────────┐    ┌──────────────────┐                  │
│  │ dsi-wizard   │    │ agoora           │                  │
│  │ VS Code Ext  │    │ Web GUI +        │                  │
│  │ (TypeScript) │    │ Knowledge Hub    │                  │
│  └──────────────┘    │ (Python/JS)      │                  │
│                      └──────────────────┘                  │
│                                                            │
│       [Tier 3 early] 拡張 / 派生                            │
│       dsi-factory / dsi-improver / dsi-core               │
│       dsi-presets-* (5 repos)                             │
│                                                            │
│       [連動]                                                │
│       paw-sensor#194 (新規 PJ 立ち上げ完全自動化 stack)     │
│         → agoora は DSI 適用第 N 号                         │
│                                                            │
└───────────────────────────────────────────────────────────┘
```

## 3. agoora ↔ dsi-wizard 同型分析

| レイヤー | dsi-wizard | agoora |
|---------|-----------|--------|
| **目的** | プロジェクトに DSI を対話配置 | プロジェクトの knowledge を統合検索 |
| **本体** | dsi-kit-library CLI | portal-api.py (FastAPI) |
| **GUI 環境** | VS Code 拡張 (TypeScript) | ブラウザ SPA (HTML+JS) |
| **設定** | `*.dsi.yaml` + JSON Schema | `portal-config.yml` + `agents.yml` + `agent_profiles.yaml` |
| **配置先** | `.claude/skills/`, `.github/copilot/` | `~/Portal/`, `~/.kb/` |
| **生成 wizard** | `dsi-wizard new research --tenfold` | researcher 役 (まだ未実装) |
| **対象** | 任意プロジェクト | 個人開発全体 (cross-repo) |
| **バージョン管理** | `.dsi-version` | `current_path.txt` (Phase D) |

→ **GUI 環境のみ違う**。VS Code (IDE) vs Browser (web)。
→ 機能・思想・設計**ほぼ完全一致**。

## 4. 統合シナリオ (★ 推奨度)

### A. agoora の VS Code 拡張化 ★★★★★

Phase 5 商用化前に **Phase 1.5c として前倒し**。
- `5-product/agoora-vscode/` 配置
- dsi-wizard と**同 VS Code 内で連携**可能
- Captain は VS Code 主開発、効果絶大

### B. Mixer CLI と portal-api の融合 ★★★★★

agoora portal-api に `POST /dsi/apply` endpoint 追加:
```
{
  "target": "/path/to/new/project",
  "industry": "ai-development",
  "language": "python",
  "scale": "M"
}
```
→ dsi-kit-library Mixer 呼出 → 配置完了 → agoora UI で結果可視化

### C. researcher 役 + 10 通り R&D wizard ★★★★★

dsi-wizard #13 の「10 通り R&D テンプレ」を **agoora researcher 役の skill** として組込:

```yaml
researcher:
  skills:
    - tenfold-rd        # ★ 新、dsi-wizard 由来
    - find-skills
    - claude-mem-mem-search
```

`tenfold-rd` の動作:
- topic + domain 受領
- N variants (default 10) + M cases (default 5) + Citations (default 5-7)
- parent Issue + N child Issues + harness skeleton 自動生成

### D. portal-config.yml に DSI ecosystem map ★★★★

```yaml
dsi_ecosystem:
  - dsi-kit-library    {tier: 1-mature, role: core-cli}
  - dsi-wizard         {tier: 2-active, role: ide-gui}
  - agoora             {tier: 2-active, role: web-gui-and-hub}   # ★ 新規
  - dsi-factory        {tier: 3-early, role: auto-scaffold}
  - dsi-improver       {tier: 3-early}
  - dsi-core           {tier: 3-early}
  - dsi-presets-*      {tier: 3-early, count: 5}
```

### E. paw-sensor#194 stack に agoora を組込み ★★★

paw-sensor 由来 DSI 提案 stack 5 件 (dsi-kit#186/187/188/189/194) で
**新規 PJ 立ち上げ完全自動化 stack** が完成済。
→ agoora を 6 件目として追加: **knowledge hub 自動配置** stack.

## 5. agoora の戦略的優位性 (再定位後)

| 観点 | 単独 product | DSI member |
|------|------------|-----------|
| **採用拡散** | agoora.jp 単独 | DSI エコシステム全体で展開 |
| **知名度** | ゼロから構築 | dsi-kit-library 既存ファンベース継承 |
| **技術相乗** | 独自開発 | dsi-wizard 同型で実装ノウハウ共有 |
| **商用化 path** | 直販のみ | dsi-kit エンタープライズ顧客への upsell |
| **ライセンス** | MIT 単独 | DSI エコシステム license と整合 |

## 6. 反論余地 (R8)

1. **DSI に縛られて agoora の独自性が薄れる**
   → 反論: 同型≠依存。agoora は Web 完結、dsi-wizard は IDE 完結、市場が分かれる
2. **dsi-kit-library が on-hold/未完成なら agoora も影響**
   → 反論: agoora は dsi-kit と疎結合、CLI 統合は optional
3. **VS Code 拡張化は Phase 5 前倒しで負担増**
   → 反論: dsi-wizard が既に scaffold 完了、TypeScript で再利用可、工数半減

## 7. 統合実装計画 (Phase 1.5b、本 3h 自走で着手)

| Task | 内容 | 本 3h で実施? |
|------|------|--------------|
| (F) portal-config.yml `dsi_ecosystem` 追加 | yaml 更新 | ✓ |
| (E) researcher 役 `tenfold-rd` skill 追加 | agents.yml 更新 | ✓ |
| (D) `5-product/agoora-vscode/` 雛形 | TypeScript scaffold | ✓ |
| (B) `scripts/auto-label.py` | Python 実装 | ✓ |
| (C) `4-portal/AGENTS.md` 生成 | agents.yml の md 版 | ✓ |
| Mixer CLI 統合 (`/dsi/apply` endpoint) | portal-api.py 拡張 | 次セッション |

## 8. 関連

- [dsi-wizard #1](https://github.com/riku1215/dsi-wizard/issues/1) — Epic
- [dsi-wizard #13](https://github.com/riku1215/dsi-wizard/issues/13) — 10 通り R&D wizard
- [dsi-kit-library #194](https://github.com/riku1215/dsi-kit-library/issues/194) — paw-sensor 由来 DSI 提案
- [agora#40](https://github.com/riku1215/agora/issues/40) Cross-Repo Knowledge Transfer
- [skills-strategy#2](https://github.com/riku1215/skills-strategy-analysis/issues/2) Instructions > Skills
- 本 repo: `1-knowledge/project-map-grand.md`
- 本 repo: `1-knowledge/skills-strategy-integration.md`
- 本 repo: `4-portal/agents.yml` (本 3h で `tenfold-rd` skill 追加予定)

`#dsi #ecosystem #agoora #strategic-repositioning #phase-1-5b`
