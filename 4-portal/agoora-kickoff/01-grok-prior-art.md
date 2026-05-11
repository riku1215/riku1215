# コメント 1/6 — Grok prior-art 調査 (90 日 X/Reddit、5 事例)

> R14 サイクル: **Grok** (リアルタイム X 検索 + 反論強化)
> 実施日: 2026-05-11
> 元データ: [riku1215/riku1215 1-knowledge/prior-art-2026-05-11.md](https://github.com/riku1215/riku1215/blob/master/1-knowledge/prior-art-2026-05-11.md)

## サマリ (200 字)

直近 90 日 (2026-02-11 〜 05-11) の X / Reddit から「個人開発者 30+ repo + LLM harness」事例を 5 件抽出。**全 5 件で graph/MCP + クラウド LLM 採用**、token 20-120x 削減 + 月額 ¥0 共通。本 agoora ハーネスは 70-80% 機能カバー済だが、**Tree-sitter 構造解析** と **dependency graph (blast radius)** が未実装ギャップ。

## 5 事例 × agoora ハーネス対応マトリクス

| # | 事例 | コア技術 | agoora 対応 | ギャップ |
|---|------|---------|------------|---------|
| 1 | **SevenviewSteve** 200+ Rails submodule | git submodule + agent skill | ✓ Phase A clone | submodule 親 repo パターン未採用 (代替済) |
| 2 | **codebase-memory-mcp** | Tree-sitter + KuzuDB + Cypher | ✗ ChromaDB (embedding) | **構造グラフ未実装** ★ 最大ギャップ |
| 3 | **GitNexus** | ブラウザ KuzuDB Graph RAG | ✗ サーバ前提 | ブラウザ完結未検討 |
| 4 | **Repowise** | dependency graph + blast radius | ✗ 未実装 | **PR 前 impact 解析未実装** ★ |
| 5 | **GitHub MCP + skills marketplace** | MCP plugin marketplace | ✓ 47 skills | shared skills repo 未公開 |

## 共通の成功要素 (5/5 一致)

| 要素 | agoora 現状 |
|------|------------|
| クラウド LLM (Claude 中心) | ✓ agents.yml で割当済 |
| MCP server 経由 | △ Issue #11 計画中 |
| **token 大幅削減 (20-120x)** | △ 効果測定基準のみ定義 |
| 永続コンテキスト (セッション跨ぎ) | △ historian + claude-mem 統合済 |
| 月額 ¥0 | ✓ |
| 役割分担/skills | ✓ agents.yml で 7 役 |

## 共通の失敗パターン (5/5 共通)

| 失敗 | agoora 対応 |
|------|------------|
| 同期忘れ | ✓ Phase E 日次 backup + Task Scheduler |
| 大規模 monorepo 遅延 | △ サブディレクトリ単位 index 未対応 |
| ツール過多でトークン浪費 | ✓ agents.yml で skill 限定 (3-5 個/役) |
| **RAG の共有 util 見落とし** | ✗ **graph 未実装、本ギャップ最大** |
| コンテキスト圧縮損失 | ✓ historian + claude-mem |

## 即時取込候補 ★ 推奨度

### A. Tree-sitter 構造解析 ★★★★★

- **根拠**: 事例 2, 4 で「embedding RAG の共有 util 見落とし」を完全解消
- **実装**: `2-intelligence/structural-search/` 新規 (Python + tree-sitter-language-pack)
- **コスト**: 0、CPU で動作、64 言語対応
- **agoora 統合**: researcher 役の skill に追加
- **Phase 判定**: Phase 1 で着手可能、Phase 2 KPI に組込推奨

### B. Dependency graph + blast radius ★★★★

- **根拠**: 事例 4 Repowise で「PR 発行前に blast radius 必須」が成功要因
- **agoora 統合**: **新 agent 役「impact-analyst」追加**、coder → impact-analyst → reviewer ループ
- **Phase 判定**: Phase 1 後半

### C. MCP server 統合 ★★★★

- **根拠**: 5/5 全事例で MCP 採用、token 削減の核
- **既存計画**: [riku1215#11](https://github.com/riku1215/riku1215/issues/11) (Phase D-4)
- **Phase 判定**: setup.ps1 + Phase D 完了後

## 出典

- 事例 1: X post `2025997225726300250` (SevenviewSteve, 200+ Rails submodule)
- 事例 2: Reddit r/ClaudeAI 2026/3/9 (codebase-memory-mcp)
- 事例 3: X post `2028436636841996451` 他 (GitNexus)
- 事例 4: X post `2052635607168651617` (Repowise)
- 事例 5: Reddit r/ClaudeCode 2026/5 (GitHub MCP marketplace)

`#r14 #grok #prior-art #tree-sitter #blast-radius`
