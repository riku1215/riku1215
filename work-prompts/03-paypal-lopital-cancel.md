# 03: PayPal LOPITAL LIMITED / PDFLEADER 自動支払い解約

## ゴール
**月¥8,999** の継続課金 (詐欺サブスクの可能性大) を停止する。年換算で **約 ¥108,000** の削減。

## 背景 (Gmail 分析結果)
- マーチャント名: `Lopital Limited` / `PDFLEADER` / `LOPITAL LIMITED` (表記揺れ、同一業者)
- 連絡先: `help@leaderdocs.limited` / +1 855-973-9124
- 課金履歴: 03/07 ¥150×2 (試用) → 03/14 ¥8,999 → 04/11 ¥8,999 → 05/09 ¥8,999 = **計 ¥27,297 既に発生**
- 直近取引ID: `0A687846DT358503H` (2026/05/09)
- 前回取引ID: `0GL12431VF624334U` (2026/04/11)

## Step 1: PayPal で自動支払いを停止 (最優先・本丸)

1. https://www.paypal.com/jp/ にログイン
2. 右上 ⚙️ 設定 → **「支払い」**タブ → **「自動支払い」**
   - 直リンク: https://www.paypal.com/myaccount/autopay/
3. 一覧から以下を探す (両方ある可能性):
   - **`Lopital Limited`**
   - **`PDFLEADER`**
   - **`LEADER DOCS`**
4. クリック → **「キャンセル」** → 確認
5. 両方ヒットすれば **両方キャンセル**

## Step 2: Subscription 確認 (念のため)
PayPal → アクティビティ → 上記取引ID (`0A687846DT358503H`) の詳細を開く → 「定期支払い」表示があれば「キャンセル」

## Step 3 (任意): 業者へ解約通知メール
規約で業者側へ通知義務がある場合に備えて、`help@leaderdocs.limited` 宛に送信:

```
件名: Cancellation of subscription

Hello,

I am writing to formally cancel my subscription with your service.
Please discontinue all recurring charges to my PayPal account immediately.

Transaction ID (most recent): 0A687846DT358503H
Account email: takaj2011311@gmail.com

Thank you,
Jun Takaki
```

## Step 4 (任意・推奨): カード会社にも念押し
- PayPayカード ゴールド (JCB) アプリで「Lopital」「PDFLEADER」「LEADER DOCS」キーワード検索
- 該当があればカード会社経由でも「定期決済停止」を依頼 (二重の安全網)

## 成功判定
- 来月 (2026/06/09 頃) に PayPal 課金通知が来ない
- カード明細にも該当決済なし

## 完了後の次ステップ
→ `04-gcp-dual-closure.md` (月¥10k のGCP二重課金もまだ生きている)
