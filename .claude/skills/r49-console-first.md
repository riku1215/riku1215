---
name: r49-console-first
description: silent bug 調査 = console error / network error 確認 を 最初 に 必須化。 仮説推測前 に DevTools / read_console_messages / read_network_requests
type: r-rule
version: 1.0.0
source: agora#4 R49 (R73 Phase 2.1 Skill 化、 2026-05-07 制定)
related-rules: [R34, R37, R50, R52]
---

# R49: silent bug 調査 = console first 必須

## When to use

- **production click → 何も起きない** 系 silent bug
- **HTMX hx-on:* / inline handler が 動かない**
- **HTMX swap が 失敗 する**
- **「ボタン 押した のに 反応 ない」 user 報告**

## What to do (1st step)

### 必ず 最初 に 実行

```
1. DevTools console を 開く (F12)
2. read_console_messages (= 最近 100 件) → error / warning 抽出
3. read_network_requests → 4xx/5xx response 確認
4. Captain に 「console error N 件 検出 / network error N 件」 即 paste
```

### NG flow (= 過去 11 turn 浪費 事例)

```
silent bug 報告
↓
仮説 ①: コード ミス? → コード review → 0 件
↓
仮説 ②: route 違い? → route 確認 → 0 件
↓
仮説 ③: cache 問題? → ハードリロード → 改善なし
↓
... (= 11 turn 後 やっと console 確認 = 一発 検出)
```

### OK flow (= R49 適用、 30 min 解消)

```
silent bug 報告
↓
1st step: console + network 確認 (= 1 sec)
↓
24 件 CSP eval error 検出 → 真因 確定
↓
CSP 'unsafe-eval' 追加 commit + push + verify
↓
完了 (~30 min)
```

## NG (やってはいけない)

- ❌ 「コード review」 を 1st step (= console 確認 skip)
- ❌ 仮説 推測 進行 (= 「たぶん cache」 「たぶん route」)
- ❌ ハードリロード / 環境 reset 連発
- ❌ 11 turn 浪費 (= 過去 事例)

## OK (推奨)

- ✅ silent bug 報告 直後 = console + network 確認 1 sec
- ✅ error 0 件 = 「次 = JS 実行 trace / network response 詳細 / DOM diff」
- ✅ error 検出 = 真因 即特定 + commit + push
- ✅ 結果 を Captain に 即 paste (R66/R67)

## Example (= 本日 立証)

ClassWeaver issue #196:
- Captain: 「production click → 何 も 起きない」
- 11 turn 浪費 後 = console 確認 = 24 件 CSP eval error 検出
- 真因 = CSP `'unsafe-eval'` 欠落 = HTMX hx-on 動作 不能
- fix = CSP 追加 (commit `240ddce`) → 30 min で 完全解消
- = R49 制定 source

## R-rule chain

- R34 (実操作 verify): R49 適用 後 R34 で 動作 verify
- R37 (>40% bug = Agent dispatch): R49 で 真因 不明 case で 連動
- R50 (Gemini pre-check): R49 結果 を Gemini で 二重 verify
- R52 (e2e silent bug guard): R49 自動化 = e2e で console error 0 監視

## 立証

- ClassWeaver issue #196 (= R49 制定 source)
- 28+ repo 全 web app 系 silent bug 標準対応 path
