# Sample Queries — 高度ユースケース集

Phase A 完了後、基礎的な使い方は `sample-queries.md` を参照。
本ドキュメントは**経営判断・事業継続・自治体提案**等に直結する高度パターンを記載。

## Pattern 11: 月次経営レビュー (R10 一括承認用)

### 例: 今月の MRR 影響タスクと支出を要約

```powershell
# 全 repo の閉鎖 issue を今月分だけ
$cutoff = (Get-Date).AddDays(-30).ToString("o")
$closed = Get-ChildItem $env:USERPROFILE\.kb\issues\*.json | ForEach-Object {
    $repo = $_.BaseName
    (Get-Content $_.FullName -Raw | ConvertFrom-Json) |
        Where-Object { $_.state -eq "CLOSED" -and $_.closedAt -gt $cutoff } |
        Select-Object @{N='repo';E={$repo}}, number, title, closedAt
}
$closed | Format-Table -AutoSize
```

### Claude Code で:
```
> 過去30日に closed された Issue (全 repo) を経営インパクト軸で分類:
> A) 収益創出/維持、B) コスト削減、C) 技術負債解消、D) 学習・調査
> 各カテゴリ Top 3 と、これらに費やした推定工数 (1 issue=平均1.5h前提)
```

## Pattern 12: 競合プロダクト比較

### 例: ClassWeaver と類似 SaaS の差別化ポイント

```powershell
.\search.ps1 -Query "ClassWeaver|時間割|スケジュール" -Type issues
.\search.ps1 -Query "competitor|競合" -Type all
```

### Claude Code で:
```
> ClassWeaver の Issue 履歴と、過去議論で出た競合 (E-Time等) との
> 機能比較表を作成。Captain の差別化戦略の根拠を抽出
```

## Pattern 13: 自治体 / 行政提案資料の根拠探し

```powershell
.\search.ps1 -Query "青森|住民監査|Dify|自治体" -Type issues
rg "ABA朝日放送|木村淳司|唐牛|藤本" $env:USERPROFILE\.kb\
```

### Claude Code で:
```
> 青森市政・自治体提案に関する過去の議論・取材記録・Dify 60社紹介の文脈を
> 全 repo から集めて、新規提案書のExecutive Summary に使えるよう
> 1500字以内で時系列要約
```

## Pattern 14: セキュリティ監査 (R55 など)

```powershell
# 過去のセキュリティ関連 Issue
.\search.ps1 -Query "security|vulnerab|脆弱|漏洩|leak" -Type all

# .env, secrets, credentials の漏洩疑惑
rg -i "(api[_-]?key|secret|password|credential)\s*[=:]" $env:USERPROFILE\.kb\repos\ | head -50
```

### Claude Code で:
```
> 全 repo を sweep して以下を抽出:
> 1) ハードコードされた可能性のある API key / secret
> 2) .env.example が無いのに参照される env var
> 3) 過去にセキュリティ警告された Issue とその対応状況
> 結果を CSV で出力 (repo, file, line, type, severity)
```

## Pattern 15: 商用化判断 (Tier S 候補抽出)

```powershell
$tierS = @("pet-care-app", "ClassWeaver", "mindgate-tgl", "ai-financial-office")
foreach ($repo in $tierS) {
    $issuePath = "$env:USERPROFILE\.kb\issues\$repo.json"
    if (Test-Path $issuePath) {
        $issues = Get-Content $issuePath -Raw | ConvertFrom-Json
        $open = ($issues | Where-Object { $_.state -eq "OPEN" }).Count
        $closed = ($issues | Where-Object { $_.state -eq "CLOSED" }).Count
        Write-Host "$repo : OPEN=$open / CLOSED=$closed"
    }
}
```

### Claude Code で:
```
> Tier S 候補 4 つ (pet-care-app, ClassWeaver, mindgate-tgl, ai-financial-office) の
> 完成度・残課題・商用化ブロッカー・推定残工数を表にまとめて。
> 次に着手すべき1つを推奨度付きで提案
```

## Pattern 16: 過去の判断ミス再発防止 (Section 7 適用)

```powershell
# 自分が「失敗した」「やり直した」と言及した Issue を抽出
.\search.ps1 -Query "失敗|やり直し|手戻り|再考|誤判断|reverted" -Type all
```

### Claude Code で:
```
> 過去の Issue から「私が間違えた / 手戻り発生した / リバートした」事例を5つ抽出。
> Section 7 の各ルール (観察精度、文脈利用、推察優先...) のどれに違反したかを照合。
> 今後の作業でアラートすべきパターンを3つ提案
```

## Pattern 17: API コスト見直し (Gmail × Issue 統合)

```powershell
# サービス名で全 repo を sweep
$services = @("Anthropic", "OpenAI", "Gemini", "Google Cloud", "AWS",
              "Stripe", "GitHub Copilot", "Lopital", "PDFLEADER", "Dify")
foreach ($s in $services) {
    Write-Host "=== $s ===" -ForegroundColor Cyan
    .\search.ps1 -Query $s -Type titles | Select-Object -First 5
}
```

### Claude Code で:
```
> Gmail 分析で判明した月額サービス一覧と、KB 内の Issue/コードで
> 実際に使われている形跡を crosscheck。
> 「払ってるけど使ってない」「使ってるけど Issue 化されていない」を抽出
```

## Pattern 18: 新プロジェクト立ち上げ前の事前調査

### 例: 「QR決済 SaaS を作りたい」と思った時

```powershell
.\search.ps1 -Query "決済|payment|Stripe|PayPay|PayPal" -Type issues
.\search.ps1 -Query "QR|barcode" -Type all
```

### Claude Code で:
```
> 私が過去に決済・QRコード関連で議論した Issue を全 repo から集約。
> 既知の知見・既存実装・避けるべき失敗・必要な法規制 (資金決済法、PCI DSS等) を統合
```

## Pattern 19: 自分への取扱説明書 (Section 7 自己監査)

```powershell
# PROFILE.md Section 7 を表示
Get-Content $env:USERPROFILE\.kb\repos\riku1215\PROFILE.md | Select-String -Pattern "^### 7-" -Context 0,5
```

### Claude Code で:
```
> 直近 24h の私の発言を読み返して、Section 7 各ルールに照らした自己採点表を作成。
> 7-1 観察精度 / 7-2 文脈利用 / ... / 7-9 ツール並列 まで、
> 各 ★ 1〜5 で、改善提案 1 つずつ
```

## Pattern 20: 業務継続性テスト (BCP)

```powershell
# GitHub 障害想定: ローカル KB だけで業務継続可能か検証
$kbSize = (Get-ChildItem $env:USERPROFILE\.kb -Recurse | Measure-Object Length -Sum).Sum / 1MB
Write-Host "KB size: $([math]::Round($kbSize, 1)) MB"
Write-Host "Last update: $((Get-Item $env:USERPROFILE\.kb\repos.json).LastWriteTime)"
$staleDays = ((Get-Date) - (Get-Item $env:USERPROFILE\.kb\repos.json).LastWriteTime).Days
if ($staleDays -gt 1) {
    Write-Host "⚠️  KB is $staleDays days stale, run update.ps1" -ForegroundColor Yellow
}
```

### Claude Code で:
```
> 仮に GitHub が今 24h ダウンしたら、私が業務継続できる範囲を評価:
> 1) 緊急対応可能なタスク
> 2) 部分対応可能 (一部不明)
> 3) 完全停止 (要 GitHub)
> 各カテゴリの代替策と KB だけで何を準備しておくべきか
```

---

## エコ運用のコツ (続き)

- **トークン節約**: 「全 repo から」と頼まずに「該当しそうな 3 repo に絞って」と指定
- **段階的深掘り**: 最初 title 検索 → 関連 issue 番号判明 → その issue だけ詳細解析
- **キャッシュ活用**: 同じ質問は KB 更新 (毎朝) 前なら再実行不要
- **多LLMレビュー (R14)**: 重要判断は Claude + Gemini + Grok に同じ Issue context を渡して比較
