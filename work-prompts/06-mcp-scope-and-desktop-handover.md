# 06: MCP scope 拡張 / デスクトップ Claude への引き継ぎ

## ゴール
GitHub MCP scope を `riku1215/riku1215` 1個 → 全 46 repo に拡張する。または、デスクトップ Claude (制限なし) に業務を引き継ぐ。

## 背景 (Section 7-6 失敗学習)
**当初の誤認**: 「GitHub App scope 拡張で解決」と説明していた。
**実態**: 2層構造であり、層1 (GitHub App 権限) を拡張しても、層2 (この Web セッションの MCP 設定) は作成時固定で変更不可。

| 層 | 場所 | 状態 |
|----|------|------|
| 層1: GitHub App 自体の repo 権限 | github.com/settings/installations | Captain が拡張済 (推察) |
| 層2: このセッションの MCP 設定 | Claude Code on web のセッション作成時固定 | **`riku1215/riku1215` ハードコード** |

## 解決策 (推奨度順)

### 案A: デスクトップ Claude / CLI へ乗り換え ★★★★★

**根拠**:
- Windows ローカル `C:\Users\m\.claude` は MCP config + memory + 30+ session jsonl 完全復活済
- 全 repo + ローカルファイル両方触れる
- このセッションの文脈ロストは下記引き継ぎテキストで補える

**手順**:
1. Windows で **デスクトップ Claude** を起動 (またはターミナルで `claude`)
2. 新規セッションで下記「引き継ぎテキスト」をペースト
3. デスクトップ Claude が業務継続

### 案B: 新規 Web セッション開始 ★★★

スコープ広く再作成。ただし claude.ai/code の新規セッション作成時に対象 repo を明示的に追加する必要あり (具体UIは Captain が試行)。

### 案C: 現セッション継続 (riku1215/riku1215 のみで作業) ★

quard-web-jp や agora 等の他 repo は触れないが、profile 関連の commit と Gmail 検索は引き続き可能。

## 引き継ぎテキスト (デスクトップ Claude に渡す用)

```
本日 2026-05-10 の Web セッションからの引き継ぎ:

完了:
- PROFILE.md 作成 (Section 7 = 失敗パターン恒久化) + CLAUDE.md @import → PR #3 (draft)
  https://github.com/riku1215/riku1215/pull/3
- Gmail分析: LOPITAL月¥9k詐欺継続課金、GCP二重月¥10k、さくら二重アカウント発覚
- GitHub spending Budget: Actions $50, Packages $10 設定済
- Claude復活: VS Code拡張/Desktop/CLI 2.1.87 すべて動作確認
- sakura レンタルサーバ Standard (idd53821 / www2211.sakura.ne.jp) 確認、お試し期間→2026/05/25終了・05/26自動課金
- /home/quard/www に Astro 静的ビルド配置済
- quard-web-jp deploy plan 完成 (Step 2-4: ドメイン追加 / DNS+SSL / GitHub Actions YAML)

進行中タスク (詳細は `work-prompts/` 配下の各 md):
- 01-sakura-domain-migration.md: quard-web.jp 会員間移行 (gck63819 → idd53821)
- 02-quard-web-deploy.md: 移行後の deploy パイプライン
- 03-paypal-lopital-cancel.md: PayPal Lopital 月¥9k 解約
- 04-gcp-dual-closure.md: GCP 二重アカウント閉鎖
- 05-pet-care-pr52-rerun.md: pet-care-app PR #52 CI再実行
- 06-mcp-scope-and-desktop-handover.md: 本ドキュメント

詳細は PR #3 の PROFILE.md と過去30+セッションログを参照。
```

## このセッションでできること (案A前提でも継続可)

- PR #3 の webhook 監視 (CI/レビュー発生で通知)
- `riku1215/riku1215` repo への追加 commit (PROFILE.md 更新、追加ドキュメント等)
- Gmail 検索 (Gmail MCP は健在)
- ローカル grep / 分析

## 成功判定
- デスクトップ Claude が引き継ぎテキストを認識し、`work-prompts/` 配下の手順を実行できる
- または、新規 Web セッションが全 repo に触れる

## 完了後の次ステップ
- 案A 採用なら、本 Web セッションは PR #3 監視と Gmail 分析の補助役にシフト
- 業務本筋はデスクトップ Claude へ
