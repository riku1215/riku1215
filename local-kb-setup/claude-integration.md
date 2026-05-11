# Claude Code 連携手順

## 基本: KB ディレクトリで起動

```powershell
cd $env:USERPROFILE\.kb
claude
```

これだけで Claude Code は `.kb/` 配下全体 (`repos/<46個>` + `issues/<46個>.json`) を context として認識します。

## 推奨: `.kb/CLAUDE.md` を配置

`.kb/` 直下に **CLAUDE.md** を置くと、Claude Code が起動時に自動読込し、ナレッジ運用ルールを内包します。

下記テンプレートを `C:\Users\m\.kb\CLAUDE.md` に保存:

```markdown
# Local Knowledge Base — riku1215/*

このディレクトリは riku1215 配下 46 リポジトリ + 1000+ Issue のローカルミラーです。

## 構造
- `repos/<name>/` - 46 repo の git working tree (depth=100)
- `issues/<name>.json` - 各 repo の Issue を JSON 化 (state=all)
- `repos.json` - 全 repo メタデータ
- `update.log` - 同期履歴

## 検索優先順位 (Claude へ)

1. **タイトル/ラベル一致** が必要なら issues/*.json を jq / ConvertFrom-Json で構造化検索
2. **全文一致** は repos/ と issues/ 両方を ripgrep:
   ```powershell
   rg "keyword" $env:USERPROFILE\.kb\
   ```
3. **意味的に近い**ものを探したい場合は将来導入予定のベクトル検索

## 運用ルール (Captain 仕様)

- R1〜R10 は agora#4 が global instruction (`issues/agora.json` に保管)
- 提案前は agora の R-rules を必ず再確認 (見落としによる手戻り防止が本KBの目的)
- 機密情報を含むため外部共有禁止
- 更新は `update.ps1` を毎朝 09:00 自動実行 (Task Scheduler)

## ありがちなプロンプト例

- 「sakura 会員間移行 に関する過去議論を時系列で要約」
- 「agora#4 の R-rules を読み込んで、今の作業計画を自己監査」
- 「pet-care-app と kuod-hp で重複する依存パッケージを洗い出して」
- 「ClassWeaver の Issue 流れから次に着手すべき最優先タスクを推奨」
- 「PROFILE.md Section 7 のルールを違反していないか直近 5 メッセージを監査」

## このセッションでは
- ローカル KB を最大限活用し、API 呼び出しを最小化
- 不明点は GitHub 直接ではなく `issues/*.json` 参照を先行
- 更新が古い (24h 超) と感じたら `update.ps1` 実行を Captain に推奨
```

## タスクスケジューラ登録 (毎朝 09:00 自動更新)

PowerShell を **管理者権限** で開いて:

```powershell
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$env:USERPROFILE\local-kb-setup\update.ps1`""
$trigger = New-ScheduledTaskTrigger -Daily -At 09:00
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RunOnlyIfNetworkAvailable
Register-ScheduledTask -TaskName "KB Daily Update" `
    -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest
```

実行確認:
```powershell
Get-ScheduledTask -TaskName "KB Daily Update" | Get-ScheduledTaskInfo
```

## トラブルシューティング

### Claude Code が `.kb/` を「大きすぎる」と警告

`.kb/` は数 GB なので、Claude Code がインデックス化に時間かかる場合あり。対策:

```powershell
# CLAUDE.md にコンテキスト制限を明記
echo "## Context Hint" >> $env:USERPROFILE\.kb\CLAUDE.md
echo "- repos/<name>/node_modules/ は ignore" >> $env:USERPROFILE\.kb\CLAUDE.md
echo "- repos/<name>/.next/ は ignore" >> $env:USERPROFILE\.kb\CLAUDE.md
echo "- repos/<name>/dist/ は ignore" >> $env:USERPROFILE\.kb\CLAUDE.md
```

または `.kb/` 直下に `.gitignore` 風のファイル (Claude Code 仕様確認要):

```
# .kb/.claudeignore (もしサポートされていれば)
**/node_modules/
**/.next/
**/dist/
**/build/
**/.git/objects/
```

### 同期が遅い

`update.ps1` 内の `--depth=100` を `--depth=30` に変更すると速くなる (履歴削減)。

### 一部 Issue が古い

`update.ps1` を手動再実行、または以下で個別 repo の Issue だけ更新:

```powershell
gh issue list -R "riku1215/agora" --state all --limit 9999 `
    --json number,title,body,labels,comments,state,createdAt,closedAt,updatedAt,author,assignees,url `
    > $env:USERPROFILE\.kb\issues\agora.json
```

## Phase D (任意): ベクトル検索追加

ripgrep の全文一致だけでは「意味的に近い」を取りこぼします。例:

- ripgrep: 「会員アカウント乗せ替え」 → hit ゼロ
- ベクトル: 「会員アカウント乗せ替え」 → "sakura 会員間移行" が hit

実装は別 PR で `local-kb-setup/vector-search/` 配下に追加予定。スタック:

- ChromaDB or Qdrant (Grok推奨は Qdrant、Rust高速)
- nomic-embed-text (Ollama 経由、約 270 MB)
- LlamaIndex で RAG パイプライン

導入後の起動:
```powershell
python $env:USERPROFILE\local-kb-setup\vector-search\index.py    # 1回だけ embedding
python $env:USERPROFILE\local-kb-setup\vector-search\ask.py "会員アカウント乗せ替え"
```
