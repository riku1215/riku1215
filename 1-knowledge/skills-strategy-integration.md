---
tags: [skills-strategy, integration, agoora, instructions-over-skills, elc, impact-analyst]
layer: knowledge
audience: [captain-only, claude]
status: active
source: riku1215/skills-strategy-analysis (11 Issues、2026-05-11 fetch)
---

# skills-strategy-analysis → agoora 統合 (7 大発見)

`#skills-strategy #agoora-integration`

## 0. サマリ (200 字)

skills-strategy-analysis の 11 Issues から **agoora 開発に直接活かせる 7 大発見**を抽出。
**最重要**: ①Instructions が Skills より 2-6x 効く ②spec-change-impact-analyzer = agoora の impact-analyst と完全同型 ③ELC (Ephemeral Local Clone) = agoora Safety Breakwater の完成形パターン。これら 3 件を即時 agoora に統合反映する。

---

## 1. 7 大発見 (★ 重要度)

### ★★★★★ F1: Instructions > Skills (2-6 倍効果差)

**出典**: skills-strategy#2 (実測データ、犬猫 PJ 5 ヶ月)

| 観点 | Instructions (CLAUDE.md) | Skills |
|------|------------------------|--------|
| 性質 | 宣言型 (常時自動適用) | 手続き型 (呼出時のみ) |
| 月効果 | **15-45 時間節約** | 8 時間節約 |
| ROI | 1-4h 作成 → 永続効果 | 5-50h 作成 → 単発 |
| Claude Code 比重 | **70%** | 30% |

**agoora への反映**:
- Phase 0.1 per-domain CLAUDE.md 生成 = **正しい投資方向** ✓ (Task 5 で実装済)
- 47 skills → Top 15 厳選優先度 ↑ (F2 参照)
- agora#83 候補 R88: **「CLAUDE.md 投資優先原則」**

### ★★★★★ F2: spec-change-impact-analyzer = agoora impact-analyst と完全同型

**出典**: skills-strategy#4

skills-strategy が既に**完璧な仕様**を起草済:
```yaml
spec-change-impact-analyzer:
  入力: [変更要件 (自然言語), ソースコードディレクトリ]
  出力:
    - 影響を受ける API 一覧
    - 影響を受ける画面/帳票
    - 影響を受ける DB テーブル
    - 影響を受ける設計書セクション
    - 再テスト必要範囲
    - 見積もり工数 (参考値)
  手順:
    1. 変更内容を LLM が解釈
    2. 関連コードを AST レベルで追跡 (= Tree-sitter)
    3. 依存グラフから影響範囲抽出 (= NetworkX)
    4. レポート生成
  失敗パターン回避:
    - 「全機能影響」と曖昧に返すのを禁止
    - 必ず具体的ファイル・メソッド単位
    - 見積もりは参考値と明示
```

**agoora への反映**:
- agents.yml `impact-analyst` の `output_format` を本仕様で全置換
- Tree-sitter PoC (2-intelligence/structural-search/) が本実装の基盤
- 失敗パターン (曖昧結論禁止) を `routing.yml impact-analysis` の always_apply に追加

### ★★★★★ F3: ELC = Ephemeral Local Clone (状態管理パラダイム)

**出典**: skills-strategy#10

> VS Code を使いたい時だけ local に clone → 作業 → push → `rm -rf` で消去。
> local は "所有" ではなく "借用"、状態を **GitHub repo 側にのみ永続化**。

| Tier | 名称 | 用途 |
|------|------|------|
| T1 | **ELC** | 主軸 — VS Code / npm test / docker / F5 |
| T2 | API-only | 軽作業 — Issue/PR/設定 |
| T3 | Codespaces | 緊急時・特殊環境 |

```bash
# gh alias 標準化
gh rent riku1215/agoora      # mktemp に clone + VS Code
# ... 作業 ...
gh return                     # PR merge + rm -rf
```

**Safety Rails**:
- Draft PR を 30 分以内に起票 (消失耐性の肝)
- `rm -rf` 前 `git status` guard
- node_modules / dist は push 対象除外

**agoora への反映**:
- `protocol.md §10 Safety Breakwater` を本パターンで強化
- `gh rent` / `gh return` を agoora workflow に組込み
- D ドライブ消失事故と同型の事故防止 (本 Captain 2026-04-19 経験)

### ★★★★ F4: 59 Skills → Top 15 厳選原則

**出典**: skills-strategy#5

- 実効果: 59 Skills 中 **8-10 本 (14-17%)** のみ使用
- 認知負荷削減: 59 → 15 で「名前覚えられない問題」解消
- 統合・削除基準明示

**agoora への反映**:
- 現 47 skills も同じ問題 (10 個未満しか活用されていない可能性)
- find-skills UI で **使用頻度 + 効果** で sort
- agents.yml の各役割の skill を 3-5 個に limit (既に対応済 ✓)

### ★★★★ F5: 4 痛点 4 領域 Skills 新設候補

**出典**: skills-strategy#6

| 領域 | 新規 Skill | agoora 対応役 |
|------|-----------|--------------|
| SRE / 本番運用 | sre-monitoring-generator, incident-response-playbook | reviewer / impact-analyst |
| データ分析 / BI | bi-query-and-dashboard-generator | researcher |
| オフショア | offshore-task-handoff-generator | (Phase 5 商用化時) |
| LLM / AI | llm-integration-designer | architect |

→ agoora.skills (Phase 2) で本 5 skill を作成予定。

### ★★★ F6: 四半期レビュープロセス + CoE

**出典**: skills-strategy#7, #8

- Skills 月次使用頻度監視
- 削除候補自動抽出
- 業種別代表 + 技術リード CoE

**agoora への反映**:
- portal-api.py `/healthz` に skills 使用頻度を含める
- 月次 retro Issue を auto-relay で自動生成

### ★★★ F7: Copilot Instructions 仕組み

**出典**: skills-strategy#9

- `.github/copilot-instructions.md` = リポジトリルートのみ自動読込
- agoora の `CLAUDE.md` と同型機能
- 業種別雛形 (公共/金融/小売) を集中管理 + sync

**agoora への反映**:
- `.github/copilot-instructions.md` を本 repo にも配置 (Phase 0.1 完了基準)
- Captain の業種 = QUARD AI 開発、agoora で雛形

---

## 2. 即時統合提案 (本 PR #19 内 or 次セッション)

### A. agents.yml impact-analyst を spec-change-impact-analyzer 仕様で再定義 ★★★★★

```yaml
impact-analyst:
  output_format:
    - 影響を受ける API 一覧 (具体的なファイル + メソッド)
    - 影響を受ける画面/帳票
    - 影響を受ける DB テーブル
    - 影響を受ける設計書セクション
    - 再テスト必要範囲
    - 見積もり工数 (参考値、明示)
  failure_patterns_to_avoid:    # ★ 必須
    - 「全機能影響」と曖昧に返すこと
    - メソッド単位での具体化不足
    - 見積もりを断定すること
```

### B. protocol.md §10 Safety Breakwater に ELC 統合 ★★★★★

```markdown
## §10b. ELC (Ephemeral Local Clone) Pattern

Captain の VS Code 作業時:
1. gh rent riku1215/agoora     # mktemp + clone + VS Code
2. Draft PR を 30 分以内起票
3. 作業中も push 継続
4. gh return                    # merge + rm -rf

不変条件: 作業終了時、ローカルにどの clone も残らない。
```

### C. .github/copilot-instructions.md 配置 ★★★★

`CLAUDE.md` と同内容 (`@PROFILE.md` import) で配置、Copilot 利用時も同 instruction 適用。

---

## 3. agoora の優位性 (skills-strategy より進化した点)

| skills-strategy | agoora |
|----------------|--------|
| Skills 60 → 15 厳選 | **agents.yml で 10 役、各役 3-5 skills** = 最初から正解 |
| Instructions 業種別 3 雛形 | **per-domain CLAUDE.md 5 個** + R-rules 強制 import |
| spec-change-impact-analyzer 単発 Skill | **structural-analyzer + impact-analyst の 2 役 chain** |
| ELC 提案のみ | **Safety Breakwater + auto-relay で実装可能** |
| 四半期レビュー手動 | **auto-relay で月次自動生成可** |

→ agoora は skills-strategy の**集合知 + ハーネス化**で 1 段階上。

---

## 4. dsi-kit-library 調査は context 制限で本セッション保留

riku1215/dsi-kit-library Issues fetch は **86KB の results** 取得済、本セッションで完全 parse は context 制約。
次セッション (新 scope) で完全取込 + 本 doc に追加更新推奨。

agora#40 既知情報:
- dsi-kit-library = Tier 1 mature
- DSI Auto-Scaffold Pipeline (dsi-factory) の library 部
- paw-sensor からの DSI 提案 (dsi-kit#194) で「新規 PJ 立ち上げ完全自動化 stack」完成

agoora 統合:
- agoora を **dsi-kit 適用第 N 号** として位置付け
- Phase 2 で dsi-wizard / dsi-improver と連携

---

## 5. 関連

- [skills-strategy#2](https://github.com/riku1215/skills-strategy-analysis/issues/2) Instructions vs Skills
- [skills-strategy#4](https://github.com/riku1215/skills-strategy-analysis/issues/4) spec-change-impact-analyzer
- [skills-strategy#5](https://github.com/riku1215/skills-strategy-analysis/issues/5) 59→15 厳選
- [skills-strategy#6](https://github.com/riku1215/skills-strategy-analysis/issues/6) Phase 2 痛点 4 領域
- [skills-strategy#9](https://github.com/riku1215/skills-strategy-analysis/issues/9) Copilot Instructions
- [skills-strategy#10](https://github.com/riku1215/skills-strategy-analysis/issues/10) ELC 提案
- 本 repo: `4-portal/agents.yml` impact-analyst
- 本 repo: `4-portal/protocol.md` §10 Safety Breakwater
- 本 repo: `1-knowledge/project-map-grand.md`
- [agora#40](https://github.com/riku1215/agora/issues/40) Cross-Repo Knowledge Transfer

`#skills-strategy #integration #agoora #instructions-over-skills #elc`
