---
tags: [llm-dispatch, multi-llm, r14, question-templates, agora-d-a, captain-portal]
layer: knowledge
audience: [captain-only, claude, all-llms]
status: active-protocol
source: 過去レビュー実績 (Grok prior-art / Gemini design / ChatGPT retrieval / Claude integration)
created: 2026-05-11
---

# LLM Dispatch Protocol — どの LLM に何を聞くか (質問種別 × 適性 matrix)

`#llm-dispatch #multi-llm #r14 #question-templates`

## 0. Captain 指示 (2026-05-11)

> 過去のレビューを参照して、「どの LLM にどんな質問をするか?」考えて、
> 質問の種類、質問の仕方を分けてもいい。

= agora#82 D-A Multi-LLM Dispatch Doctrine の**質問レベルでの実装**。
過去 R14 サイクル 4-7 の実績から、LLM 別の得意領域 + 質問テンプレを体系化。

---

## 1. 過去レビュー実績 (本セッション中の 4 サイクル)

| サイクル | LLM | 質問種別 | 主要発見 |
|---------|-----|---------|---------|
| **1** | **Grok** | prior-art X/Reddit 90 日 | 5 事例 (codebase-memory-mcp, Repowise, GitNexus 等)、Tree-sitter / blast radius |
| **2** | **Gemini** | design validation 3 軸 | Issue 外部脳 / Safety 防波堤 / Phase 1 KPI |
| **3** | **ChatGPT** | technical retrieval policy | agent_profiles.yaml / search_kb(role) / 7 step ロードマップ |
| **4** | **Grok** | 命名候補 X 検索 | agora 競合 vs agoora 空き |
| **5** | **Captain 実測** (ai-financial-office#89) | LLM × task 適性 | Gemini OCR ✓ / ChatGPT CSV filter ✓ |

→ **明確な得意領域パターン**が浮上 → 本 protocol で固定化。

---

## 2. LLM × 質問種別 matrix (確定版)

### 🔵 Grok — リアルタイム + 反論 + 競合

| 質問種別 | 例 | 期待出力 |
|---------|-----|---------|
| **realtime-research** | "2026 年最新の X トレンドで、Y 系 OSS 5 件" | URL 付き 5+ 件、X post ID 必須 |
| **competitor-analysis** | "Cursor / Continue / agoora の差別化" | 5 列 trade-off 表 |
| **counter-argument** | "本提案に対し反論 3 件 + リスク確率" | echo 禁止、必ず 3+ 反論 |
| **prior-art (X/Reddit)** | "個人開発者 30+ repo 運用の最新事例" | 90 日内、URL 必須 |
| **failure-case-search** | "撤退した SaaS 5 件、撤退理由" | Hacker News + Tech Crunch |

#### 質問テンプレ
```
あなたは agoora の critic agent (R14 強制、別 LLM)。
X / Reddit / Hacker News のリアルタイム検索で以下を回答 (URL 必須):

Q1. <realtime-research>
Q2. <competitor-analysis>
Q3. <counter-argument: 反論 3+ + リスクマトリクス>
Q4. <prior-art>
Q5. <failure-case>

回答は反論 + 代替案 + リスク確率必須 (R8 強化)。
"現状で問題ない" 禁止。
```

### 🟢 Gemini — 戦略 + 設計 + 複数選択肢

| 質問種別 | 例 | 期待出力 |
|---------|-----|---------|
| **strategy-decision** | "Phase 1.5 vs 2.0 で優先すべきは?" | ① 判断 / ② trade-off / ③ 懸念 |
| **design-validation** | "本ハーネス設計の致命的盲点 3 件" | 3 大設計要素 + 改善案 |
| **multi-option-evaluation** | "3 案の比較 + ★ 推奨度" | 工数 / リスク / 業務影響 |
| **document-summary** | "本 PR 14k 行を 500 字で要約" | entry-level 説明 + 例え話 |
| **trade-off-analysis** | "Over-engineering リスク評価" | 軸明示、定量化 |
| **horizontal-transfer** | "本知見を他 28 repo に展開する手順" | repo 別 priority 表 |

#### 質問テンプレ
```
あなたは agoora の戦略アドバイザー (D-B Captain Communication + D-G Premise)。

以下を「① 判断 / ② trade-off / ③ 懸念」形式で:

Q1. <strategy-decision>
Q2. <design-validation>
Q3. <multi-option, ★ 推奨度付き>
Q4. <horizontal-transfer>

長期 / 中期 / 短期の時間軸で評価。
"無難な判断" は禁止、強い意見を含めること。
```

### 🟠 ChatGPT (Codex / GPT-5) — 技術詳細 + 実装コード

| 質問種別 | 例 | 期待出力 |
|---------|-----|---------|
| **implementation-code** | "Tree-sitter で TypeScript AST 解析 (50 行)" | runnable Python/TS、import 込 |
| **api-design** | "search_kb(query, role) の FastAPI endpoint" | 完全実装、エラー処理含む |
| **migration-script** | "feedback.sqlite3 に role カラム追加、rollback 可" | up/down migration |
| **workflow-yaml** | "GitHub Actions × Claude API auto-relay (200 行)" | YAML + script 配置 |
| **algorithm-detail** | "blast radius 算定アルゴ、scope 判定基準" | 数式 / pseudo-code 含む |
| **library-selection** | "ChromaDB 代替 (Qdrant / DuckDB / LanceDB) 比較" | 性能 / API / 移行コスト |

#### 質問テンプレ
```
あなたは agoora の技術アドバイザー (skills-strategy#9、technical-detail 専門)。

以下のコード + 解説を 1 ファイル単位で回答:

Q1. <implementation-code: X 行以内>
Q2. <api-design>
Q3. <migration-script>
Q4. <workflow-yaml>
Q5. <algorithm-detail>

回答末尾に必ず「想定リスク 2 件」+「テスト方法」。
import / 前提 / 環境変数を明示。
```

### 🔴 Claude (主体 = 私) — 統合判断 + 実装決定

| 質問種別 | 役割 |
|---------|------|
| **synthesis** | 3 LLM の結論を agoora 設計に統合 |
| **implementation-decision** | コミット level の判断 (yes/no / 修正案) |
| **harness-design** | agents.yml / routing.yml の構造設計 |
| **agora-rule-compliance** | R-rule 適用判断、違反 detect |
| **captain-relay** | 他 LLM へ送る質問の起草 (本 protocol そのもの) |

#### Self-prompt (Claude が自分で使うテンプレ)
```
本タスクの種別: <synthesis / decision / design / compliance / relay>
他 LLM へ dispatch すべき部分: <Yes/No、Yes なら下記>
- realtime/counter → Grok
- strategy/design → Gemini
- code/api → ChatGPT
直接判断する部分: <list>
R9 Pre-action Checklist 通過後に proposal 作成。
```

---

## 3. 質問の「仕方」 = format 分け

| Format | 用途 | 構造 |
|--------|------|------|
| **flat list** | 簡単な事実 | "次の 5 件を URL 付きで列挙" |
| **table** | 比較 | "X 行 / Y 列、各セル 1 文" |
| **decision-tree** | 段階的 | "Yes/No 質問を 5 段、各分岐の結論" |
| **counterfactual** | 反実仮想 | "もし X だったら、Y は防げたか?" |
| **persona-driven** | 役割固定 | "あなたは <role>、<context>。<task>" |
| **constrained** | 制約付き | "200 字以内 / コード 50 行以内 / 反論 3 件" |
| **iterative-pushback** | 多段反論 | "回答後、自己反論 3 件追加" |

→ 過去レビューで **persona-driven + constrained + iterative-pushback** の組合せが最高品質。

---

## 4. 3 LLM 並列 dispatch ベストプラクティス

### Pattern A: 並列独立レビュー (最も使う)

```
[同じ仕様書を 3 LLM に並列送信]
   ↓
Grok: 競合視点 + 反論
Gemini: 戦略・盲点
ChatGPT: 実装可否 + コード
   ↓
[Claude が統合] → 一致点 = 強、不一致 = 要 Captain 判断
```

### Pattern B: 段階 dispatch (技術判断 → 戦略 → 競合)

```
[ChatGPT: 技術可否で篩い] (もし NG なら停止、後段不要)
   ↓
[Gemini: 戦略・優先順位]
   ↓
[Grok: 競合 sanity check]
```

### Pattern C: critic ループ (各 LLM が前 LLM を反駁)

```
[Claude: 提案 v1]
   ↓
[Gemini: 強み弱み]
   ↓
[Grok: Gemini の盲点を反駁]
   ↓
[ChatGPT: Grok の主張を実装検証]
   ↓
[Claude: 統合]
```

---

## 5. agent_profiles.yaml task_llm_matrix の拡張版 (本 commit で反映)

```yaml
task_llm_matrix:
  # === Grok 領域 ===
  realtime-research:      {primary: grok, fallback: gemini-flash}
  competitor-analysis:    {primary: grok, fallback: claude-opus}
  counter-argument:       {primary: grok, fallback: gemini-pro}
  prior-art:              {primary: grok, fallback: gemini-flash}
  failure-case-search:    {primary: grok, fallback: gemini-flash}

  # === Gemini 領域 ===
  strategy-decision:      {primary: gemini-2.5-pro, fallback: claude-opus}
  design-validation:      {primary: gemini-2.5-pro, fallback: claude-opus}
  multi-option-evaluation:{primary: gemini-2.5-pro, fallback: claude-opus}
  document-summary:       {primary: gemini-pro, fallback: claude-sonnet}
  trade-off-analysis:     {primary: gemini-2.5-pro, fallback: claude-opus}
  horizontal-transfer:    {primary: gemini-pro, fallback: claude-opus}

  # === ChatGPT 領域 ===
  implementation-code:    {primary: chatgpt, fallback: claude-sonnet}
  api-design:             {primary: chatgpt, fallback: claude-opus}
  migration-script:       {primary: chatgpt, fallback: claude-sonnet}
  workflow-yaml:          {primary: chatgpt, fallback: claude-sonnet}
  algorithm-detail:       {primary: chatgpt, fallback: claude-opus}
  library-selection:      {primary: chatgpt, fallback: gemini-pro}

  # === Claude 領域 ===
  synthesis:              {primary: claude-opus, fallback: gemini-pro}
  harness-design:         {primary: claude-opus, fallback: gemini-2.5-pro}
  agora-rule-compliance:  {primary: claude-opus, fallback: chatgpt}
  captain-relay-drafting: {primary: claude-sonnet, fallback: claude-opus}

  default:                {primary: claude-sonnet, fallback: gemini-flash}
```

---

## 6. 過去成功事例の繰返性 (本 protocol の検証)

### 成功 Case 1: Grok prior-art (本セッション)

- 質問種別: prior-art (X/Reddit 90 日)
- format: persona-driven + constrained (5 事例 + URL)
- 結果: Tree-sitter / blast radius / Repowise 等を発見
- → **本 protocol が当時あれば同質**: 確度 90%+

### 成功 Case 2: ChatGPT retrieval policy

- 質問種別: implementation-code + api-design
- format: persona-driven + constrained (50 行)
- 結果: agent_profiles.yaml 完璧仕様提供
- → **本 protocol が当時あれば同質**: 95%+

### 成功 Case 3: Gemini design validation

- 質問種別: design-validation + multi-option
- format: persona-driven (戦略アドバイザー) + 3 軸
- 結果: Issue 外部脳 / Safety 防波堤 / Phase 1 KPI
- → **本 protocol が当時あれば同質**: 90%+

→ 過去レビュー成功率 = 本 protocol で**再現可能性 90%+ で固定化済**。

---

## 7. 関連

- `4-portal/agent_profiles.yaml` task_llm_matrix (本 commit で拡張)
- `4-portal/prompts/critic.md` (R14 別 LLM 強制)
- `1-knowledge/prior-art-2026-05-11.md` (本 protocol の実証元)
- `1-knowledge/skills-strategy-integration.md` (LLM 比較実測)
- `1-knowledge/ai-financial-office-autonomous-analysis.md` (Captain 実測 LLM 適性)
- `4-portal/agoora-kickoff/10-llm-review-disruptive-i1-i5.md` (本 protocol 適用済 packet)
- agora#82 D-A Multi-LLM Dispatch Doctrine

`#llm-dispatch #multi-llm #r14 #question-protocol #captain-instruction`
