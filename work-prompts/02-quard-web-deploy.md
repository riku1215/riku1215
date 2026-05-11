# 02: quard-web.jp 公開 (レンタルサーバへドメイン追加 + DNS/SSL + GitHub Actions deploy)

## ゴール
`quard-web.jp` をさくらレンタルサーバ Standard (`www2211.sakura.ne.jp` / `/home/quard/www`) で公開し、`quard-web-jp` GitHub repo から自動 deploy を構築する。

## 前提
- `01-sakura-domain-migration.md` 完了済 (quard-web.jp が idd53821 にある)
- レンタルサーバ Standard お試し期間 **2026/05/25 終了**、05/26 自動課金開始 (継続する場合)
- `/home/quard/www` に既に Astro 静的ビルド済ファイル (`_astro/` `index.html` `images/` `overview/` `products/` `thanks/`) が配置済
- `quard-web-jp` GitHub repo は private、Astro 静的サイト (推察)

## Step 2: レンタルサーバにドメイン追加 (3分)

1. https://secure.sakura.ad.jp/menu/ → **idd53821** でログイン
2. 「**契約中のサービス一覧**」→ **さくらのレンタルサーバ スタンダード**「コントロールパネルを開く」
3. コンパネ左メニュー → **「ドメイン/SSL」→「ドメイン/SSL」一覧**
4. 右上 **「ドメイン新規追加」**
5. **「さくらインターネットで取得したドメイン」**タブ → `quard-web.jp` を選択
6. 「追加」→ 確認 → 完了
7. 公開フォルダ: **`/home/quard/www`** (既存ファイルがある場所)

## Step 3a: DNS ネームサーバ設定 (5分 + 反映最大24h)

1. idd53821 会員メニュー → 「契約中のドメイン一覧」→ `quard-web.jp`
2. **「ネームサーバの設定」** → **「さくらインターネットのネームサーバを利用」**
3. 自動で `ns1.dns.ne.jp` / `ns2.dns.ne.jp` 設定 → 反映待ち (最大24h、通常1〜2h)

## Step 3b: Let's Encrypt 無料 SSL 有効化 (DNS反映後、3分)

1. レンタルサーバ コンパネ → 「ドメイン/SSL」→ `quard-web.jp` 行 → **「SSL」** リンク
2. **「無料SSL設定」**タブ → **「Let's Encrypt 無料SSLを利用する」** ボタン
3. 規約同意 → **「無料SSLを設定する」** → 数分で発行
4. **「常時SSL化」**を ON → http→https 自動リダイレクト

## Step 4: GitHub Actions 自動 deploy (30分)

### 4-1: SSH 鍵生成 (Captain の Windows PowerShell)

```powershell
ssh-keygen -t ed25519 -C "github-deploy-quard-web" -f $env:USERPROFILE\.ssh\sakura_quard_deploy -N ""

# 公開鍵を表示
type $env:USERPROFILE\.ssh\sakura_quard_deploy.pub
# 秘密鍵を表示 (GitHub Secrets に貼る用)
type $env:USERPROFILE\.ssh\sakura_quard_deploy
```

### 4-2: 公開鍵を sakura に登録

sakura レンタルサーバ コンパネ → 「サーバ情報」→「**SSH**」→ **「SSH鍵」** → 公開鍵 (`.pub` 中身) をペースト

### 4-3: GitHub Secrets 登録

`riku1215/quard-web-jp` リポ → Settings → Secrets and variables → Actions → New repository secret:

| Secret 名 | 値 |
|----------|---|
| `SAKURA_SSH_HOST` | `www2211.sakura.ne.jp` |
| `SAKURA_SSH_USER` | `quard` |
| `SAKURA_SSH_KEY` | `~/.ssh/sakura_quard_deploy` の中身 (秘密鍵全文、-----BEGIN/END含む) |

### 4-4: ワークフロー YAML 配置

`quard-web-jp` repo の `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Sakura Rental Server

on:
  push:
    branches: [main, master]
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - name: Build Astro
        run: npm run build
        # ※ Astro 以外なら適宜 (Next.js: npm run build && npm run export → out/)

      - name: Deploy via rsync over SSH
        uses: burnett01/rsync-deployments@7.0.1
        with:
          switches: -avzr --delete --exclude='.well-known'
          path: dist/
          remote_path: /home/quard/www/
          remote_host: ${{ secrets.SAKURA_SSH_HOST }}
          remote_user: ${{ secrets.SAKURA_SSH_USER }}
          remote_key: ${{ secrets.SAKURA_SSH_KEY }}
```

## 成功判定
- ブラウザで `https://quard-web.jp` を開き、`/home/quard/www/index.html` の内容が表示される
- `quard-web-jp` repo の main に push → 数分後 sakura に自動反映

## 失敗時のチェック
- DNS反映: `nslookup quard-web.jp` で sakura IP が返るか
- SSL: `https://quard-web.jp` で証明書エラーなし
- SSH鍵: コンパネで公開鍵が登録されているか、秘密鍵の改行コードが LF か
- Actions エラー: PR上で workflow log 確認

## レンタルサーバ お試し期間の判断
- 2026/05/25 までに公開動作確認 → 継続する場合は何もしなくても 05/26 自動課金
- 継続不要なら **2026/05/24 までに解約** (会員メニュー → 解約)

## 完了後の次ステップ
→ Captain の HP 運用本格開始。
→ 他ドメイン (classweaver.jp, mindgate-tgl.com) も同パターンで応用可能。
