---
tags: [risks, mitigations, llm-review, phase-d, phase-d-2, knowledge, architecture]
layer: knowledge
audience: [captain-only, claude]
status: active
created: 2026-05-11
---

# リスク・対策一覧 (R14 多LLMレビュー結果統合)

`#risks #mitigations #llm-review #architecture`

## 出典

- **Grok Q1** (X 検索、直近90日): 「静かな構成」、ただし 10K docs で Semantic Collapse
- **Gemini Q1 レビュー**: Grok 限界を補完、技術的観点で 4 つの実用課題抽出
- **Codex (ChatGPT) Q1**: Streamlit + SQLite WAL 設計推奨 (Phase D-2 採用)

## R1. ChromaDB 排他制御 (Gemini 指摘)

`#chromadb #concurrency #risk-high #phase-d`

### 実態
- ChromaDB `PersistentClient` は内部で SQLite (メタデータ) + Parquet (ベクトル) 使用
- SQLite WAL モードは「1 writer + N readers」許容
- **Streamlit マルチスレッド** (複数タブ・複数ユーザ) + `st.cache_resource` で**クライアント使い回し**時、他プロセス書込みと衝突して `database is locked` エラー頻発

### 対策

| 段階 | 対策 | コスト |
|------|------|--------|
| 1 (現状) | 個人利用 + 同時アクセス 1 セッションなら問題発生確率低 | 0 |
| 2 (中規模) | **ChromaDB クライアント/サーバーモード** (HTTP 経由) で独立稼働 | 30 分 (Docker起動) |
| 3 (将来) | Qdrant / pgvector に移行 | 数時間 |

### 推奨
- 個人運用 1 セッション → 現状継続 OK
- 複数タブ・MCP server 並走 → 段階 2 (Chroma サーバーモード) 推奨

## R2. Streamlit st.cache_resource メモリリーク (Gemini 指摘)

`#streamlit #memory-leak #risk-medium #phase-d-2`

### 実態
- Streamlit はスクリプト全体を再実行するアーキテクチャ
- `st.cache_resource` はコネクションを保持
- 開発・運用過程で**リロード繰り返し** → 古いセッションメモリ解放追いつかず
- ChromaDB Rust コア / Ollama 呼出オーバーヘッドが蓄積 → OOM クラッシュ

### 対策

```python
# kb_feedback_ui.py 改良 (将来)
@st.cache_resource(ttl=3600, max_entries=1)  # 1時間で自動失効
def get_collection():
    ...
```

- **TTL 設定**: 1 時間で自動再生成
- **定期再起動**: Streamlit プロセスを毎日 09:00 (Task Scheduler) で再起動
- **メモリ監視**: kb-stats.ps1 拡張で Streamlit プロセス RAM 計測

## R3. Ollama + Iris Xe = CPU フォールバック (Gemini + Grok 一致指摘)

`#ollama #iris-xe #performance #risk-low #phase-d`

### 実態
- Windows Ollama はバックエンド llama.cpp 依存
- Intel Iris Xe は Vulkan / OpenVINO **明示セットアップ無しでは CPU (AVX2) フォールバック**
- nomic-embed-text 軽量モデルでも、1000 docs バッチ embedding で NVIDIA 比 **10倍+ 時間**

### 影響予測 (i7-1355U + Iris Xe + 32GB RAM)

| 作業 | NVIDIA RTX 4070 | i7-1355U CPU |
|------|----------------|-------------|
| 1000 docs 初回 embedding | 3-5 分 | **30 分 - 1 時間** |
| 単発 query | <100 ms | 200-500 ms |
| 8 docs 評価 (judge.py) | 1-2 秒 | 5-10 秒 |

### 対策

| 案 | 効果 | コスト |
|----|------|--------|
| 1. CPU 受容 (現状) | 軽量モデルなら実用 | 0 |
| 2. **IPEX-LLM** (Intel 公式) で Iris Xe 活用 | 2-3 倍速化期待 | 1-2 時間設定 |
| 3. Ollama → llamafile (Vulkan) 切替 | 同上 | 1 時間 |
| 4. クラウド embedding (OpenAI/Cohere) | 100倍速、ローカルC完結性失う | $/月 |

### 推奨
- 初期: 案1 で動作確認 (`python index.py` を夜間バッチで)
- 速度不満なら: 案2 IPEX-LLM

## R4. UX 摩擦 (Gemini が指摘した **真の失敗要因**) ★最重要

`#ux-friction #adoption #risk-high #phase-d-2 #captain-portal`

### 実態
1000 docs 規模ローカル RAG の「2週間で使わなくなる」最大要因は **Semantic Collapse ではない**:

> 「立ち上げが遅い」「Streamlit UI がもっさり」
> 「結局、該当部分を手動でコピーして優秀な LLM (Gemini等) に直接貼り付けた方が早くて正確」
> → **ローカル RAG を起動するモチベーションが削がれる**

### 対策 (Phase D 設計の優先順位再評価)

| UX 形態 | 起動コスト | 採用予想 |
|---------|----------|---------|
| **MCP server (Claude Code 内)** | **ゼロ** (Claude Code 既に起動済) | ★★★★★ |
| Streamlit Web UI | ブラウザ起動 + URL 入力 | ★★ |
| CLI (python ask.py) | 端末切替 | ★★★ |

### Phase D-2 設計変更

**従来**: Streamlit Web UI を main UX として推奨  
**変更後**:
- **Main UX**: Claude Code 内で `search_kb` ツール呼出 (MCP 経由、ゼロクリック)
- **Streamlit UI**: **分析専用** (フィードバック表示・統計、毎日 09:00 一括確認)
- **CLI**: スクリプティング・自動化用

つまり Captain の通常使用フロー:
```
Claude Code 起動 → 質問 → Claude が自動で search_kb 呼出 → KB データ込みで回答
```
→ KB を意識せずに使える = UX 摩擦最小 = 「使われなくなる」回避

## R5. Semantic Collapse > 10K docs (Grok 指摘)

`#semantic-collapse #scale #risk-medium #phase-g`

### 実態
Stanford 論文: 10K docs 超で RAG 精度 87% 急落。1000 docs 以下は安全ゾーン。

### Captain 現状
- Issue 1000+
- Phase F (PR/Release 追加) で 2-5K 想定
- → SAFE ゾーン継続見込み

### 対策
- `kb-stats.ps1` で監視 (5K で警告、8K で必須着手、10K で緊急)
- Phase G: re-ranker (BM25 + cross-encoder) 導入

## R14 サイクル 3: ChatGPT (Codex) Q1 レビュー (2026-05-11)

`#llm-review #chatgpt #codex #r14`

ChatGPT が Grok 回答を厳密検証、**X 投稿 URL の検証性弱さ**を指摘し
公式制約ベースで以下を補強:

### 重要発見

1. **「投稿がない」≠「リスクなし」**: Chroma 公式ドキュメントは
   「PersistentClient は同一ローカルパス共有の concurrent writers に process-safe ではない」と明記
2. Grok 提示の X URL 4 件、ChatGPT 検索で再現性弱 (タイムスタンプ整合性は OK)
3. 実運用で見るべき**真のリスク 4 つ** (Grok/Gemini が触れなかった):
   - KB 更新中に UI/MCP が古い index を読む不整合
   - Chroma collection 再作成時に feedback の doc_id 失効
   - Streamlit キャッシュが古い client/collection 保持
   - 1000 docs で**検索品質低い** → feedback UI を開く心理コストが上回る

### 実装済対策 (このセッションで反映)

- ✅ **kb_feedback_ui.py に `@st.cache_resource(ttl=3600)`** 追加
- ✅ **SQLite `PRAGMA busy_timeout=3000`** 追加 (concurrent write retry)
- ✅ **rebuild.py 新規実装** (atomic swap pattern):
  - `$HOME/.kb/chroma_build_<TS>` で新規構築
  - 完了後 `$HOME/.kb/chroma_<TS>` にリネーム
  - `$HOME/.kb/chroma_current` symlink を atomic に切替
  - 過去 build を `--keep N` 世代まで保持 (rollback 可能)

### ChatGPT 最終判断 (採用)

> 実装は **Streamlit + SQLite WAL + Chroma read-only + ingest 単一 writer + st.cache_resource(ttl=3600)** で進めて下さい。

→ 全要素実装済。

## R14 サイクル 4: ChatGPT 深堀りレビュー (2026-05-11)

`#llm-review #chatgpt #r14 #production-ready`

ChatGPT が公式 (Chroma Cookbook / GitHub Issue / Streamlit docs / SQLite docs)
の根拠ベースで再構築。**Windows 配慮** + **再 embed 時の履歴保護** を強化。

### 重要発見

1. **Chroma GitHub Issue 実例**:
   - 2 プロセス同時 → `get` で更新見えるが `query` で反映されない不整合報告あり
   - PersistentClient 破棄後の内部状態残存 → 再作成で `attempt to write a readonly database` エラー
2. **Streamlit st.cache_resource 公式注意**:
   - singleton 共有・mutation/concurrency クラッシュ警告あり
   - `.clear()` API 公式提供 → UI に **手動 clear ボタン**推奨
3. **SQLite WAL 制約**: network filesystem では使用不可
   (Captain は local Windows = OK)
4. **doc_id だけだと再 embed 時に失効**: chunk_hash が必須
5. **Windows ディレクトリ rename**: プロセス保持中失敗の可能性
   → **symlink swap より `current_path.txt` 方式が安全**

### 実装変更 (このコミットで反映)

- ✅ **`current_path.txt` 方式** に rebuild.py を変更 (symlink 廃止、Windows-safe)
- ✅ **kb_feedback_ui.py が current_path.txt を読込** (TTL切れ時に新 build に追従)
- ✅ **feedback schema 拡張**: `collection_version` + `ollama_version` 追加
- ✅ **chunk_hash インデックス追加** (`idx_feedback_chunk`)
- ✅ **「Clear Chroma cache」ボタン** Streamlit sidebar に追加
- ✅ **exports/ ディレクトリ** で pairwise JSONL を整理 (`feedback_pairwise_<TS>.jsonl`)
- ✅ Backwards-compat: ALTER TABLE で既存 DB に新カラム追加 (データ保護)

### ChatGPT 最終戦略 (採用)

> Streamlit でまず feedback 収集を 2 週間続け、SQLite から query × useful/unuseful chunk を蓄積。
> 次にやるべきは feedback.sqlite3 → pairwise JSONL export。

→ Sidebar 「Export pairs → JSONL」ボタン経由で実現。
2 週間の feedback 蓄積後、Phase G (re-ranker 学習) の入力データになる。

### 最終 layout (R14 4 サイクル 統合結果)

```
$HOME/.kb/
├── current_path.txt              ← 現在の chroma path 記述
├── chroma_<YYYYMMDD_HHMM>/       ← 各世代の build (--keep N 保持)
├── chroma_build_<YYYYMMDD_HHMM>/ ← ingest 中 (一時)
├── feedback.sqlite3              ← Streamlit が書く (WAL モード)
├── exports/
│   ├── feedback_pointwise_<TS>.jsonl
│   └── feedback_pairwise_<TS>.jsonl
├── repos/                        ← Phase A
├── issues/                       ← Phase A
└── chroma_db/                    ← legacy (fallback、index.py 使用時)
```

## まとめ (R14 4 サイクル 結論)

| 要素 | リスクレベル | 緊急度 | 実装状況 |
|------|------------|--------|---------|
| R1 ChromaDB 排他制御 | 中 | 段階 2 で対応 | 個人利用範囲は OK |
| R2 Streamlit メモリリーク | 中 | TTL 設定で軽減 | 改善余地 |
| R3 Ollama CPU フォールバック | 低 | 時間予測修正 | 受容 |
| **R4 UX 摩擦** | **高** | **設計優先順位変更** | **MCP main UX 化** |
| R5 Semantic Collapse | 中 | 5K 時点で対応 | 監視中 |

### 結論

**Gemini Q1 レビューの最大価値**: 「**Streamlit を main UX にすべきではない**」という設計変更示唆。  
**MCP server (Claude Code 統合)** をメインに据え、Streamlit は分析専用化する方針が確定。
