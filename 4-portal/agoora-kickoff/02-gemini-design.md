# コメント 2/6 — Gemini design validation (3 大設計要素)

> R14 サイクル: **Gemini** (戦略判断・複数選択肢評価)
> 実施日: 2026-05-11
> 質問: 「dynabook + クラウド LLM のみで Kuuki Design 18-agent 理想に迫る Phase 1 設計の致命的盲点を 3 件挙げよ」

## Gemini 総評

> キャプテン、そのアプローチはシステムアーキテクチャの観点から見て**極めて理にかなった洗練された設計戦略**です。ハードウェアの力技 (GPU への物理的依存) に頼る前に、クラウド上の強力な汎用 LLM (API) を活用して「司令塔 (オーケストレーター)」と「エージェント間の連携経路 (ハーネス)」を完璧に組み上げる。これは、スケーラビリティと保守性を担保するためのソフトウェア工学の王道です。
>
> 物理的な VRAM の制約 (ほぼ GPU ゼロ) は、逆に言えば「完全に疎結合で、どこにでも移植可能な最強の AI ワークフロー」を強制的に生み出すための最高の制約 (チャレンジ) になります。

## G1: 役割 (Roles) の分離と動的バインディング

> クラウド上の LLM は非常に賢い反面、文脈が広すぎると平気で幻覚 (ハルシネーション) を起こします。そのため、API を叩く前に「あなたは今、どの役割か」を**極限まで絞り込む**設計が必要。

**実装の工夫**: `AGENTS.md` のようなドクトリンをさらに細分化、System Prompt を独立。タスク発生時、オーケストレーターが**タスクの種類に応じて適切な Prompt (役割) を被せてから API に投げる**ルーティング機構を構築。

→ **agoora 反映**: `agents.yml` (7 役 × LLM × skills × knowledge_scope) + `routing.yml` (12 ルール decision tree) で実装済 ✓

## G2: Knowledge の非同期・外部注入 ★★★★★ 最重要

> ローカルのメモリ (RAM) で大量のコンテキストを保持し続けると破綻。

**実装の工夫**: エージェントが直接すべてを記憶するのではなく、**GitHub Issue や専用 Markdown ファイルを「外部の脳 (共有メモリ)」として使う**。
- エージェント A が調査結果を Issue に書込 ([R66](https://github.com/riku1215/agora/issues/4) の徹底)
- エージェント B はその Issue のテキストだけを読込んで次の作業

→ ローカルマシン負荷は「テキスト受渡し」のみで劇的に軽量化。

→ **agoora 反映**: `protocol.md §9 "Issue-as-shared-memory"` 節追加 ✓

```
[architect] → Issue body 書込 (gh issue create / comment)
      ↓
[coder] ← Issue text のみ読込 (RAM 不要)
      ↓
[reviewer] → 同 Issue にコメント追加
      ↓
[historian] → 完了時 Issue close + 要約付与
```

## G3: Skills (スキル/ツール) の安全な実行環境

> エージェントが自律的に動く際、**最も危険なのが意図しない本番環境の破壊**。

**実装の工夫**: クラウド LLM が直接コード書換えるのではなく、LLM には **「GitHub CLI のコマンド」や「スクリプト実行計画」だけを出力**させる。ローカル PC 側スクリプトが受取り、**人間 (Captain) の承認トリガーを経てから安全に実行する「防波堤」**をハーネスに組込み。

→ **agoora 反映**: `protocol.md §10 "Safety Breakwater"` 節追加 ✓
- LLM 出力の shell コマンドは**既定 dry-run**
- `--execute` flag 明示時のみ実行
- 破壊操作 (rm -rf, git push --force, DELETE) は**二重承認**

## Phase 1 完了の Gemini 提案目標

1. **「1 つの Issue を起点とした完全自動リレー」完成**
   - Issue 「○○ 機能追加」起票 → ①要件定義 AI → ②実装 AI → ③レビュー AI → ④結果 Issue 返却 を **API 経由で完遂**

2. **トークン消費 (コスト) の最適化**
   - 重い思考: claude-opus / 中: claude-sonnet / 軽: claude-haiku, gemini-flash
   - 振り分けロジックを Dify 上 (or routing.yml) で確立

3. **API の向き先を localhost に変えるだけで Phase 2 移行可能**な疎結合設計

→ **agoora 反映**: `protocol.md §11 "Phase 1 KPI"` に正式 KPI として明文化 ✓

## Gemini 反論 (致命盲点) → 全て解消済

| Gemini 指摘 | agoora 対応 |
|------------|------------|
| G1 役割分離曖昧 | agents.yml で 7 役明文化 ✓ |
| G2 メモリ破綻 | Issue-as-shared-memory 採用 ✓ |
| G3 本番環境破壊 | Safety Breakwater 採用 ✓ |

## 次サイクル候補

- ChatGPT に「Tree-sitter PoC 実装方針」をレビュー依頼 → コメント 3 で実施

`#r14 #gemini #design-validation #harness #issue-as-memory #safety`
