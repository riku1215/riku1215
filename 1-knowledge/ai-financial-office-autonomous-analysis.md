---
tags: [ai-financial-office, autonomous-run, multi-llm, r22, r32, dogfooding, agoora-integration]
layer: knowledge
audience: [captain-only, claude]
status: active
source: riku1215/ai-financial-office (63 Issues、search_issues 経由、2026-05-11 fetch)
---

# ai-financial-office 自走分析 — agoora dogfooding 事例として

`#autonomous-run #multi-llm #r22 #r32 #ai-financial-office #dogfooding`

## 0. サマリ (200 字)

ai-financial-office (63 Issues) は **multi-LLM クロスレビュー自走の完成形** dogfooding 事例。
agora R22 (資料受領 自動 destination) + R32 (Proactive Info Gathering) + K6 (親+sub 分割) を
完全実装。Phase 0/1/2 で工数明記 sub-issue、L0-L2 自動化レベル分類、LLM 比較実証データ等、
**agoora が再現すべき 5 パターン**が揃う。本分析を agoora.researcher 役の参考事例ライブラリ化。

---

## 1. 5 大パターン (agoora 統合候補)

### P1. R22 適用 1 例目 — 資料受領 自動 destination + sub-issue 化 ★★★★★

**事例**: ai-financial-office#89 (2026-05-03)

```
Captain が .docx 共有
   ↓
Claude session が agora#59 K22 適用
   ↓
28 repo から ai-financial-office を 自動選択 (主題が確定申告 + 帳簿整理)
   ↓
親 Issue #89 起票:
  - 5 use-case (U1-U5) 抽出 + 推奨度 (★)
  - 既存 fit 識別 (#81 #79 等への接続提案)
  - LLM 比較実証データ含む
   ↓
sub-issue 5 件起票候補 (各 use-case ごと)
   ↓
GHCP/Codex に assign で並列 PR
```

**agoora 統合**: researcher 役の `tenfold-rd` skill 拡張、または **新規 skill `resource-routing`** として実装:
- 入力: 資料 (docx/pdf/url 等)
- 自動選択: 28 repo から主題に合う 1-3 repo
- 出力: 親 Issue (use-case 抽出 + ★) + sub-issue 候補リスト

### P2. K6 (親+sub) Issue 分割 with 工数明記 ★★★★★

**事例**: #66 親 + 8 sub-issues (#76-#83)

| Phase | sub-issue | 工数 | 完了 |
|-------|----------|------|------|
| P0-1 | 代行業務 ToDo 管理 | 8-12h | ✓ #76 |
| P0-2 | バルク承認 (50 件) | 4-6h | ✓ #77 |
| P0-3 | 月次成果物自動配信 | 6-8h | (#78) |
| P1-1 | 月次クロージング オーケストレーション | 12-16h | — |
| P1-2 | スタッフ別 work load ダッシュボード | 8-10h | — |
| P1-3 | 紙領収書スキャン整理 | 6-8h | — |
| P2-1 | LTV / 工数 / 利益率 ダッシュボード | 10-14h | — |
| P2-2 | 内部 → SaaS 切出 | 16-20h | — |

→ **Phase 別工数集計 + 完了率 25%** を親 Issue body で可視化
→ 各 sub-issue に **Acceptance Criteria + 依存 + 関連 docs** 明示

**agoora 統合**:
- agents.yml `architect` 役の output_format に **工数 (8-12h 形式)** + **AC checklist** 追加
- routing.yml `new-feature` pipeline で **sub-issue 自動分割** を tenfold-rd skill に bind
- portal-config.yml に sub-issue / phase の対応構造を schema 化

### P3. multi-LLM 比較実証データ ★★★★★

**事例**: #89 で LLM provider 比較 (実測)

| Task | Gemini Pro | ChatGPT Pro | Claude |
|------|-----------|------------|--------|
| 領収書 OCR | ✅ 可 | ❌ 不可 | 未試行 |
| CSV filter | ❌ 不可 | ✅ 可 | 未試行 |

→ **R14 多 LLM 強制の実証根拠**
→ task-LLM matrix を持つことで適切な dispatcher が可能

**agoora 統合**:
- `agents.yml` の各役の `llm.primary/fallback` を **task 種別 × LLM 適性表** で動的選択
- `agent_profiles.yaml` に task_llm_matrix 追加:
  ```yaml
  task_llm_matrix:
    ocr-receipt:    {primary: gemini-pro, fallback: claude-opus}
    csv-filter:     {primary: chatgpt, fallback: gemini-pro}
    code-review:    {primary: chatgpt, fallback: claude}
    counter-arg:    {primary: grok, fallback: gemini}
    architecture:   {primary: claude-opus, fallback: gemini-pro}
  ```

### P4. L0/L1/L2 自動化レベル分類 ★★★★

**事例**: #77 バルク承認

- **L0/L1**: 1-クリック承認可 (低リスク、自動化対象)
- **L2 以下**: 手動 (誤承認防止)
- 50 件超 → 警告表示

→ **Safety Breakwater の階層化モデル**

**agoora 統合**:
- protocol.md §10 Safety Breakwater に L0-L3 階層を追加:
  - L0: read-only / dry-run → 即実行
  - L1: ローカル file edit → 自動実行
  - L2: git commit / API call → Captain 確認 (R10)
  - L3: 破壊操作 (rm -rf, push --force) → 二重承認
- `agents.yml coder` 役の Safety Breakwater 制約として明文化

### P5. docs/autonomous-run-template.md (進行中活用) ★★★★

**事例**: ai-financial-office 内に既存

agora#59 K1-K10 由来の 5 段階自走テンプレが**実プロジェクトで稼働中**。
→ agoora の routing.yml + protocol.md と接続可能。

**agoora 統合**:
- ai-financial-office の `docs/autonomous-run-template.md` を agoora に転記 / link
- agora#60 (paw-sensor) と統合した自走テンプレ統一版を作成

---

## 2. agoora 即時取込アクション (R10 一括)

| # | アクション | 推奨度 | 工数 |
|---|-----------|--------|------|
| 1 | agent_profiles.yaml に `task_llm_matrix` 追加 (P3) | ★★★★★ | 30 分 |
| 2 | protocol.md §10 に L0-L3 階層 (P4) | ★★★★★ | 20 分 |
| 3 | architect 役 output_format に「工数 + AC checklist」 (P2) | ★★★★ | 20 分 |
| 4 | researcher 役に `resource-routing` skill (P1) | ★★★★ | 1h |
| 5 | docs/autonomous-run-template.md を agoora に転記 (P5) | ★★★ | 1h |

→ 本 commit で #1-#3 を実装、#4-#5 は次セッション queue。

---

## 3. agoora researcher 役の参考事例ライブラリ化

ai-financial-office#89 は「資料 1 つから 5 use-case + 28 repo 自動振分 + sub-issue 候補」 を
**1 回の操作で実現**した実例。これを agoora の researcher 役の reference として永続記録:

```yaml
# 4-portal/agents.yml researcher.reference_examples (新追加候補)
researcher:
  reference_examples:
    - example_id: ai-financial-office-89
      pattern: R22 適用 (資料受領 自動 destination + sub-issue)
      url: https://github.com/riku1215/ai-financial-office/issues/89
      use_when: ".docx / .pdf 受領 + 28 repo から主題自動判定"
    - example_id: ai-financial-office-66
      pattern: K6 親+sub 工数明記分割
      url: https://github.com/riku1215/ai-financial-office/issues/66
      use_when: "大型機能を Phase 0/1/2 に分割 + sub-issue 起票"
```

---

## 4. ラベル分析 (ai-financial-office 内 taxonomy)

ai-financial-office のラベル体系:
- **milestone-q2 / q3 / q4** (時期別)
- **strategy / marketing / infra / production**
- **implementation / decision-log**
- **P1-supabase** (テクニカル領域)

→ agora の 65 unique label とは異なる **simpler な flat 構造**。
→ agoora-labels-audit.md 提案の prefix:value 移行候補。

**移行案**:
- `milestone-q2` → `phase:02` または `milestone:q2`
- `strategy` → `type:strategy`
- `implementation` → `type:implementation`
- `infra` → `area:infra-runtime`

---

## 5. 関連

- [ai-financial-office#66](https://github.com/riku1215/ai-financial-office/issues/66) 親 Issue + 8 sub
- [ai-financial-office#89](https://github.com/riku1215/ai-financial-office/issues/89) R22 適用 1 例目
- [ai-financial-office#77](https://github.com/riku1215/ai-financial-office/issues/77) L0/L1/L2 分類
- ai-financial-office `docs/autonomous-run-template.md` (進行中 dogfooding)
- [agora#59](https://github.com/riku1215/agora/issues/59) K1-K10 + K22 knowledge hub
- [agora#62](https://github.com/riku1215/agora/issues/62) R32 Proactive Info Gathering
- 本 repo `4-portal/agents.yml` (researcher 役、本 commit で task_llm_matrix 追加)
- 本 repo `4-portal/protocol.md` (§10 Safety Breakwater、本 commit で L0-L3 階層化)
- 本 repo `1-knowledge/usability-feedback-2026-05-11.md` (R83-R87 候補と統合)

`#ai-financial-office #autonomous-run #r22 #r32 #dogfooding #agoora`
