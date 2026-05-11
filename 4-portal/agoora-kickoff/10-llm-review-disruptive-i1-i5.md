# 3 LLM レビュー依頼パケット — I1-I5 破壊的イノベーション提案 (R14 強制)

> Captain がコピペで各 LLM へ送信、回答を本 PR or agoora#X に統合。
> 出典: `1-knowledge/disruptive-innovation-5-proposals.md`

---

## 📦 共通前提 (3 LLM 全てに最初に貼付)

```
# 背景 — agoora プロジェクト

agoora = riku1215 (個人開発者) の 28+ repo を統合する「Captain's knowledge hub」。
本セッション 12h 自走で PR #19 (~14,500 行) として実装中。
詳細: https://github.com/riku1215/riku1215/pull/19

# 問題

Captain が指摘した Claude (=私) の根本的弱点:
1. 記憶があてにならない (session 跨ぎ忘却、同 session 内も 30+ msg で精度低下)
2. 見逃し常習犯 (agora#4 fetch 忘れ、scope 誤判定、過去 Issue 重複提案)

# 私の対応提案 (5 件、機構で補完)

I1. Pre-Action Probe: 提案前に ~/.kb/ 自動検索 (researcher 強制 fan-out)
I2. MCP Capability Auto-Probe: session 開始時 3 秒 capability test (.claude/hooks/SessionStart)
I3. Trigger Word Listener: Captain 発話 regex 監視で historian 自動発火
I4. Section 7 Pre-Block: proposal 出力前 violation scanner
I5. Continuous Self-Audit: 30 msg 毎 agora#4 + #82 再 fetch + 直近 5 msg audit

詳細: github.com/riku1215/riku1215/blob/claude/claude-app-recovery-options-KIAig/1-knowledge/disruptive-innovation-5-proposals.md

# 質問
```

---

## 🎯 LLM 1: ChatGPT (Codex / GPT-5) — Technical Detail ペルソナ

```
あなたは agoora の技術アドバイザー (skills-strategy#9 通り、technical-detail 用途)。
以下の I1-I5 実装について 5 件回答してください:

Q1. I1 Pre-Action Probe の実装で、orchestrator system prompt に「researcher 強制
   fan-out」を埋め込む方法と、prompt level だけで強制困難な場合の portal-api 側
   での enforce 実装 (Python 50 行) を提案。

Q2. I2 MCP Capability Auto-Probe の .claude/hooks/SessionStart.py 実装 (Python
   80 行) を、Claude Code の SessionStart hook spec に準拠して書け。MCP tool
   の dry-run 方法も含む。

Q3. I3 Trigger Word Listener を agoora routing.yml の always_apply で実装する場合、
   実際の runtime は Python regex か LLM intent classification か? 各案の
   precision/recall + 実装コストを比較。

Q4. I4 Section 7 Pre-Block を「proposal output 直前」に挟む技術的方法:
   (a) Anthropic API の prefill / stop_sequences で実現可能か?
   (b) post-processing で violation 検出時の retry mechanism は?
   実装 70 行で書け。

Q5. I5 Continuous Self-Audit を 30 msg ごとに発動する場合、msg count は
   どこに保持? session-level state 不在の Claude Code 環境で実装する方法を
   3 案提示 (file-based / portal-api / browser extension)。

回答末尾に「想定リスク 2 件」必須。
```

---

## 🎯 LLM 2: Gemini (戦略・トレードオフ) ペルソナ

```
あなたは agoora の戦略アドバイザー (R14 別 LLM 強制で Claude 案を critic レビュー)。

以下の I1-I5 提案を 3 軸で評価:

Q1. **Over-engineering リスク評価**:
   I1-I5 全て実装すると orchestrator system prompt が 5,000+ tokens に膨張。
   "1 度に高品質完成" (R80) と矛盾しないか? 必須優先順位 (Top 3 へ絞る) を提案せよ。

Q2. **代替案 (Captain 案にない発想)**:
   私 (Claude) の弱点を機構で防ぐ I1-I5 以外で、より根本的な解決策はないか?
   例: そもそも Claude を使わず Gemini / GPT-5 を主体にする / 人間レビュー必須化
   等。3 案 + ★ 推奨度。

Q3. **Captain 業務影響評価**:
   I1-I5 実装で Captain の workflow がどう変わるか?
   - 短期 (1 ヶ月): メリット / デメリット
   - 中期 (3 ヶ月): どこで価値が顕在化?
   - 長期 (Phase 5 商用化): 他 SaaS との差別化要素として成立するか?

Q4. **「失敗を資産化」の本質的限界**:
   skill-baton-hashtag-thesis で「失敗 = 進歩のタネ」と定義したが、これは
   class-weaver 119 Issues の規模だから成立する話。個人開発者の他 PJ で
   この approach は scale するか? Tier 別 (1 mature / 2 active / 3 early) で
   答えよ。

Q5. **Phase 1.5 → 2.0 移行判断**:
   I1-I5 のうち、Phase 1.5 で実装すべきは? Phase 2.0 まで先送りすべきは?
   trade-off + Captain 業務優先 (sakura/dify/audit) との整合性で判定。

回答は「① 判断 / ② trade-off / ③ 懸念」形式。
```

---

## 🎯 LLM 3: Grok (リアルタイム + 競合分析) ペルソナ

```
あなたは agoora の critic agent (R14 強制、Grok-3/4)。
X / Reddit / Hacker News のリアルタイム検索で以下を回答:

Q1. **競合事例 (2026 年最新)**:
   I1-I5 と同型機構を実装している AI Agent / IDE 拡張 / SaaS は?
   - Cursor の "session memory" 機構
   - Cognition の Devin
   - Anthropic Claude Code 自体の SessionStart hook
   - Codeium Forge
   - その他 3 件以上
   各々と I1-I5 の差別化ポイントを 1 行で。

Q2. **「Claude の弱点を機構で補完」設計の先行事例**:
   X / Reddit で「Claude is forgetful / context loss」を議論する個人開発者の
   実装事例を 5 件以上 (URL 付き)。彼らの解決策と I1-I5 の差は?

Q3. **失敗 = 資産アプローチの先行事例**:
   skill-baton-hashtag-thesis の「failure-driven progress」と同思想を実装する
   OSS / 商用ツールは?
   - Linear / Notion AI / Coda の failure log 系
   - Sentry 等の error tracking と「資産化」の差
   5 事例。

Q4. **絶対的反論 (R8 強制)**:
   I1-I5 の各々に対して、本当に必要か / 過剰設計か / 代替手段の存在を
   X 検索ベースで反論。「現状で問題ない」結論は禁止、必ず 3 反論以上。

Q5. **Phase 5 商用化時の market 評価**:
   agoora が「失敗が資産になる開発インフラ」として SaaS 化した場合、
   2026-2027 で発見されている類似プロダクトの市場規模 + 失敗事例
   (撤退した SaaS) を 5 件以上。Captain の差別化を強化する hint。

回答は反論 + 代替案 + リスク確率必須 (R8 強化)。
```

---

## 統合計画

回答を 3 LLM から受領後、私 (Claude orchestrator 役) が:
1. 各回答を `1-knowledge/disruptive-innovation-i1-i5-r14-review.md` に統合
2. I1-I5 の優先順位を 3 LLM 集合知で再決定
3. Phase 1.5 即実装 / Phase 2.0 queue を確定
4. agora#83 起票 draft (08-agora-83-issue-draft.md) に R88 候補として追加

---

## 提出順序 (推奨)

| Step | LLM | 理由 |
|------|-----|------|
| 1 | ChatGPT | 技術詳細を先、実装可否で I1-I5 を篩い |
| 2 | Gemini | 戦略レビュー、Over-engineering リスク評価 |
| 3 | Grok | 競合 + 失敗事例、最終 sanity check |

3 LLM 集合知 = **R14 完全実装** (本セッションの真の目玉)。

`#r14 #multi-llm-review #i1-i5 #disruptive #agoora-critic`
