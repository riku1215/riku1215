# agoora-landing — Phase 5 商用化 Landing Page

`#agoora #landing #phase-5 #deploy`

> agoora.jp の **Phase 5 商用化 Landing Page** v0。
> Captain 指示「デプロイできるようになるまで」反映、3 deploy 経路を整備済。

## 📂 ファイル構成

| ファイル | 用途 |
|---------|------|
| `index.html` | Landing 本体 (280 行、Tailwind CDN、zero build) |
| `vercel.json` | Vercel deploy config (cleanUrls + cache headers) |
| `README.md` | 本ファイル |
| `../../.github/workflows/deploy-pages.yml` | GitHub Pages 自動 deploy workflow |

## 🚀 Deploy 経路 (★ 推奨度順)

### ★★★★★ 経路 A: GitHub Pages (推奨、Captain 1 step)

**前提**: riku1215/riku1215 は **public repo** なので GitHub Pages 無料利用可。

#### Captain Windows 1 step 設定

1. ブラウザで開く: https://github.com/riku1215/riku1215/settings/pages
2. **Source** で **「GitHub Actions」**を選択
3. **Save**

→ 本 commit の push で**自動 deploy 開始** (1-2 分)。

#### 確認

- Actions tab: https://github.com/riku1215/riku1215/actions → "Deploy agoora-landing to GitHub Pages" が ✅
- Live URL: **https://riku1215.github.io/riku1215/**

#### 更新 (今後)

`5-product/agoora-landing/index.html` を編集して push するだけで自動再 deploy。

---

### ★★★★ 経路 B: Vercel (連携式、HTTPS + Edge)

#### 初回連携 (5 min)

1. https://vercel.com/ にログイン (GitHub OAuth)
2. **New Project** → `riku1215/riku1215` をインポート
3. **Root Directory** を `5-product/agoora-landing` に設定
4. **Framework Preset** は **"Other"** (静的サイト)
5. **Deploy** クリック

→ 自動 deploy 完了、URL = `https://agoora-landing-XXX.vercel.app`

#### カスタムドメイン (Phase 5)

- Vercel Project Settings → Domains → `agoora.jp` 追加 (ドメイン取得後)
- agora.quard-web.jp も同様

---

### ★★★ 経路 C: Sakura レンタル (Phase 5 商用化時)

quard-web.jp と同じ sakura レンタルサーバ (idd53821 主運用) に配置:

```bash
# SFTP / rsync で配置
rsync -av index.html sakura-user@idd53821.sakura.ne.jp:~/www/agora/
# URL: https://agora.quard-web.jp/ (sub-domain)
```

→ Phase 5 商用化時、QUARD 既存ブランド傘下に統合。

---

## ✅ 動作確認 checklist

ブラウザで開いたら以下を確認:

- [ ] Hero「もし agoora だったら、この手戻りは防げた」表示
- [ ] dark/light toggle (右上ボタン) 動作 + localStorage 永続化
- [ ] レスポンシブ (mobile / tablet / desktop)
- [ ] 比較表 (Cursor / Continue / Devin / agoora) 表示
- [ ] CTA「Try agoora Demo」「View on GitHub」リンク
- [ ] Google Fonts (Inter + Noto Sans JP) 読込
- [ ] Tailwind CDN 動作
- [ ] a11y 4.5:1 contrast

## 🐛 既知の問題 (本 v0 時点)

| 問題 | 修正案 | 優先 |
|------|--------|------|
| デモ URL `agora.quard-web.jp` 未 deploy (Phase 5) | sakura に静的 deploy | ★★★ |
| GitHub OAuth CTA は Phase 5.1 まで未実装 | "Try Demo" のみ active | ★★ |
| Tailwind CDN は production で警告 | Phase 5 で `npm run build` 化 | ★★ |
| 比較表のデータは推定値 | 実測 benchmark で update | ★ |

## 🎨 デザイン variants (将来)

現在は **Bold 案** のみ。Captain 評価後:

- **Conservative**: hero 控えめ、professional tone
- **Standard**: 中間、技術者向け詳細
- **Bold (現在)**: 強い主張、emotional

Phase 5 で A/B テスト候補。

## 🔗 関連

- `4-portal/portal-config.yml` (agoora 製品情報)
- `1-knowledge/skill-baton-hashtag-thesis.md` (Landing コピーの thesis 出典)
- `1-knowledge/counterfactual-agoora-could-have-prevented.md` (20-25% 効率改善実証)
- [agora.quard-web.jp](https://agora.quard-web.jp) (Phase 5 デモ deploy 先)
- [agoora.jp](https://agoora.jp) (Phase 5 SaaS 本サイト、ドメイン取得予定)

## Captain 即時アクション (3 案)

| # | アクション | 工数 | 推奨 |
|---|-----------|------|------|
| **A** | https://github.com/riku1215/riku1215/settings/pages → Source: GitHub Actions | **1 min** | ★★★★★ |
| B | Vercel.com → New Project → 連携 | 5 min | ★★★★ |
| C | sakura rental SFTP 配置 | 30 min | ★★★ (Phase 5) |

→ **A 推奨**。1 分作業で `https://riku1215.github.io/riku1215/` で世界公開。
