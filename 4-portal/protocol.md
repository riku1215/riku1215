---
tags: [captain-portal, protocol, orchestration, harness, phase-1, dify-alternative]
layer: portal
audience: [captain-only, claude]
status: active
updated: 2026-05-11
---

# Captain Portal — オーケストレーションプロトコル

`#captain-portal #protocol #harness #dify-alternative`

**役割**: タスク受領から完了までの全工程を「役割 × 階層分岐 × 反論強制」で運用する規約。Dify を使わず本ハーネスで同等以上の自動分岐を実現する。

---

## 0. 設計思想

Captain 発言 (2026-05-11):
> 本来ならハイスペック構成にして、それぞれの役割の Agent（LLM モデル）を学習させ機能特化させ、役割分担で走らせる…ただ今はその前の段階として、LLM はローカルに置かずに一般的なものを利用して、役割と knowledge、Skills、他でハーネス設計して、理想の形にどれだけ近づけるか…

> Dify を使わずとも、階層構造で、同じような分岐は作れるはず。分岐が上手くいけば、最適な Agent が働いてくれるはず。

**結論**: Phase 1 は **fine-tune の代わりに「system prompt + skill 制約 + knowledge スコープ」で擬似専門化**、**Dify の代わりに「YAML routing + 階層フォルダ + 単純な dispatcher script」で分岐**を実現。

---

## 1. アーキテクチャ全景

```
[Captain 入力]
      │
      ▼
┌─────────────────────────────┐
│ route.sh / route.ps1        │  ← routing.yml 解釈、agent パイプライン決定
└─────────────────────────────┘
      │
      ▼
[orchestrator] R9 Pre-action Checklist
      │
      ├──> [researcher]   過去議論検索 (~/.kb/)
      │
      ├──> [architect]    設計 (Claude)
      │
      ├──> [critic]       反論 (Grok / Gemini) ★ R8 強制
      │
      ├──> [coder]        実装 (Claude)
      │
      ├──> [reviewer]     レビュー (ChatGPT 経由) ★ R14
      │
      └──> [historian]    記録 (~/.kb/ + claude-mem)
      │
      ▼
[orchestrator] R10 Batched Authorization → Captain
```

各 agent = (LLM × skills × knowledge スコープ) の組合せ。`agents.yml` に定義。

---

## 2. 階層分岐の仕組み (Dify 代替)

### 2-1. 入力 → ルール match

`routing.yml` の `rules` を上から評価:

| 優先度 | ルール ID | 判定基準 |
|--------|-----------|---------|
| 0 | explicit-mention | `@architect` 等明示指定 |
| 1 | urgent-bypass | 緊急/急ぎキーワード |
| 2 | bug-fix / new-feature / refactor / ... | タスク種別 |
| 3 | pure-question | `?` 終わり、実装語なし |
| 99 | default | 全て fallback |

最初に match した rule の `pipeline` を採用。

### 2-2. パイプライン実行

`pipeline: [orchestrator, researcher, architect, critic, coder, reviewer, historian, orchestrator]`

→ 順次実行。各 agent は前の agent の output を context として受領。

### 2-3. フィードバックループ

| トリガー | 動作 | 最大反復 |
|---------|------|---------|
| `reviewer.verdict == rejected` | `coder` へ戻る | 3 |
| `critic.severity == critical` | `architect` へ戻る | 2 |
| `researcher.hits == 0` | orchestrator へ通知 (新規領域警告) | — |

### 2-4. なぜ Dify 不要か

| Dify 機能 | 本ハーネス代替 |
|-----------|---------------|
| Workflow GUI | `routing.yml` (テキスト編集、git diff 可視) |
| LLM 切替 | `agents.yml` の `llm.primary/fallback` |
| Knowledge 連携 | `~/.kb/` 直接 (Phase D ChromaDB 経由) |
| Variable 受渡 | shell パイプ + JSON |
| 分岐 | `rules` decision tree |
| Logging | `~/.kb/routing.log` |
| 多 LLM | R14 で既に実現済 |

**追加コスト**: ゼロ (既存資産のみで構築)。

---

## 3. 各 agent の振舞い規約

### orchestrator (Claude、本セッションの私)
- 受領時に必ず R9 Pre-action Checklist 通過
- R10 Batched Authorization 形式で Captain へ提示
- 並列実行可能な agent は同時 fan-out
- 最終出力は 200 字結論 + ★ 推奨度 + アクション 1 件

### researcher (Gemini / Claude)
- 必ず `~/.kb/` から過去 Issue/PR/議論を検索
- 検索クエリ + ヒット数 + 関連番号を明示
- `hits == 0` なら新規領域フラグを立てる

### architect (Claude / Gemini)
- 設計判断は必ず 3 案以上 (★ 推奨度付き)
- trade-off 表 + 反論余地を明記
- skills: grill-me で漏れ検出、write-prd で文書化

### critic (Grok / Gemini) ★ R14 強制
- architect とは**別 LLM** を必須 (echo chamber 防止)
- 反論最低 3 件
- リスク確率 × 影響度マトリクス
- 「現状で問題ない」結論は禁止 (必ず何か指摘)

### coder (Claude / ChatGPT)
- TDD 推奨 (skill: tdd)
- 変更ファイル一覧 + diff + rollback 手順
- Phase D-2 で feedback DB に記録

### reviewer (ChatGPT 経由 / Claude)
- severity: critical / warn / info の 3 段階
- critical あれば coder へ自動 loop-back
- 承認後に historian へ

### historian (Claude)
- セッション終了時に必ず `~/.kb/` + claude-mem へ記録
- 次セッション引継メモを 200 字で作成
- timeline-report で全 agent 呼出履歴を残す

---

## 4. 階層構造との対応 (Portal Level 1-3)

```
Portal/
├── 0-foundation/   # R-rules, doctor.ps1, ask-gemini.sh
├── 1-knowledge/    # ~/.kb/ (researcher / historian の scope)
├── 2-intelligence/ # ChromaDB, judge.py (researcher の semantic search)
├── 3-interface/    # Streamlit feedback (Captain ↔ orchestrator)
├── 4-portal/       ← 本プロトコル + agents.yml + routing.yml ★ ハーネス核
├── 5-product/      # ClassWeaver / pet-care 等 (coder の deploy 対象)
└── 6-meta/         # ~/riku1215/ (PROFILE.md, agora#4 R-rules)
```

各 agent の `knowledge_scope` は上記層を **明示的に参照範囲制限**。
これが「役割と knowledge」を結合する Phase 1 の擬似 fine-tune。

---

## 5. R-rules との対応

| R-rule | 適用 agent | 強制方法 |
|--------|-----------|---------|
| R1 番号付け | orchestrator | output_format で必須化 |
| R3 トークン量 | orchestrator | 200 字結論ルール |
| R5 user 負担 | orchestrator | 質問 ≤ 2 個/turn |
| R7 制約開示 | orchestrator | 冒頭 disclosure 必須 |
| R8 反論余地 | critic | always_apply で強制 |
| R9 Pre-action | orchestrator | 最初に必ず通過 |
| R10 Batched Auth | orchestrator (final) | output_format |
| R14 多 LLM | critic | different_llm_than_architect |
| R71 Plan-first | orchestrator | implementation 前に確認 |

---

## 6. 運用例 (実タスクでの分岐)

### 例 1: 「pet-care-app PR #52 の CI 失敗を直して」
- Match: `bug-fix` (キーワード "失敗", "直して")
- Pipeline: `[orchestrator → researcher → coder → reviewer → historian → orchestrator]`
- researcher: 過去 PR #52 議論を `~/.kb/prs/pet-care-app.json` から抽出
- coder: 修正 patch 生成
- reviewer: severity 判定
- historian: 記録 → 次セッション引継

### 例 2: 「Phase 2 で hi-spec マシン買うべきか」
- Match: `strategy-decision` ("戦略", "判断")
- Pipeline: `[orchestrator → researcher → architect → critic → orchestrator]`
- researcher: 過去ハード議論 + 価格動向
- architect: Galleria 中古 vs RTX 5090 新 vs Mac Studio の 3 案
- critic (Grok): 反論 3 件 (中古リスク、待機機会損失、商用化時 spec 不足)
- orchestrator: R10 一括承認形式で提示

### 例 3: 「@critic この設計どう思う?」
- Match: `explicit-mention`
- Pipeline: `[orchestrator → critic → orchestrator]`

---

## 7. 効果測定 (Phase 1 完了基準)

- [ ] 実タスク 5 件で routing 自動分岐成功 (Captain 介入ゼロで pipeline 選択)
- [ ] `researcher.hits` で過去議論ヒット率 ≥ 70%
- [ ] `critic` が architect 提案に対し平均 3 件以上の反論
- [ ] 1 セッションの平均 LLM コスト ≤ ¥100
- [ ] historian 記録で次セッション復元成功率 ≥ 90%

達成時 → Phase 2 (hi-spec 移行 + 商用パッケージ化、Kuuki Design 18-agent 拡張) へ。

---

## 8. 実装ファイル

| ファイル | 役割 | 状態 |
|---------|------|------|
| `4-portal/agents.yml` | 7 役定義 + LLM/skill/scope 紐付け | ✓ 本 PR |
| `4-portal/agent_profiles.yaml` | retrieval policy per role (ChatGPT 提案) | ✓ 本 PR |
| `4-portal/routing.yml` | 分岐 decision tree | ✓ 本 PR |
| `4-portal/protocol.md` | 本ファイル | ✓ 本 PR |
| `4-portal/route.sh` | dispatcher (Linux/macOS) | ✓ 本 PR |
| `4-portal/route.ps1` | dispatcher (Windows) | ✓ 本 PR |
| `4-portal/portal-init.ps1` | Portal 骨格生成 | ✓ commit 3758f12 |
| `1-knowledge/prior-art-2026-05-11.md` | Grok+Gemini+ChatGPT R14 レビュー記録 | ✓ 本 PR |

---

## 9. Issue-as-shared-memory (Gemini G1、2026-05-11 R14)

**Gemini 提案**: GitHub Issue を agent 間の「外部の脳 (共有メモリ)」として運用。

### 動作モデル
```
[architect 出力] → Issue body 書込 (gh issue create / comment)
                       ↓
[coder] ← Issue text のみ読込 (RAM 不要、テキスト渡し)
                       ↓
[reviewer 出力] → 同 Issue にコメント追加
                       ↓
[historian] → 完了時に Issue close + 要約付与
```

### 利点
- ローカル RAM 負荷ゼロ (テキスト受渡しのみ)
- 永続記憶 (GitHub に保存、セッション跨ぎ)
- 監査可能 (全 agent の発言が Issue 履歴に残る)
- Captain がいつでも介入可

### 実装ルール
- 全 agent は GitHub Issue を **first-class state** として扱う
- `gh issue create` で task Issue を起点、各 agent はコメントで進捗報告
- R66 (md → Issue paste) を徹底
- 完了時 historian が 200 字要約 + 引継メモ追記 → close

---

## 10. Safety Breakwater (Gemini G2 + ai-financial-office#77 L0-L3 階層、2026-05-11)

### 10-0. 階層化 L0-L3 (ai-financial-office#77 反映)

ai-financial-office の **バルク承認実装** で実証された 4 段階階層モデル:

| Level | 操作種別 | 例 | 自動度 |
|-------|---------|-----|--------|
| **L0** | read-only / dry-run | search_kb / git log / curl GET | 即実行 (R20 auto-execute OK) |
| **L1** | ローカル file edit (workspace 内) | Edit/Write tool、agoora 配下のみ | **自動実行** (Captain 通知のみ) |
| **L2** | git commit / API call / Issue 作成 | git commit、gh issue create | **R10 Captain 確認**必須 |
| **L3** | 破壊的操作 (取消不可) | rm -rf、git push --force、DROP TABLE | **二重承認**必須 (R10 + 「yes/yes」明示) |

50 件超選択時の **警告表示** (#77 pattern):
> 「N 件処理します。元に戻せません」

`route.sh / route.ps1` の Safety Breakwater で本階層を強制実装。



**Gemini 提案**: LLM はコマンド文字列を出すだけ、ローカルが Captain 承認後に実行する「防波堤」。

### 危険ゾーン分離
| 層 | 担当 | 権限 |
|----|------|------|
| LLM (Claude/Gemini/Grok) | 推論・計画・コマンド生成 | テキスト出力のみ |
| route.sh / route.ps1 | コマンド受領・dry-run | 実行不可 |
| Captain 承認 | yes/no | R10 Batched Authorization |
| ローカル shell | 承認後実行 | フル権限 |

### 強制ルール
- LLM 出力に含まれる shell コマンドは **既定 dry-run**
- `--execute` flag 明示時のみ実行
- 破壊的操作 (rm -rf, git push --force, DELETE etc.) は **二重承認** (Captain + R9 checklist)
- R10 Batched Authorization の出力フォーマット:
  ```
  以下のコマンドを実行します (yes/no):
  1. git add 4-portal/
  2. git commit -m "..."
  3. git push origin <branch>
  ```

---

## 11. Phase 1 KPI (Gemini Phase 1 目標 + ChatGPT ロードマップ統合)

### 目標 (Phase 1 完了基準)

1. **「1 Issue 起点の完全自動リレー」完成**
   - Issue 「○○ 機能追加」起票 → researcher 調査 → architect 設計 → coder 実装 → reviewer レビュー → historian 完了報告 を **Captain 1 クリック (R10)** で完遂

2. **トークン消費最適化**
   - 重い思考: claude-opus / 中: claude-sonnet / 軽: claude-haiku, gemini-flash
   - 振り分けは `agent_profiles.yaml` の `llm_hint` に従う

3. **API 向き先 localhost で Phase 2 移行可能**
   - 疎結合設計、agents.yml の `llm.primary` を変えるだけで local LLM へ切替可

### 効果測定
- routing.log で pipeline 選択精度 ≥ 90%
- feedback.sqlite3 で role 別 retrieval 品質 ≥ 4/5
- 1 セッション平均 LLM コスト ≤ ¥100
- historian 引継で次セッション復元成功率 ≥ 90%

---

## 12. 次のステップ

1. **Captain レビュー** (本 PR ドラフト)
2. **agents.yml の調整** (役割追加/削除、LLM 割当変更)
3. **route.sh 動作確認** (Linux/macOS、本セッション可)
4. **route.ps1 実装** (Windows、Captain 環境)
5. **実タスク 1 件で試行** (Issue #8 pet-care-app PR #52 推奨)
6. **メトリクス収集 1 週間** → Phase 2 判断

`#captain-portal #protocol #phase-1 #harness-design`
