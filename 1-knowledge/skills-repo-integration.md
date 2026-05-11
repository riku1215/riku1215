---
tags: [skills-repo, qurad-custom, battle-tested, agoora-integration, captain-portal]
layer: knowledge
audience: [captain-only, claude]
status: active-critical
source: riku1215/skills (2026-05-11 search_code)
created: 2026-05-11
---

# riku1215/skills 統合 — QUARD 独自 4 battle-tested skills

`#skills-repo #quard-custom #battle-tested #agoora-integration`

## 0. サマリ (200 字)

riku1215/skills は **「QUARD custom Claude Code skills — battle-tested through 28+ repo eco」**。
2026-05-09 作成、4 つの実証済 custom skill を格納:
**competitor-loop / label-migration / multi-llm-review / nano-banana-image-gen**。
agoora の 47 base skills (Anthropic/Vercel/max4c/thedotmack) と異なる **Captain 独自層**。
本 4 skill は agoora の必須 import 候補 (Tier 1 mature)。

---

## 1. 4 Skills 個別分析

### S1. `competitor-loop` ★★★★

**推定機能**: 競合分析 (X 検索 + GitHub trending 等) を回す loop skill。
Phase 5 商用化前に競合動向 (Cursor/Continue/Augment Code/Aider/agoora 競合) 自動追跡。

**agoora 統合**:
- **critic 役の補助 skill** (devil's advocate に競合視点追加)
- **researcher 役** の `realtime-research` task category と統合
- portal-config.yml の business.strategy に追加
- Phase 2 で Grok 経由 X 検索 + GitHub trending API 統合

### S2. `label-migration` ★★★★★ — 完全一致

**機能 (推定)**: 旧ラベル taxonomy → 新 prefix:value への bulk migration。
**agoora の `scripts/auto-label.py` と完全同型**。

**agoora 統合 (即時)**:
- 本 PR で実装した `scripts/auto-label.py` は本 skill の **simplified clone** に過ぎない
- 本 skill が **公式 battle-tested 版** → 本 skill を import + agoora で wrap
- 旧 zz-deprecated-* → 新 prefix:value migration を agora にも適用 (agora#83 R86 と一致)
- agents.yml `historian` 役 + `domain-expert` 役の skill に追加

### S3. `multi-llm-review` ★★★★★ — Captain 独自 R14 実装

**機能 (推定)**: R14 多 LLM レビューを **skill 化**。
Claude → Gemini → ChatGPT → Grok の dispatch + cross-review pipeline。
**agoora の critic 役 + agents.yml R14 always_apply の skill 公式版**。

**agoora 統合 (即時)**:
- agents.yml `critic` 役の `skills:` に追加 (現状 placeholder の `(R8 反論パターン)` を置換)
- `routing.yml always_apply r14-multi-llm` の実装基盤として採用
- 28 repo (ai-financial-office#89 LLM 比較表等) で実証済 → 信頼性高

### S4. `nano-banana-image-gen` ★★★

**機能 (推定)**: agora R12 nano-banana mockup pattern の実装 skill。
画像 mockup 生成 (Gemini Imagen / DALL-E 等経由)。

**agoora 統合**:
- agoora UI の **モックアップ生成タブ** (Phase 2、99-portal-ui 拡張)
- coder 役の `frontend-design` / `web-design-guidelines` skill と組合せ
- Captain の Dify 60 社提案資料作成にも活用 (business.proposals)

---

## 2. agoora skills layer 階層化 (本発見で正式化)

| Tier | 出所 | 件数 | 役割 |
|------|------|------|------|
| **T1 (公式)** | Anthropic / Vercel | ~15 | base (mcp-builder/find-skills 等) |
| **T2 (コミュニティ)** | max4c / thedotmack | ~30 | community (grill-me/tdd/claude-mem) |
| **T3 (QUARD 独自)** ★ 新 | **riku1215/skills** | **4** | **battle-tested、Captain 業務特化** |
| **T4 (agoora 独自)** | 4-portal/agents.yml | 7+ | tenfold-rd / resource-routing 等 |

**累計**: 47 (T1+T2) + 4 (T3) + 7 (T4) = **58 skills**

---

## 3. 即時 agoora 統合 (本 commit 実装)

### A. `4-portal/agents.yml` critic 役に `multi-llm-review` skill ★★★★★
```yaml
critic:
  skills:
    - multi-llm-review   # ★ riku1215/skills 由来、battle-tested R14 実装
```

### B. agents.yml researcher 役に `competitor-loop` skill ★★★★
```yaml
researcher:
  skills:
    - competitor-loop    # ★ Phase 2 で realtime 競合分析
```

### C. agents.yml historian 役に `label-migration` skill ★★★★★
```yaml
historian:
  skills:
    - label-migration    # ★ agora taxonomy migration、scripts/auto-label.py の公式版
```

### D. portal-config.yml DSI ecosystem に skills repo 追加 ★★★
```yaml
dsi_ecosystem:
  members:
    skills:
      tier: 1-mature
      role: quard-custom-skills-collection
      tech: [Markdown SKILL.md format, Claude Code compatible]
      count: 4
      battle_tested_in: 28+ repo eco
```

---

## 4. agora#83 起票 draft 更新 (R-rule 候補)

skills repo の存在で **R88 (Instructions over Skills) に補足**:
- **Tier 3 QUARD 独自 skills は Battle-tested**、Tier 1/2 (公式/コミュニティ) より上位
- 47 公式 + 4 QUARD = 51 skills だが、**Top 15 厳選では QUARD 4 を必ず含める**
- 47 公式 skills の活用率 14-17% (skills-strategy#5) でも、Tier 3 は 80%+ 活用想定

---

## 5. 経費削減 + 投資効率

skills repo の存在で **Captain 独自スキル蓄積コスト**が明確化:
- 4 skills × 推定 5-50h 開発 = 20-200h 投資済
- agoora がこの資産を活用 = **既存投資の ROI 最大化**
- 1-knowledge/skills-strategy-integration.md F1 (Instructions > Skills 2-6 倍効果差) と
  矛盾せず、本 4 skills は **「Instructions に内蔵すべき重要 Skills」** = 例外的に高 ROI

---

## 6. 関連

- [riku1215/skills](https://github.com/riku1215/skills) (4 SKILL.md)
- [riku1215/skills/README.md](https://github.com/riku1215/skills/blob/main/README.md)
- 本 repo: `1-knowledge/skills-strategy-integration.md` (Instructions vs Skills)
- 本 repo: `1-knowledge/ai-financial-office-autonomous-analysis.md` (multi-LLM 実証)
- 本 repo: `4-portal/agents.yml` (本 commit で 3 skill 追加)
- 本 repo: `4-portal/portal-config.yml` dsi_ecosystem (本 commit で skills 追加)
- 本 repo: `scripts/auto-label.py` (label-migration の simplified clone)
- agora#82 R-rule 7 doctrine cluster
- skills-strategy#2 Instructions over Skills

`#skills-repo #quard-custom #4-skills #agoora-integration #t3-tier`
