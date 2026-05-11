# Sample Queries — KB 活用ユースケース集

Captain が頻繁に直面する「あれ、どこだっけ?」を **`search.ps1`** + **Claude Code on KB** で解決する具体例集。

## Pattern 1: 過去の議論を引っ張る

### 例: sakura 会員間移行の手順を確認したい

```powershell
# Step 1: タイトルで当たりをつける
.\search.ps1 -Query "sakura" -Type titles

# Step 2: 詳細を読む (上で見つかった Issue 番号で)
.\search.ps1 -Query "会員間" -Type issues

# Step 3: 全文で隠れた言及も
rg "gck63819|idd53821" $env:USERPROFILE\.kb\
```

### Claude Code で:
```
cd $env:USERPROFILE\.kb
claude

> sakura 会員間移行 (gck63819 → idd53821) について、過去の議論と決定事項を時系列でまとめて
```

## Pattern 2: R-rules / 運用ルール参照

### 例: 提案前に R9 Pre-action Checklist 違反していないか自己監査

```powershell
# R-rules を引き出す
.\search.ps1 -Query "R9" -Repo agora -Type issues
rg "R9.*checklist|Pre-action" $env:USERPROFILE\.kb\issues\agora.json
```

### Claude Code で:
```
> 直近私が出した提案について、agora の R1〜R10 ルール (issues/agora.json) と照合して
> 違反/グレーゾーンを抽出。Section 7 観察精度ルールも含めて。
```

## Pattern 3: 横断的な重複検出

### 例: pet-care-app と kuod-hp で同じパッケージのバージョン違いがないか

```powershell
# 各 package.json を見る
Get-Content $env:USERPROFILE\.kb\repos\pet-care-app\package.json
Get-Content $env:USERPROFILE\.kb\repos\kuod-hp\package.json

# 比較は jq / PowerShell
```

### Claude Code で:
```
> repos/pet-care-app と repos/kuod-hp の package.json を比較して、
> 同じ名前で異なるバージョンの依存関係を表にして
```

## Pattern 4: 進行中のタスク全体俯瞰

```powershell
# 全 repo の open Issue 一覧
Get-ChildItem $env:USERPROFILE\.kb\issues\*.json | ForEach-Object {
    $repoName = $_.BaseName
    (Get-Content $_.FullName -Raw | ConvertFrom-Json) |
        Where-Object { $_.state -eq "OPEN" } |
        ForEach-Object { "[$repoName#$($_.number)] $($_.title)" }
} | Sort-Object | Out-Host -Paging
```

### Claude Code で:
```
> 全 46 repo の open issues を読んで、優先度高い順に top 10 出して。
> 緊急度 (期限・blocker)、重要度 (収益/業務影響)、依存関係 を考慮して。
```

## Pattern 5: 過去の失敗パターン回避

### 例: 似たような deploy ミスを過去にしていないか

```powershell
.\search.ps1 -Query "deploy" -Type issues
.\search.ps1 -Query "failed|error" -Type issues | Select-Object -First 30
```

### Claude Code で:
```
> sakura VPS deploy 関連の過去 Issue (issues/pet-care-app.json) から
> 失敗パターンと対処を抽出。今回の deploy で同じ罠を避けるチェックリスト作って。
```

## Pattern 6: 月次レビュー

```powershell
# 過去30日に closed された Issue
$cutoff = (Get-Date).AddDays(-30).ToString("o")
Get-ChildItem $env:USERPROFILE\.kb\issues\*.json | ForEach-Object {
    $repoName = $_.BaseName
    (Get-Content $_.FullName -Raw | ConvertFrom-Json) |
        Where-Object { $_.state -eq "CLOSED" -and $_.closedAt -gt $cutoff } |
        ForEach-Object {
            "[$repoName#$($_.number)] $($_.title) (closed: $($_.closedAt.Substring(0,10)))"
        }
} | Sort-Object
```

### Claude Code で:
```
> 過去30日に closed された Issue (closedAt > 30日前) を全 repo から集めて、
> 何を達成したか月次レビュー形式でまとめて
```

## Pattern 7: 新しいプロジェクト発想時の事前調査

### 例: 「ChatGPT 連携 SaaS を作りたい」と思った時

```powershell
# 過去に類似議論があるか
rg "ChatGPT|OpenAI|GPT-4" $env:USERPROFILE\.kb\issues\
.\search.ps1 -Query "AI" -Type titles
```

### Claude Code で:
```
> 私が過去に ChatGPT/OpenAI/GPT 関連で議論した Issue (全 repo) を集めて、
> 既知の知見・既存実装・避けるべき失敗を統合的にまとめて
```

## Pattern 8: 商用化判断資料

```powershell
.\search.ps1 -Query "ClassWeaver" -Type issues
.\search.ps1 -Query "pet-care" -Type issues
```

### Claude Code で:
```
> ClassWeaver と pet-care-app の Issue 履歴から、
> 各プロダクトの完成度・残課題・商用化ブロッカーを表にまとめて
```

## Pattern 9: 自治体提案資料の根拠探し

```powershell
.\search.ps1 -Query "青森|住民監査|Dify" -Type issues
```

### Claude Code で:
```
> 青森自治体・住民監査請求・Dify 60社紹介 に関する過去の議論・取材記録・
> 提供資料を全 repo から集めて、提案書の根拠資料として時系列に整理
```

## Pattern 10: PR 出す前の最終確認

```powershell
# 該当ファイルが過去にどう変更されてきたか
cd $env:USERPROFILE\.kb\repos\pet-care-app
git log --all -p -- docs/deploy_sakura_vps.md | head -100
```

### Claude Code で:
```
> repos/pet-care-app/docs/deploy_sakura_vps.md の過去変更履歴を git log で確認し、
> 直近の私の編集 (working tree) が以前の判断と矛盾していないか自己レビュー
```

---

## エコ運用のコツ

- **rg は爆速、まず ripgrep**: API 呼び出しせず全文検索が 1秒未満
- **Claude にタスクを丸投げしない**: まず自分で 1〜2 回 ripgrep で当たりをつけて、絞り込んだ範囲を Claude にレビューさせる方がトークン節約
- **更新タイミングを意識**: 朝 09:00 自動更新後に重い分析、それまでは前日のデータで OK
