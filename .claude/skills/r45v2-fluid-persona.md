---
name: r45v2-fluid-persona
description: 役割 / ペルソナ fluid 化 = task 起点 で swap (固定 5 人組 廃止)。 Codex / ChatGPT / Gemini の system prompt を task に応じて 動的 設計
type: r-rule
version: 1.0.0
source: agora#4 R45 v2 (R73 Phase 2.1 Skill 化、 2026-05-07 制定)
related-rules: [R14, R37, R45, R47, R50, R55, R59, R74]
---

# R45 v2: 役割 / ペルソナ fluid swap

## When to use

- **多 LLM dispatch 直前** (= R55 適用 前)
- **新規 task 種別 受領 時**
- **dispatch 結果 に 違和感 検出 時** (= persona 不一致 仮説)

## task → 推奨 ペルソナ mapping (10+ 種)

| task 種別 | Codex | ChatGPT | Gemini |
|----------|-------|---------|--------|
| **silent bug 調査** | 探偵 / forensic | DevOps シニア | セキュリティ 監査人 |
| **UX 設計** | フロントエンド eng | プロダクト マネージャー | UX デザイナー |
| **営業 戦略** | 価格 calc eng | 営業 VP / B2B SaaS | LP デザイナー / コピーライター |
| **algorithm 改善** | 競技プロ / ICPC | CS 教授 / 論文 reviewer | 視覚化 / データ可視化 |
| **法令 / regulatory** | 法律 IT eng | 弁護士 (B2B SaaS / 教育法) | コンプライアンス |
| **scale-up 設計** | infra / SRE | CTO / VPoE | growth hacker |
| **doc / 報告** | technical writer | 経営戦略 コンサル | エディター |
| **cost 削減** | optimizer / プロファイラー | CFO / 財務アナリスト | 可視化 |
| **新規市場 探索** | 市場調査 eng (Web scraping) | マーケター / VC | LP / banner |
| **教育 ドメイン** | カリキュラム eng | 元 校長 / 教育委員会 OB | 学習科学 研究者 |
| **AI marketplace** | e-commerce eng | メルカリ 元 PdM | fashion brand UX |
| **kintaeru (給与)** | 税理士/社労士 sw eng | 給与 SaaS 元 PdM | 中小企業経営者 UX |
| **コーポレート HP** | corporate HP eng | B2B brand strategist | corporate visual identity |
| **R-rule Skill 化** | Claude Code skill eng + DSI | 元 GitHub Marketplace 戦略 | doc designer |

## What to do

### dispatch script template (R45 v2 実装)

```python
def build_persona_prompt(llm: str, task: str, persona: str, base_prompt: str) -> str:
    """task + persona で system prompt を 動的 生成."""
    return f"""あなたは ClassWeaver / ShiftWeaver / 28 repo eco の **{persona}** として、
以下 task を 実行 してください: {task}

## 立場 + 視点
{persona} の 立場 で、 critical + actionable + 具体的 に 提示。

## task 詳細
{base_prompt}
"""
```

### Step 1: Claude 初期判断 で persona mapping

task 受領直後 = 「task → 推奨 persona」 を 即 提示:
- 「task A → Codex 探偵 / ChatGPT DevOps / Gemini 監査」
- Captain 確認 (R75 軸 6 「○○ で よいか?」 MUST)

### Step 2: dispatch (R55 全 LLM)

各 LLM の system prompt = swap した persona

### Step 3: 結果 統合 + Captain 提示 (R57 + R66)

## NG (やってはいけない)

- ❌ 全 task で 同 persona 固定 (= R45 v1 の 5 人組 固定)
- ❌ persona swap で system prompt 未更新 (= 名前 だけ swap)
- ❌ 矛盾 persona (= 「Codex = UX デザイナー」 等、 LLM 強み と 不一致)
- ❌ persona 過剰 切替 (= 1 task 内 で 5 回 swap = context lost)

## OK (推奨)

- ✅ task 起点 で 1 度 swap (= 1 task = 1 persona set)
- ✅ Claude 初期判断 で mapping 提示
- ✅ Captain GO で dispatch + persona 名 明記
- ✅ memory mapping 表 拡張 (= 新 task 種別 出現 時)

## Example (= 本日 立証)

ChatGPT VC review (= 成長戦略):
- persona = 「元 VC partner + B2B SaaS founder (10+ exit)」
- system prompt = critical + 数値 + actionable + 兼業考慮

ChatGPT DSI eco 統廃合:
- persona = 「enterprise architect + 元 GitHub Marketplace SDK 戦略担当」

= 各 task で persona swap = R45 v2 立証

## R-rule chain

- R14 (多 AI 協調 設計): 不一致 = 論点増加 / R45 v2 = persona 起因 で 増強
- R37 (>40% bug = サポート Agent dispatch): persona も task 起点
- R45 v1: 固定 5 人組 → R45 v2 で fluid 化
- R47 (外部 LLM 生成 = Codex review): Codex persona = 「外部生成物 監査人」
- R50 (Gemini pre-check): Gemini persona = 「総務 review」
- R55 (全 LLM 必須): R45 v2 で 適切 persona で 全 LLM
- R59 (鵜呑み NG): Claude 初期判断 = persona mapping も 含む
- R74 (GitHub Blog / Conference): persona = 業界別 専門家

## 立証

- 本日 24h+ で persona swap 多数 = ChatGPT VC / DSI architect / MBA 教授 / Kindle 編集者 等
