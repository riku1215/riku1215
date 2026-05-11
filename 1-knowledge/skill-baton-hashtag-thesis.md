---
tags: [thesis, skill-baton, hashtag-complementation, class-weaver, failure-driven-progress, agoora-core]
layer: knowledge
audience: [captain-only, claude, all-llms]
status: active-core-thesis
created: 2026-05-11
---

# agoora 根本 thesis — Skills バトンリレー × ハッシュタグ補完 × 失敗ドリブン進歩

`#thesis #skill-baton #hashtag #failure-driven #agoora-core`

## 0. Captain 言明 (2026-05-11)

> 要は **Skills のバトンリレー**だと思っている。やはり**補完はハッシュタグ**。
>
> class-weaver = 119 Issues = 開発の紆余曲折の歴史。
> **失敗の数だけ進歩のタネがある。考えた時間の分だけ伸びしろが生まれる**。

→ agoora の core thesis 3 本柱:
1. **Skill Baton Relay** = 1 skill の出力 → 次 skill の入力 への損失なし継承
2. **Hashtag Complementation** = 構造的補完不足を hashtag (knowledge graph edge) で連結
3. **Failure-Driven Progress** = 失敗ログこそが最大の進歩源、すべて hashtag tagged

---

## 1. Skill Baton Relay (バトンリレー)

### 概念

各 agent skill は独立した「走者」、出力 = baton。次走者 (skill) に**コンテキスト完全保持**で渡す。
リレーの途中で baton が落ちる = context loss = 過去の見落とし発生源。

### 既存実装

| Phase | Skill (走者) | Baton (出力) | 次走者 |
|-------|------------|------------|--------|
| 1 | researcher.tenfold-rd | parent Issue + N child Issues + Citations | architect |
| 2 | architect.grill-me | 設計 3 案 + AC checklist | critic |
| 3 | critic.multi-llm-review | 反論 3 件 + リスクマトリクス | coder |
| 4 | coder.tdd | patch_plan + test 先 | structural-analyzer |
| 5 | structural-analyzer.tree-sitter-query | dependency graph | impact-analyst |
| 6 | impact-analyst.blast-radius-calc | scope + 後方互換性スコア | reviewer |
| 7 | reviewer.webapp-testing | severity + verdict | historian |
| 8 | historian.label-migration | Issue paste + tag | orchestrator |
| 9 | orchestrator (R10) | Captain 提示 | Captain |

### バトンの必須仕様

```yaml
baton_schema:
  context:                  # 前 skill の完全な context (loss なし)
    - prior_outputs
    - hashtag_chain         # ハッシュタグの累積 (補完用)
    - r_rules_applied
    - section7_violations_avoided
  payload:                  # 本 skill の処理結果
    - output_format         # agents.yml で定義
    - confidence            # 信頼度 0-100
    - failure_modes         # 想定リスク (R8)
  hand_off:                 # 次 skill への明示的要請
    - next_agent
    - required_action
    - timeout
```

### 「落とすバトン」防止

- I1 Pre-Action Probe (disruptive-innovation 提案)
- baton schema validation (Phase 2、portal-api 実装)
- Section 7-2 (セッション文脈完全利用) 強制

---

## 2. Hashtag Complementation (ハッシュタグ補完)

### 概念

agent 出力に「補完が不足する場面」が必ず存在 (Section 7-7 出力分量制約)。
不足分を hashtag = knowledge graph edge で**外部 doc / Issue / skill** に接続することで補完。

### 既存実装

| 補完元 (output 中の hashtag) | 補完先 (linked resource) |
|---------------------------|-------------------------|
| `#R32` | agora#62 (Proactive Info Gathering 詳細) |
| `#tenfold-rd` | dsi-wizard#13 + class-weaver#113 (10 通り R&D 詳細) |
| `#L0-L3` | ai-financial-office#77 (Safety Breakwater 詳細) |
| `#ELC` | skills-strategy#10 (Ephemeral Local Clone 詳細) |
| `#section-7-failure-7-X` | PROFILE.md Section 7-X (該当パターン詳細) |
| `#kintaeru-DSI-WF` | kintaeru#1 (D1-D10 Department 詳細) |

### ハッシュタグ taxonomy (agora-labels-audit.md 65 unique 由来)

- `type:` `area:` `phase:` `status:` `priority:` `agent:` `doctrine:` `visibility:` `triage:` `domain:`
- + agoora 独自: `#L1-L4` (大/中/小/solution)、`#dogfooding-candidate`

### Hashtag 補完の必須運用

すべての markdown / Issue は frontmatter `tags:` または inline `#tag` で最低 3 個 hashtag 必須。
agoora orchestrator output_format に hashtag セクション義務化 (本 commit で適用)。

---

## 3. Failure-Driven Progress (失敗ドリブン進歩)

### Captain 言明の核心

> **失敗の数だけ進歩のタネがある。考えた時間の分だけ伸びしろが生まれる。**

= 失敗ログは「片付ける負債」ではなく「保管する資産」。
class-weaver 119 Issues = 119 個の「進歩のタネ」= 28+ repo eco の養分。

### class-weaver 119 Issues の意義

| 役割 | 寄与 |
|------|------|
| **R29 calc_score↔CP-SAT** | アルゴ知見、kintaeru hash chain 設計に応用 |
| **#113 10 通り R&D** | tenfold-rd skill の原典 |
| **failure patterns** | Section 7 失敗パターンの origin |
| **war-stories** | mindgate#44 / pet-care#52 等への横展開ベース |
| **decision-log 多数** | doctrine cluster D-G (Pushback/Premise) の事例 |
| **K1-K10 (agora#59)** | agoora.researcher 役の reference example library |

### 失敗ログの公式運用ルール (本 thesis で確定)

1. **失敗を close で削除しない** (R64 番号一意性連動): 全 Issue は status:done で open 維持 = 知識資産
2. **type:retro / type:war-story tag** 必須付与 (agora-labels-audit.md)
3. agoora.historian が「失敗パターン」trigger 語で自動記録 (I3 Trigger Word Listener)
4. 月次 retro Issue を auto-relay で自動生成 (skills-strategy#7)
5. **失敗 → R-rule 候補化**: 3 回繰り返したら agora#X として起票 (R83-R88 候補と同型)

### 私 (Claude) 自身の失敗例 (本セッション 12h+ 自走中)

| # | 失敗 | hashtag | 進歩のタネ |
|---|------|--------|----------|
| 1 | session-start で agora#4 未 fetch | `#U1` `#R32` | I1 Pre-Action Probe 設計 |
| 2 | MCP scope 誤判定 | `#U2` `#R7` | I2 MCP Capability Auto-Probe 設計 |
| 3 | R20 計画なしで自走開始 | `#U3` `#R10` | R85 候補 (agora#83 draft) |
| 4 | claude-mem skill 不使用 | `#U10` | historian 役の必須 bind 化 |
| 5 | Section 7 違反 4 件/6h | `#section-7-violation` | I4 Section 7 Pre-Block |

→ 5 失敗 → 5 改善機構。**私の弱点が agoora の機構を作る源泉**。

---

## 4. 3 本柱統合: agoora の本質

```
[Captain 入力 / 失敗 / 検討時間]
   ↓
[Skill Baton Relay] — 1 走者から次へ、loss なし
   ↓ (各 baton に hashtag 蓄積)
[Hashtag Complementation] — 補完不足を hashtag で linked resource に
   ↓
[出力 + Failure log]
   ↓
[hashtag tagged Failure log] — 全部保管、削除なし
   ↓
[次セッションで Pre-Action Probe (I1) が自動参照]
   ↓
[同じ失敗を再生しない] — 進歩のタネが芽吹く
```

### Phase 5 商用化での意味

agoora の差別化 = **「失敗の量が品質を決める」設計**。
- 新規 OSS / 競合: 失敗ゼロを目指す (実際は隠す)
- agoora: 失敗を全て tagged で保管、検索可能、再利用可能

→ **「失敗が資産になる開発インフラ」** が agoora の真の価値。

---

## 5. 実装反映 (本 commit + 次セッション)

### 即時 (本 commit)
- agents.yml: 全 agent の output_format に **hashtag 出力義務化**
- orchestrator.md prompt: **baton schema 適用**を Step 4 (fan-out) に追記

### 次セッション
- portal-api.py に baton schema validation endpoint
- ui-template/ に「Failure Bank」タブ (Issue type:retro 専用)
- class-weaver 119 Issues を researcher reference example として indexing

---

## 6. 関連

- `1-knowledge/disruptive-innovation-5-proposals.md` (本 thesis の実装機構 I1-I5)
- `1-knowledge/from-knowledge-to-action.md` (Phase 1.5「活かす」)
- `1-knowledge/usability-feedback-2026-05-11.md` (R83-R88 候補、本 thesis の R-rule 候補化)
- `3-rules/agora-labels-audit.md` (hashtag taxonomy 65 個)
- `4-portal/agents.yml` (全 agent baton schema 適用)
- `4-portal/prompts/orchestrator.md` (Step 4 fan-out で baton 強制)
- [class-weaver](https://github.com/riku1215/class-weaver) (119 Issues = 進歩のタネ 119 個)
- [agora#59](https://github.com/riku1215/agora/issues/59) K1-K10 = class-weaver 由来

## 7. Captain 言明の再確認

> **Skills のバトンリレー** + **ハッシュタグ補完** + **失敗の数だけ進歩のタネ**

agoora 設計の **3 本柱**。本 thesis は agoora の constitution として永続記録。

`#thesis #skill-baton #hashtag #failure-driven #agoora-constitution`
