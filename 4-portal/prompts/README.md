# agoora prompts/ — 11 agent system prompts (Claude 設計 + 実装)

`#prompts #system-prompts #agent-design #captain-portal`

> **Captain 役割 (specifier)**: agents.yml で「何をする agent か」を定義
> **Claude 役割 (designer + implementer)**: 本ディレクトリで「どう動かす system prompt か」を設計
>
> 2026-05-11 役割分担確定。

## 0. 設計原則 (Captain 承認済 R-rules 全準拠)

各 agent prompt は以下 6 原則を満たす:

1. **R3 トークン量**: system prompt ≤ 1500 tokens、instruction ≤ 500 tokens
2. **R8 反論余地**: critic 以外でも「但し書き / 想定リスク」必須
3. **R9 Pre-action**: orchestrator 内蔵、他 agent も R9 影響受ける
4. **R10 Batched Auth**: 出力末尾は yes/no 表 or アクション 1 件
5. **R14 多 LLM**: critic は別 LLM 強制、他は使う LLM 明示
6. **Section 7 失敗回避**: 「曖昧結論」「全範囲影響」「失礼しました」禁止

## 1. 設計テンプレート (全 prompt の共通 frame)

```markdown
---
agent: <name>
llm_primary: <claude-opus/sonnet/haiku|gemini-pro/flash|grok|chatgpt>
llm_fallback: <...>
skills_required: [...]
knowledge_scope: [...]
triggers: {...}
references: [R-rules / Section 7 / 関連 doc]
---

# System Prompt
あなたは agoora の <name> 役。役割: <一文要約>

## 必須出力フォーマット
- <field 1> (例: 200 字結論)
- <field 2>
- ...

## 禁止事項 (Section 7 / spec-change 由来)
- ❌ <例>
- ❌ <例>

## skill 呼出ルール
- <skill> → <when>

## R-rule 連動
- R<N>: <準拠方法>

# Task Instruction Template
{以下、user_input + 各種 context を受領した時の処理手順}

# 出力例 (golden sample)
{典型ケースの理想出力}
```

## 2. 全 11 agent prompts (本ディレクトリ内)

| ファイル | agent | LLM | 役割 |
|---------|-------|-----|------|
| `orchestrator.md` | orchestrator | claude-opus | 司令塔・統合 |
| `researcher.md` | researcher | gemini-flash | 過去議論検索 |
| `architect.md` | architect | claude-opus | 設計判断 |
| `critic.md` | critic | grok | 反論 (R14 強制) |
| `coder.md` | coder | claude-sonnet | 実装計画 |
| `reviewer.md` | reviewer | chatgpt | severity 判定 |
| `historian.md` | historian | claude-haiku | 記憶保存 |
| `structural-analyzer.md` | structural-analyzer | claude-sonnet | Tree-sitter |
| `impact-analyst.md` | impact-analyst | claude | blast radius |
| `domain-expert.md` | domain-expert | gemini-pro | ドメイン特化 |
| (本ファイル) | README | — | 設計原則 + index |

## 3. prompt 適用方法

### 3-A. Anthropic API call 時 (auto-relay.py)

```python
from pathlib import Path
PROMPTS_DIR = Path("4-portal/prompts")

def load_prompt(agent_name: str) -> str:
    return (PROMPTS_DIR / f"{agent_name}.md").read_text(encoding="utf-8")

# 使用例:
system = load_prompt("architect")
user = f"設計 task: {task_description}"
client.messages.create(model="claude-opus-4-7", system=system, messages=[{"role": "user", "content": user}])
```

### 3-B. portal-api.py /search でも適用

agent_profiles.yaml の role × prompts/<role>.md = 完全な agent コンテキスト形成。

## 4. メンテナンス

- agents.yml 変更時 = 該当 prompt も更新 (Captain 仕様変更 → Claude 実装追従)
- 月次 review (R7 四半期レビュー連動): 各 prompt の出力品質を feedback.sqlite3 で測定
- 違反パターン発見時 = `禁止事項` セクションに即追加 (Section 7-6 失敗即時学習)

## 5. 関連

- `4-portal/agents.yml` (Captain 仕様、本ディレクトリの source of truth)
- `4-portal/AGENTS.md` (md 版仕様、LLM 読み)
- `4-portal/agent_profiles.yaml` (retrieval policy、本 prompt と組合せ)
- `4-portal/protocol.md` (オーケストレーション、Issue-as-shared-memory / Safety Breakwater)
- `3-rules/r-rules-index.md` (全 R-rules)
- `PROFILE.md Section 7` (失敗パターン、禁止事項源泉)

`#prompts #design #captain-portal #claude-designed`
