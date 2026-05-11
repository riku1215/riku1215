---
tags: [agoora, dogfooding, tier-3-early, validation, captain-strategy]
layer: knowledge
audience: [captain-only, claude]
status: active-strategic
created: 2026-05-11
---

# agoora dogfooding 候補 — 低 Phase PJ での実証検証戦略

`#agoora #dogfooding #tier-3 #validation #captain-strategy`

## 0. Captain 戦略 (2026-05-11)

> 開発 Phase が低い PJ は、agoora の実装で開発しながら実証検証してもいい

= **3 重価値の同時実現**:
1. **agoora dogfooding** (実走で弱点露見 → 改善ループ)
2. **早期 PJ の加速開発** (agoora researcher + architect + coder で 1 issue → PR 自動化)
3. **顧客向け実証データ** (Phase 5 商用化時のデモ材料、「この PJ は agoora で 1 セッション開発」)

---

## 1. 候補 PJ 評価 (★ 適性度、portal-config.yml quard_products より)

### 🟢 第 1 候補 (即着手推奨)

| Product | Phase | tech | adoptability ★ | 理由 |
|---------|-------|------|---------------|------|
| **kintaeru** | Phase 0 → 1 | TypeScript + Cloudflare Workers + Neon | ★★★★★ | 11 Issue 起票済 + agora#40 Tier 1→3 transfer 実例 + LINE 統合は agoora routing 拡張可能 |
| **shiftweaver** | phase-0-skeleton | (FastAPI 推定、localhost:8000 確認済) | ★★★★★ | 既に skeleton 起動中、Captain 環境で確認済、最小コストで試行可 |

### 🟡 第 2 候補 (短期着手)

| Product | Phase | 適性 ★ | メモ |
|---------|-------|--------|------|
| **prompt-notes** | spec | ★★★★ | Notes 系で小規模、AI Skills 直接活用 (researcher tenfold-rd) |
| **sourcecode-judge-saas** | spec | ★★★★ | コード判定 = impact-analyst + Tree-sitter PoC の直接適用先 |
| **doc-studio** | spec | ★★★ | 文書系、AI 直接活用、agoora UI 一部流用可 |

### 🔵 第 3 候補 (中期、要設計)

| Product | Phase | 適性 ★ | メモ |
|---------|-------|--------|------|
| **dsi-factory / dsi-wizard / dsi-improver / dsi-core** | spec | ★★★★ | DSI Ecosystem 内、agoora と循環的開発 (DSI から agoora、agoora で DSI) |
| **book-studio / video-autopilot** | spec | ★★★ | メディア生成系、Phase 2 で nano-banana-image-gen skill 活用 |
| **quard-community / quard-ui** | spec | ★★ | 周辺、優先度低 |

---

## 2. 推奨着手順序 (Phase 1.5 内、本 6h+ 自走の延長)

### Phase 1.5d-1: kintaeru で実証 (最有力候補) ★★★★★

**着手手順**:
1. agoora.researcher 役 (tenfold-rd skill) で kintaeru の Phase 1 Issue 候補を 5-10 件提案
2. agoora.architect 役で各 Issue の設計 3 案 + ★ 推奨度
3. agoora.critic 役 (multi-llm-review skill) で R14 反論
4. agoora.coder 役で実装 patch_plan (TypeScript)
5. agoora.impact-analyst で Cloudflare Workers + Neon の blast radius
6. agoora.reviewer で 5-gate (R27)
7. agoora.historian で 結果を kintaeru Issue にコメント (Issue-as-shared-memory)

**期待成果**:
- kintaeru Phase 1 が agoora 1 セッション (3-6h) で 1-3 Issue 進行
- agoora の弱点 5+ 発見 → R83-R88 候補追加
- LINE Webhook 統合パターンを agoora routing.yml に逆輸入

**Stop Conditions**:
- kintaeru 共同開発者 (伊藤さん) との調整不在で爆速進行不可なら停止
- 労基法対応 (Issue #4) は Captain 認可必須

### Phase 1.5d-2: shiftweaver で実証 (Quick win)

**理由**: 既に skeleton 起動済、Captain Windows 環境で動作確認可。
**着手**: kintaeru と並行、agoora 1h セッションで shiftweaver Phase 0 → Phase 1 進行試行。

### Phase 1.5d-3: dsi-factory で実証 (循環)

**特徴**: agoora が DSI Ecosystem の member なので、**agoora で DSI を開発 = 自己拡張**。

---

## 3. dogfooding 試行で測定する KPI

| KPI | 目標値 | 測定方法 |
|------|--------|---------|
| **1 セッション完了 Issue 数** | 1-3 件 | 試行後 closed Issue count |
| **agoora 経由開発時間 / 手動開発時間** | 0.5x 以下 | 同種 Issue を 1 件は手動、1 件は agoora 経由で測定 |
| **R-rule 違反検出率** | ≥ 80% | reviewer 役の指摘件数 / 全違反潜在件数 |
| **発見した agoora の弱点数** | ≥ 5/PJ | usability-feedback-2026-05-11.md に追記 |
| **顧客デモ可能 PR 数** | ≥ 1/PJ | 「agoora で生成」と明示できる PR |

---

## 4. agoora 改善ループ (dogfooding → 修正 → 再 dogfooding)

```
[Tier 3 PJ Issue]
     ↓
[agoora pipeline] (researcher → architect → critic → coder → reviewer)
     ↓
[PR 自動生成 + Captain 承認]
     ↓
[失敗 / 不便 / 違反検出]
     ↓
[1-knowledge/usability-feedback-*.md に追記]
     ↓
[agoora 修正 (agents.yml / routing.yml / agent_profiles.yaml)]
     ↓
[次の Tier 3 PJ で再 dogfooding]
     ↓ (繰り返し)
[Phase 5 商用化、agoora は 28+ repo で実証済 SaaS]
```

→ **3-5 PJ 経由で agoora は「実証済 enterprise grade」へ進化**

---

## 5. 共同開発 PJ の特殊扱い (kintaeru モデル)

kintaeru は伊藤さんとの共同開発:
- 共同開発 PJ では **agoora の Issue へのコメント** は伊藤さんから見える
- **automated comment via auto-relay** は事前合意必要
- → agoora.protocol.md §11 に「共同開発 PJ では auto-relay は notify-only mode」追記推奨

---

## 6. portal-config.yml 更新提案

| Product | 現状 | 更新後 |
|---------|------|--------|
| kintaeru | `用途不明 (要 Captain 確認)` | `LINE 起点勤怠+給与計算 SaaS (共同、agoora dogfooding 第 1 候補)` |
| shiftweaver | phase-0-skeleton | `phase-0-skeleton (agoora dogfooding 第 2 候補)` |
| prompt-notes / sourcecode-judge-saas / doc-studio | spec | `spec (agoora dogfooding 第 3 候補)` |

`dogfooding_candidate: true` フィールド追加で機械可読化。

---

## 7. 反論余地 (R8)

1. **kintaeru は共同開発、agoora dogfooding で混乱**
   → 反論: 伊藤さんと事前合意 + notify-only mode で安全
2. **早期 PJ で実証 = 完成度低い顧客向けデモは逆効果**
   → 反論: 「Phase 0 → Phase 1 を agoora で X 時間で完成」は強力なデモ材料
3. **agoora 自体が未成熟、Tier 3 PJ に与えるリスク大**
   → 反論: Safety Breakwater L0-L3 で破壊操作は防御済 (ai-financial-office#77 pattern)
4. **dsi-factory は agoora と循環依存**
   → 反論: 循環依存は dsi-wizard + agoora の sister product 関係で OK

---

## 8. R10 一括承認

| # | 項目 | 推奨度 |
|---|------|--------|
| 1 | 本 doc 配置 + portal-config.yml 更新 | ★★★★★ 即実装 |
| 2 | kintaeru で agoora dogfooding 第 1 試行 (次セッション) | ★★★★★ |
| 3 | shiftweaver で Quick win 試行 (並行) | ★★★★ |
| 4 | dogfooding KPI を agoora-status.json + Live tab で可視化 | ★★★★ |
| 5 | 試行 3 件後、本 doc 更新 + agora#83 に追記 | ★★★ |

---

## 9. 関連

- `1-knowledge/usability-feedback-2026-05-11.md` (R83-R88 候補、本 dogfooding で追加)
- `1-knowledge/ai-financial-office-autonomous-analysis.md` (Tier 2 active の dogfooding 完了例)
- `1-knowledge/from-knowledge-to-action.md` (Phase 1.5「活かす」フェーズ)
- `1-knowledge/project-map-grand.md` (Tier 1/2/3 全体マップ)
- `4-portal/portal-config.yml` quard_products (本 commit で kintaeru 等更新)
- `4-portal/agents.yml` tenfold-rd / multi-llm-review (本 dogfooding で活用)
- [agora#40](https://github.com/riku1215/agora/issues/40) Cross-Repo Knowledge Transfer

`#agoora #dogfooding #tier-3 #validation #phase-1-5d`
