# 05: pet-care-app PR #52 CI 再実行と マージ

## ゴール
GitHub spending Budget 設定により CI 停止が解消されたはずなので、PR #52 を再起動し問題なければマージ→ deploy へ進める。

## 背景
- PR #52: pet-care-app の さくらVPS deploy 準備 (Codex セッションで作成)
- 内容: `.env` 事前検査、nginx bootstrap/HTTPS 切替 script、deploy 手順更新
- 停止原因: 「recent account payments have failed or your spending limit needs to be increased」
- 対策完了: Actions $50 budget + Packages $10 budget 設定済 (2026-05-10)

## 前提
- このセッションは `riku1215/riku1215` 1個のみ スコープ → **pet-care-app は触れない**
- 実行は **(a)** デスクトップ Claude / CLI、または **(b)** GitHub MCP scope 拡張済の新セッションが必要

## Step 1: PR #52 の現状確認

ブラウザで開く:
- https://github.com/riku1215/pet-care-app/pull/52

確認項目:
1. **Checks タブ**: 失敗している job 一覧
2. **失敗 job 詳細** → ログの最後 20行 をコピー (エラーメッセージ特定)
3. **Files changed**: 直近の変更点を再確認

## Step 2: CI 再実行

1. Checks タブ → 右上 **「Re-run failed jobs」** または **「Re-run all jobs」**
2. 数分待機 → 結果確認

## Step 3: 結果別の対処

### 3-A: 全て green ✓
→ Step 4 (マージ) へ

### 3-B: spending limit 系エラー再発
- どの SKU で止まっているか判別 (Actions / Packages / Codespaces / Premium runners)
- 該当 SKU の budget を増額: https://github.com/settings/billing/budgets

### 3-C: 実コードの問題
- エラーメッセージを共有 (Captain → Claude session)
- 修正 PR or PR#52 に追加 commit

## Step 4: マージ前の最終チェック

- [ ] `.env.example` がコミット済、本番値は含まれない
- [ ] `docs/deploy_sakura_vps.md` に手順が反映済
- [ ] `nginx/templates/petcare.https.conf.template` に SSL 設定
- [ ] `scripts/check_prod_env.sh` で .env 検査ロジック
- [ ] `scripts/render_nginx_conf.sh` で nginx config 生成

## Step 5: マージ

GitHub UI → **「Merge pull request」** (Squash merge 推奨) → 削除 source branch

## 完了後の次ステップ (deploy 実行)
PR#52 が main に入ったら:

1. さくらVPS (`133.242.136.126`) に SSH 接続
2. リポジトリを clone
3. `.env` 本番値を配置
4. `scripts/check_prod_env.sh` 実行 → エラーなし確認
5. `docker compose -f docker-compose.prod.yml up -d`
6. `scripts/render_nginx_conf.sh && systemctl reload nginx`
7. `https://petcare.quard-web.jp` を確認

→ 詳細は `pet-care-app/docs/deploy_sakura_vps.md` を参照

## 成功判定
- PR#52 が merged 状態
- `https://petcare.quard-web.jp` が 200 OK で pet-care-app のトップが表示

## 関連リソース
- agora#79 (sakura VPS hardening の進捗 comment 既存)
- `BILLING_ESCAPE_PLAN_2026-05-10.md` (ローカル / Captain Windows に Codex 配置)
- `RECOVERY_QUEUE_2026-05-10.md` (同上)
