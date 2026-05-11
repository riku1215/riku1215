---
tags: [doctrine, r-rules, agora-82, clusters, captain-portal]
layer: foundation
audience: [claude, all-llms]
status: active
source: agora#82
---

# 7 Doctrine Clusters 詳細 (agora#82 由来)

`#doctrine #r-rules #agora-82`

> agora#82 で提案された **R-rule 50+ → 7 doctrine cluster** 統合。
> 認知負荷削減 (7 primary 参照で全 R-rule 機能カバー) + 番号 freeze (R64) で互換性維持。

## D-A. Multi-LLM Dispatch Doctrine

**Primary: R55 全 LLM 必須 (forward review)**

### 哲学
> 単一 LLM の判断を鵜呑みにしない。設計判断・実装判断は必ず複数 LLM のクロスレビューを経る。

### Member Rules
| Rule | 機能 | 適用フェーズ |
|------|------|-----------|
| R55 ★ | 全 LLM 必須 (forward review) | 設計判断前 |
| R45v2 | fluid persona (LLM 役割 swap) | agent 役割 dispatch |
| R59 | Claude 初期判断 → Codex/ChatGPT 検証 (sideways) | 重要判断 |
| R70 | Captain 戦術指示疑え + 反論 + 解決策 | Captain 指示受領時 |
| R77 | Claude 単独判断 NG + 多 LLM | 高リスク判断 |
| R79 | Captain 修正提案 = Codex (+ 多 LLM) dispatch | 修正フェーズ |
| R82 | 実行後 多 LLM 分析 (backward review) | post-execution |

### agoora 実装
- `agents.yml` の **critic 役は別 LLM 強制** (architect が Claude なら critic は Grok)
- `routing.yml always_apply` で `different_llm_than_architect` 制約
- 4-portal/protocol.md §11 Phase 1 KPI に「R14 強制」明記

## D-B. Captain Communication / Entry-level

**Primary: R56 entry-level 説明**

### 哲学
> Captain は技術詳細を 100% 把握しているわけではない。例え話 + 「何が起きた」 + 「結果」で簡潔に伝える。

### Member Rules
| Rule | 機能 |
|------|------|
| R56 ★ | entry-level 説明 (例え話 + 何が起きた + 結果) |
| R71 | 言語化 failure 補完視点 (NG 用語禁止) |
| R78 | Gemini = 分かりやすい文章化ルーティーン |

### agoora 実装
- orchestrator output_format に **200 字結論先頭 + entry-level 例え話**
- 専門用語使用時は ()  で簡単な訳/補足
- Help タブで Captain 向けに UI 操作ガイド (技術不要レベル)

## D-C. Question Quality

**Primary: R76 質問 5 軸構造化**

### 哲学
> Captain への質問は 5 軸 (target/option/recommendation/tradeoff/decision-impact) で構造化。候補なしで質問しない。

### Member Rules
| Rule | 機能 |
|------|------|
| R76 ★ | 質問 = 5 軸構造化 |
| R63 | 質問増やして無駄回避 |
| R81 | 候補を提案せずに質問しない (must) |

### agoora 実装
- orchestrator が AskUserQuestion ツール使用時は ★ 推奨度付き選択肢必須
- 質問は 1 turn ≤ 2 件 (R5 連動)

## D-D. Autonomy & Planning

**Primary: R65 24/48/72h plan**

### 哲学
> Claude が長時間自走できる体制 (R16/R20) を整備。Captain の合意は事前一括 (R10) で取り、走り始めたら R20 で auto-execute。

### Member Rules
| Rule | 機能 |
|------|------|
| R65 ★ | 24/48/72h plan |
| R10 | batched authorization |
| R16 | autonomous run mode |
| R20 | 5-min timeout auto-execute |
| R44 | (詳細確認要) |
| R61 | 夜間浅く広く |
| R72 | ゆっくり mode |

### agoora 実装
- 6h 自走時は R65 + R10 計画提示 → R20 で自動実行
- protocol.md §11 Phase 1 KPI に **「1 Issue 起点完全自動リレー」** 明記
- route.sh / route.ps1 の Safety Breakwater で破壊操作のみ承認待ち

## D-E. Visibility & Reporting

**Primary: R57 3-line 要約**

### 哲学
> セッション中の進捗は 3 行で要約、md doc は Issue にペーストして外部化。Captain がいつでも追える。

### Member Rules
| Rule | 機能 |
|------|------|
| R57 ★ | 3-line 要約 |
| R66 | md doc → Issue paste |
| R67 | Chrome 複数モニター自走可視化 |

### agoora 実装
- **Issue-as-shared-memory** (protocol.md §9) = R66 完全実装
- progress 報告は 3 行サマリ + 詳細リンク
- 99-portal-ui で全 Issue を横断検索可

## D-F. Quality Gate

**Primary: R80 1 度で高品質完成 (反復 fix NG)**

### 哲学
> 完成までに 5 回 commit が必要なものは「高品質」ではない。1 度の出力で 5-gate (lint/test/type/integration/manual) 全通過を目指す。

### Member Rules
| Rule | 機能 |
|------|------|
| R80 ★ | 1 度で高品質完成 (= 反復 fix NG) |
| R27 | 5-gate Definition of Done |
| R34 | 実操作 verify |
| R49 | console first (silent bug) |
| R50 | Captain 指示前 Gemini pre-check |

### agoora 実装
- reviewer agent の severity 判定 (critical → coder へ自動 loop-back、最大 3 反復)
- CI/CD lint workflow (本 6h 自走で実装予定)
- portal-api.py の `/healthz` で 5-gate チェック相当

## D-G. Pushback / Premise

**Primary: R19 Question the Premise**

### 哲学
> Captain の前提を疑え。「絶対変更しない」と書きながら変更している憲法的文書 (= N1 禁止事項) を発見したら即訂正。

### Member Rules
| Rule | 機能 |
|------|------|
| R19 ★ | Question the Premise |
| R8 | 反論ルール (R8 反論余地) |
| R18 | Pushback-as-Algorithm |
| R60 | Vision = Captain 専管 (鵜呑み必須) |
| R75 | Captain 抽象 → Claude スキーム化 |

### agoora 実装
- **critic agent** が agents.yml の必須役 (反論最低 3 件)
- routing.yml always_apply で `r14-multi-llm` (architect と別 LLM 必須)
- Section 7-8 自信度と反論余地 で全提案に ★ 推奨度

## クラスター運用ルール (agora#82 Phase 2)

1. 新 R-rule 候補 = 既存 cluster の派生で賄えるか先 check (R5 既存確認適用)
2. 真新規 cluster = Captain 明示認可必須 (R60 vision-captain-only)
3. **番号 freeze**: R-rule 番号の廃止/merge (= 削除) は **しない** (R64 番号一意性死守)
4. agoora 全 markdown で cluster reference は **D-X** 形式で統一

## agoora repo 全 CLAUDE.md の必須 reference

```markdown
## R-rules 準拠

本 repo は agora#4 + agora#82 (7 doctrine cluster) に準拠:
- D-A Multi-LLM Dispatch (R55)
- D-B Captain Communication (R56)
- D-C Question Quality (R76)
- D-D Autonomy & Planning (R65)
- D-E Visibility & Reporting (R57)
- D-F Quality Gate (R80)
- D-G Pushback / Premise (R19)

詳細: `3-rules/doctrine-clusters.md`
```

## 関連

- [agora#82](https://github.com/riku1215/agora/issues/82) 原典
- `3-rules/r-rules-index.md`
- `3-rules/R9-checklist-template.md`
- `3-rules/R10-batched-authorization-template.md`
- `4-portal/protocol.md`

`#doctrine #r-rules #agora-82 #captain-portal`
