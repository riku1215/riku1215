# PROFILE.md — キャプテン プロフィール

最終更新: 2026-05-10

---

## 1. ユーザー属性情報

* **キャプテン**。AI戦略コンサルタント兼AI駆動アプリ開発者。
* **個人開発者**。riku1215 配下で **46 リポジトリ + 1000+ Issue** を単独運用。
* **拠点: 日本 (青森周辺)**。
* **屋号: QUARD (クオード)** — 個人事業主、法人化前段階。`quard-web.jp` `kuod-hp.vercel.app` 等を運用。

## 2. 興味 / 関心

* **AI駆動SaaS開発**を主軸 (ClassWeaver / pet-care-app / mindgate-tgl / ai-financial-office 等)。
* **商用化アプリの本番デプロイ進行中**: pet-care-app をさくらVPSへ → `petcare.quard-web.jp` 公開予定。
* **エコ開発** (1人で持続可能な 46 repo 並行運用)。
* **AIネイティブワークフロー / Mixed-Initiative UX (Horvitz 1999)** 研究。
* **複数LLM併用** (Claude / Codex / Gemini / Grok / GitHub Copilot)。R14 多LLMレビュー。
* **GitHub CLI + Project v2 + Actions** による開発オペレーション設計。GitHub Issue を**ナレッジDBとして運用** (1000+蓄積)。

## 3. 人間関係

* **青森県・自治体・地域企業との業務関係**。Difyを約60社に紹介、住民監査請求活動 (2026-04-23 ABA朝日放送経由で青森市監査委員会へ提出)。

## 4. 日付があるイベント、プロジェクト、計画

* **2026-04-22 〜 04-30**: sakura `idd53821` 新規開設、VPS仮登録、`classweaver.jp` / `mindgate-tgl.com` 取得 (主運用アカウント基盤整備)。
* **2026-04-23**: 青森市監査委員会事務局へ住民監査請求書を提出、ABA朝日放送ほか地元メディア取材調整。
* **2026-05-02 〜 05-05**: Eco Development System 構築 (agora#53 起点)、P0 Security Hardening 6時間自走セッション。
* **2026-05-08**: 古い休眠アカウント `gck63819` で誤って `quard-web.jp` を取得 → 2026-05-10 に会員間移行が課題化。
* **2026-05-10**: 🚨 **Codex インストールに伴うデスクトップ Claude 消失事故**。Codex も使用上限到達。Web版 Claude で業務継続中。`C:\Users\m\.claude` 資産は生存・Codex がバックアップ済み。Claude 環境再整備完了 (VS Code 拡張 / Desktop App / CLI 2.1.87)。

### 進行中の業務継続課題 (2026-05-10)

1. pet-care-app 本番 deploy (PR#52 が GitHub billing/spending limit で CI停止中)
2. GitHub MCP scope が `riku1215/riku1215` 1個に制限 (要 claude.ai 拡張)
3. sakura 会員間ドメイン移行 (`gck63819 → idd53821`, `quard-web.jp`)
4. 詐欺継続課金 LOPITAL/PDFLEADER 月¥8,999 (PayPal) の解約
5. GCP 二重アカウント (月¥10,000) の整理

## 5. コミュニケーション / 対話スタイル指示 (本人要求)

* **★ 推奨度付き複数案提示** / **反論歓迎 (R8)**。
* **結論→詳細** / **200字以内結論** / **アクション提案で締める**。
* **時間を奪う提案 NG** / **不正確表現 NG**。
* **多LLMレビュー前提 (R14)** / **反論・批判含む議論歓迎**。
* **R10 一括承認 (Batched Authorization)**: 提案前に複数案を一括取得。
* **R9 Pre-action Checklist** 通過後に提案 (R1番号付/R3トークン量/R5user負担/R7知識前提/R8反論余地)。
* **Codex由来フォーマット併用可**: 「① 判断 / ② trade-off / ③ 懸念」。

## 6. 運用ルール / インフラ

* **運用ルール体系**: R1〜R10 (agora#4 が global instruction)。CLAUDE.md にセッション開始ワークフロー記載。
* **ナレッジハブ**: `riku1215/agora` (1000+ Issueを構造化知識として運用)。
* **主要ドメイン**: `quard-web.jp` (運用予定) / `classweaver.jp` / `mindgate-tgl.com` / `kuod-hp.vercel.app` (現運用)。
* **月額ランニング** (2026-04締め): 楽天¥69,240 + PayPay¥83,494 = **¥152,734**。改善余地: LOPITAL¥9k + GCP重複¥5k + さくら重複。

## 7. AI/Claude 運用指示 (失敗パターンから抽出)

> 以下は 2026-05-10 セッションで実際に発生した Claude の失敗パターンから恒久化した運用指示。再発を内部的に自己ブロックすること。

### 7-1. 観察精度の徹底

* スクリーンショット受領時は **UI要素 (アイコン形状/ボタンラベル/バッジ) を逐一読み取る**。曖昧判断禁止。
* `Install` ボタンと `⚙ 歯車` (= installed) のような**識別可能要素を混同しない**。識別困難なら「画像から○○が見える/見えない」と事実のみ述べる。

### 7-2. セッション文脈の完全利用

* **既出情報の再確認を禁止**。判断前に直近の Codex ログ / Captain発言 / 添付資料を再参照。
* **対話チャネル自体が情報**: Captain がデスクトップ Claude/Web/CLI のどこで話しているかは、対話文脈とスクショから推察し、再質問しない。
* セッション中の確定事項を内部的に追跡し、毎回参照する。

### 7-3. 推察優先・確認は最小化

* **推察可能なら推察を明示**: 「○○と推察します。違えば訂正ください」形式。
* **確認質問は1メッセージあたり最大2問**。それ以上は分割。
* **既知の事実は再確認しない**。Captain の時間を奪う質問は R5 違反として自己ブロック。

### 7-4. 制約の即時開示 (R7 強化)

* **私が物理的にできない操作は冒頭で明示**: リモートインストール不可、MCP scope外不可、Captain の Windows ローカルファイル直接アクセス不可。
* 隠してから「実はできない」と後出ししない。

### 7-5. 焦点ロック

* Captain の **最優先課題から逸脱しない**。副次トピック (インストール状態確認等) で本筋を遅延させない。

### 7-6. 失敗即時学習

* 誤判断を指摘されたら、**根本原因を1行で明示**してから訂正。「失礼しました」だけで流さない。
* 同パターンの誤りを再発させない (本ドキュメントが再発防止の記録)。

### 7-7. 出力分量の節度

* **結論→詳細**、200字以内結論を先頭。
* 表/見出しを機械的に並べない。情報密度 > 形式整理。
* **アクション提案で締める** (次の Captain 作業を1つ明示)。

### 7-8. 自信度と反論余地

* 推奨には **★ 推奨度** または **確信度 (%)** を付与。
* 「反論歓迎」を明示。多LLMレビュー前提 (R14)。

### 7-9. ツール利用の効率

* **並列実行可能なツール呼び出しは1メッセージで束ねる**。
* 不要な ToolSearch / 既知ツール再ロードを避ける。

### 7-10. 外部LLM相談プロトコル (R14 多LLMレビューの一形態)

**LLM 役割分担**:

| LLM | 領域 | アクセス |
|-----|------|---------|
| **Gemini** | 進め方の迷い / 複数選択肢 / 客観的意見 (戦略・経営判断) | `ask-gemini.sh` / `.ps1` (本セッション直接呼出可) |
| **Codex (ChatGPT / GPT-5)** | テクニカル詳細・コード実装・アルゴリズム選定 | Captain 経由 (本セッション egress block、Windows Codex CLI / ブラウザ) |
| **Grok** | リアルタイム情報・X検索・反論強化 | Captain 経由 (同上) |
| **Claude (私)** | 統合判断・実装・運用 | 主体 |

**トリガー**:

| トリガー | 行動 |
|---------|------|
| 進め方で迷ったとき | `ask-gemini.sh "A vs Bで迷っている。文脈で推奨は?"` |
| 複数の選択肢があるとき | Captain が選ぶ前に Gemini 独立評価を取得 |
| 客観的な意見が欲しいとき | 「私の判断は妥当か、反論あれば」 |
| **テクニカル詳細が必要** | Captain に「Codex に〇〇を聞いてほしい」と依頼 |
| リアルタイム情報が必要 | Captain に「Grok に〇〇を確認してほしい」と依頼 |

**Claude (私) も**自分が判断に迷ったとき、適切な LLM への相談を Captain に提案する。
追従ではなく独立判断を求める設計 (Section 7-8 自信度と反論余地、R14 多LLMレビュー)。

**モデル選定 (Gemini)**:
* `gemini-2.5-pro`: 重い設計判断・経営判断
* `gemini-2.5-flash`: 日常の軽い相談
* `gemini-2.5-flash-lite`: コスト最小の前捌き

---

## 8. Knowledge Base 戦略 (見落とし・手戻り防止)

> 2026-05-10 セッションで確定: AI コスト削減は副次目的、**真の目的は GitHub 戦略の進化と手戻り回避**。

### 8-1. ローカルミラー基盤

* **構築**: `local-kb-setup/setup.ps1` (Windows PowerShell, 1〜2 時間)
* **保管**: `C:\Users\m\.kb\` (Cドライブ完結、外部送信なし)
* **対象**: riku1215 配下 46 repo + 1000+ Issue
* **更新**: `update.ps1` を Task Scheduler で毎朝 09:00 自動実行

### 8-2. 検索階層

| 階層 | ツール | 速度 | 用途 |
|------|--------|------|------|
| L1: 全文一致 | ripgrep (`rg`) | <1秒 | 既知語句で精密検索 |
| L2: 構造化 | jq / PowerShell | 1-3秒 | Issue title / labels / state |
| L3: 意味検索 | ChromaDB + nomic-embed-text (Phase D) | 3-10秒 | 「会員アカウント乗せ替え」→「sakura会員間移行」 |
| L4: AI 統合 | Claude Code (`cd ~/.kb`) | 数秒-数十秒 | 横断的な要約・推論 |

### 8-3. Claude Code 連携プロトコル

`.kb/CLAUDE.md` を配置し、毎セッション開始時に:

1. 全 R-rules を context に焼く (agora.json から抽出)
2. 直近作業の整合性チェック (Section 7-2 セッション文脈の完全利用)
3. **提案前に必ず過去類似議論を検索** (見落とし防止本丸)

### 8-4. Phase 構成

* **Phase A** ★ (`local-kb-setup/setup.ps1`): ローカルクローン + ripgrep
* **Phase B**: 構造化検索ヘルパー (`search.ps1`) — Phase A に同梱
* **Phase C**: 双方向同期 (`update.ps1`) — Phase A に同梱
* **Phase D** (`local-kb-setup/vector-search/`): ベクトル検索 + MCP server
* **Phase D-2** (`vector-search/kb_feedback_ui.py`): Streamlit + SQLite フィードバック付き Web UI (Codex 推奨)
* **Phase E** (`backup.ps1`): バックアップ強化 (git-bundle 月次)
* **Phase F (NAS拡張)** (`expand.ps1` / `docs-mirror.sh`):
  - PR / Releases / Workflow runs / Discussions / Repo メタ追加
  - 外部ドキュメント mirror (Anthropic/MCP/Ollama/Chroma/LlamaIndex 等)
  - C ドライブ 1.47 TB 余裕活用、NAS的アグレッシブ蓄積
* **Phase G**: re-ranker 導入 (Grok レビュー結果: 10K docs で Semantic Collapse、Stanford 論文)
  - 5K docs: 計画開始 / 8K: 必須着手 / 10K: 緊急 (`kb-stats.ps1` で監視)
  - hybrid search (BM25 + vector) または cross-encoder で Top-K 並べ替え
* **Phase H (任意)**: ローカル LLM (Ollama + IPEX-LLM) — ハード次第、3-6ヶ月後判断

### 8-6. Claude Code Skills (Grok Q2 レビュー反映)

Captain の Claude Code 環境に **47 個の skill** がインストール済 (`.agents/skills/`):

**ベース skill pack (Anthropic / Vercel 公式)** — Grok 評価: 失敗率 <5%、安定:
- mcp-builder, claude-api, skill-creator (基盤・最重要)
- pdf, docx, xlsx, pptx (文書処理 — 自治体提案・監査請求)
- frontend-design, web-design-guidelines, brand-guidelines
- deploy-to-vercel, vercel-cli-with-tokens
- webapp-testing, doc-coauthoring, internal-comms
- find-skills (skill 検索の skill)

**コミュニティ skill (Grok 上位 5 推奨)**:
- **grill-me** (max4c): コード書き始める前に 40 問以上質問攻め、設計漏れゼロ
- **tdd** (max4c): test-first 強制ワークフロー
- **write-prd, tech-spec** (max4c): 仕様文書化
- **claude-mem 系** (thedotmack, 74K ⭐): mem-search, make-plan, smart-explore, timeline-report, pathfinder
  → セッション跨ぎ記憶 + コンテキスト圧縮、長時間開発で必須

**セキュリティ注意 (Grok 中程度懸念)**:
- skill は agent 権限でツール呼出可 = **RCE リスク**
- 公式 (anthropics/, vercel-labs/) は sandbox 推奨で比較的安全
- コミュニティ skill の `exec` 含むものは要確認
- 推奨: self-hosted + allowlist、AI 生成 skill は要レビュー

### 8-7. 先行事例 (Grok Q3 レビュー反映)

直近 Reddit で「30+ repo solo dev + Local KB」事例 5 件確認。Captain の構成 (案A'')
と特に**事例 2** (SQLite + Ollama nomic-embed-text + MCP) は**完全一致**。

| 事例 | 構成 | 1年運用 | 月額 |
|------|------|---------|------|
| 1: Mem0 MCP | persistent memory MCP | 数百セッション継続 | ¥0 |
| **2: SQLite + Ollama + MCP** | **本案A'' とほぼ同じ** | 数ヶ月継続 | ¥0 |
| 3: Markdown + SQLite hybrid | RRF reranking | 1年超継続 | ¥0 |
| 4: clankbrain | structured memory + drift detection | 139セッション継続 | ¥0 |
| 5: Jarvis | Ollama + Knowledge Graph | 96.5% test coverage、生産運用 | ¥0 |

### 8-8. 成功・失敗パターン (Grok Q3 抽出)

**成功 9 要素**:
1. シンプルから始めよ (CLAUDE.md → MCP/hybrid search)
2. raw ではなく **「タイトル + 要約」を embed** (精度+軽量化)
3. **layered context**: summary 常時参照 + semantic 必要時
4. **judge LLM** で retrieval 品質を自動学習 → `judge.py` 実装済
5. **drift detection** で古い情報自動更新
6. **deduplication / merge** で重複除外
7. **複数 repo = global memory 層** (context-switching 対策) — PROFILE.md が該当
8. **knowledge graph** で Issue/PR 関連性可視化 (Phase H 候補)
9. **Docker / 再現性** (個人 dev 必須)

**失敗 4 パターン** (避ける):
1. 手動 CLAUDE.md 更新忘れ → 古い情報判断 → 手戻り
2. embedding 品質悪 → noisy retrieval
3. 過剰 RAG (Weaviate 等大規模) → メンテ負荷で挫折
4. 同期忘れ → 古い memory 残存

**クラウド完結派 (Local KB なし) との比較** (Grok 抽出):
- Local KB 派: 60% メッセージ削減、85% 初回コード一致率向上
- クラウド派: context amnesia で毎回 60% 余計説明 → 手戻り多発、再説明疲労
- → **30+ repo 規模では Local KB 派が明確優位**

### 8-9. KB サイズ監視 (重要)

Grok レビュー (2026-05-11) で **Semantic Collapse の 10K docs 境界線** を発見。
Stanford 論文によると docs 数 10K 超で RAG 精度が 87% 急落。

監視コマンド:

```powershell
.\kb-stats.ps1            # サマリ表示
.\kb-stats.ps1 -Json      # JSON 出力 (cron 監視用)
```

```bash
./kb-stats.sh --json | jq .status
```

Status: SAFE (<5K) / GROWING (5-8K) / WARN (8-10K) / CRITICAL (>=10K)

Captain の現在: Issue 1000+ → Phase F で PR/Release 追加で 2-5K 範囲想定、
SAFE ゾーン継続見込み。10K 接近時は Phase G 着手必須。

### 8-5. 副次効果 (AIコスト削減)

| 項目 | 月額削減 |
|------|----------|
| Claude API (ローカル前捌き) | ~¥7,000 |
| Copilot 部分置換 | ~¥1,500 |
| GCP 二重閉鎖 | ¥10,000 |
| LOPITAL 解約 | ¥9,000 |
| **合計** | **約 ¥27,500/月 (年¥330,000)** |

ただしこれは副産物。**本来の価値は「見落としによる手戻り工数を月数十時間削減」**にある。
