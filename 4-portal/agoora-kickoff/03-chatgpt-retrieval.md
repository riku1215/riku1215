# コメント 3/6 — ChatGPT retrieval policy 提案

> R14 サイクル: **ChatGPT (Codex / GPT-5)** (技術詳細・実装提案)
> 実施日: 2026-05-11
> 質問: 「dynabook + クラウド LLM の Phase 1 設計を技術的に最大化する具体提案」

## ChatGPT 総評

> 結論: その方針はかなり合理的です。今やるべきは「ローカル LLM 高性能化」ではなく、**Agent 能力を model size ではなく harness quality で再現する実験**です。低 GPU 環境では、LLM を鍛えるより、**役割定義・KB 検索・Skills・Issue 駆動・評価ログを鍛える方が費用対効果が高い**。

## ChatGPT が提示した最適アーキテクチャ

```
Claude Code / ChatGPT / Gemini / GH Copilot
        |  (外部 LLM の推論能力)
        v
Agent Harness Layer
  - Role prompt
  - R-rule / Doctrine
  - Skills
  - KB search
  - Issue context
  - repo state
  - evaluation logs
        |
        v
Local Knowledge / Tools
  - GitHub 46 repo
  - 1000+ Issues
  - $HOME/.kb
  - ChromaDB
  - SQLite feedback
  - scripts
  - MCP tools
```

> Captain が今作っているのは「ローカル LLM 環境」ではなく、**外部 LLM を複数 Agent として安定運用するための制御層**です。

## C1: 全 Agent に同じ KB 検索を食わせない ★★★★★

> Agent の違いは prompt だけでは弱い。**検索対象・検索クエリ・評価軸・出力フォーマットまで分ける**と、かなり専門 Agent っぽくなる。

### 提案ファイル: `agent_profiles.yaml` (retrieval policy per role)

```yaml
architect:
  top_k: 12
  collections: [issues, decisions, r_rules]
  output: [decision, tradeoff, risk, next_action]
reviewer:
  top_k: 10
  collections: [past_bugs, r_rules, similar_fixes]
  output: [blocking, non_blocking, test_needed, rule_candidate]
implementer:
  top_k: 8
  collections: [code_patterns, current_issue, similar_impl]
  output: [patch_plan, files, commands, verification]
```

### API 変更提案

```python
search_kb(query: str, role: str = "default", repo: str | None = None)
```

### Feedback DB schema 拡張

```sql
ALTER TABLE feedback ADD COLUMN role TEXT DEFAULT 'default';
```

これにより:
- reviewer では役立つが、implementer では役立たない chunk を検出
- architect では強いが、PM ではノイズになる rule を検出
- = **「役割別 Agent 学習」の低スペック版**

→ **agoora 反映**: `agent_profiles.yaml` を本リポに配置 ✓

## C2: 5 役 → 3 役で十分 (cognitive load 削減) ★★★★

> 1 人開発では Agent 管理自体が新しい仕事になる。最初は **Architect / Reviewer / Implementer の 3 役**で十分。

| Top 3 推奨 | 理由 |
|-----------|------|
| Architect / Reviewer / Implementer | 開発品質に直結、Claude Code 運用と相性最良 |
| Knowledge Curator 追加 | KB 肥大化時に必須化 (46 repo + 1000 Issue で発生確率高) |
| PM / Roadmap Agent | 便利だが Issue 運用で代替可能、後回し |

→ **agoora 判断**: 7 役は維持 (機能的に必要) だが、`agent_profiles.yaml` MVP は ChatGPT 推奨 3 役 + Curator = 4 役で開始、残り 3 役 (orchestrator / researcher / critic) はメタ役割として常時稼働。

## C3: やらない方がよいもの (ChatGPT 明示)

| やらない方がよい | 理由 | agoora 判断 |
|----------------|------|-----------|
| ローカル LLM fine-tuning | GPU 制約に対し投資重い | [riku1215#12](https://github.com/riku1215/riku1215/issues/12) で「Phase H 棚上げ」確認済 ✓ |
| 複数ローカル LLM 常駐 | RAM/CPU/運用コスト | 同上 ✓ |
| AutoGen/CrewAI 風多 Agent 自律 | 制御不能リスク | route.sh の **Safety Breakwater** で対応 ✓ |
| Web UI 凝り過ぎ | feedback 収集以上は本末転倒 | 99-portal-ui は機能優先で実装、装飾は最小限 ✓ |
| VS Code 拡張化 | 時期尚早 | 不要 ✓ |

## C4: 推奨ロードマップ (7 steps)

| Step | 内容 | agoora 対応 |
|------|------|-----------|
| 1 | `agent_profiles.yaml` 配置 | ✓ 本 repo で実装 |
| 2 | `search_kb` に role 引数追加 | [riku1215#11](https://github.com/riku1215/riku1215/issues/11) Phase D-4 |
| 3 | role 別 top_k / collection | ✓ agent_profiles.yaml |
| 4 | Streamlit feedback UI | ✓ 既存 (3-interface/kb_feedback_ui.py) |
| 5 | feedback.sqlite3 に role | 次セッション |
| 6 | pairwise JSONL export | feedback UI 拡張 |
| 7 | re-ranker / rule-based boost | [riku1215#13](https://github.com/riku1215/riku1215/issues/13) Phase G |

## ChatGPT 30 秒セットアップコマンド

```bash
mkdir -p "$HOME/.kb/config" && cat > "$HOME/.kb/config/agent_profiles.yaml" <<'YAML'
architect:
  top_k: 12
  collections: ["issues", "decisions", "r_rules"]
  output: ["decision", "tradeoff", "risk", "next_action"]
reviewer:
  top_k: 10
  collections: ["past_bugs", "r_rules", "similar_fixes"]
  output: ["blocking", "non_blocking", "test_needed", "rule_candidate"]
implementer:
  top_k: 8
  collections: ["code_patterns", "current_issue", "similar_impl"]
  output: ["patch_plan", "files", "commands", "verification"]
YAML
```

→ **agoora 反映**: `agent_profiles.yaml` (211 行) を Captain Portal に配置 ✓

`#r14 #chatgpt #retrieval-policy #agent-profiles #search-kb-role`
