# Local Knowledge Base Setup

riku1215 配下の 46 リポジトリ + 1000+ Issue をローカル (`C:\Users\m\.kb\`) にミラーし、**見落とし・手戻りを防ぐ** 高速ナレッジ基盤を構築する。

## 目的

| 解決したい問題 | 対処 |
|---------------|------|
| 「あの sakura アドバイスどこだっけ?」が探せない | ripgrep で 1 秒以内に全 Issue から発見 |
| AI セッション (Claude等) が一部しか見えず手戻り発生 | Claude Code を `.kb/` 配下で起動して全 context を context 化 |
| GitHub API レート制限で検索が遅い | ローカル grep は API 制限ゼロ |
| 過去の意思決定 (R-rules等) を AI が参照せず矛盾発生 | 全 R-rule / 全 Issue がローカルに常駐 |
| GitHub 障害時に業務停止 | ローカルクローンで業務継続可能 |

## 前提

- **Windows 11 + PowerShell 7+**
- **gh CLI** authenticated: `gh auth status` で OK と表示されること
- **git** installed (`git --version` で確認)
- **ripgrep** (`rg`): `winget install BurntSushi.ripgrep.MSVC`
- 約 **20 GB** 空き容量 (C ドライブ推奨)

## クイックスタート

### 1. 初回構築 (1〜2 時間)

```powershell
cd $env:USERPROFILE\riku1215\1-knowledge
.\setup.ps1
```

完了後の構造:

```
C:\Users\m\.kb\
├── repos\           ← 46 repo を git clone
│   ├── agora\
│   ├── pet-care-app\
│   ├── riku1215\
│   └── ... (43 more)
├── issues\          ← 各 repo の Issue を JSON 化
│   ├── agora.json
│   ├── pet-care-app.json
│   └── ...
└── repos.json       ← 全 repo メタ情報
```

### 2. 日次更新 (5〜10 分)

```powershell
.\update.ps1
```

タスクスケジューラ登録 (毎朝 09:00 自動):

```powershell
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$env:USERPROFILE\1-knowledge\update.ps1`""
$trigger = New-ScheduledTaskTrigger -Daily -At 09:00
Register-ScheduledTask -TaskName "KB Daily Update" -Action $action -Trigger $trigger -RunLevel Highest
```

### 3. 検索

#### ripgrep (全文・最速)

```powershell
# 全文検索
rg "sakura 会員間" $env:USERPROFILE\.kb\

# Issue だけ検索
rg "quard-web" $env:USERPROFILE\.kb\issues\

# 特定 repo のみ
rg "deploy" $env:USERPROFILE\.kb\repos\pet-care-app\
```

#### helper スクリプト

```powershell
# .\search.ps1 -Query "sakura" [-Type all|files|issues|titles]
.\search.ps1 -Query "sakura"
.\search.ps1 -Query "quard-web" -Type titles
```

#### Issue タイトルだけ (PowerShell)

```powershell
Get-ChildItem $env:USERPROFILE\.kb\issues\*.json | ForEach-Object {
    $repo = $_.BaseName
    (Get-Content $_.FullName -Raw | ConvertFrom-Json) |
        Where-Object { $_.title -match "sakura" } |
        ForEach-Object { "[$repo#$($_.number)] $($_.title)" }
}
```

### 4. Claude Code 連携

```powershell
cd $env:USERPROFILE\.kb
claude
```

→ Claude Code は **`.kb/` 配下全体** を context として起動。

詳細は `claude-integration.md` を参照。

## 同期方針

- **ローカル → GitHub**: 各 repo 内で `git push`、Issue 変更は `gh issue create/comment`
- **GitHub → ローカル**: `update.ps1` で `git pull` + Issue JSON 再取得
- **競合**: 単独開発者なので稀。`git pull --rebase` で十分

## セキュリティ

- 機密情報を含むため **外部共有禁止**
- C ドライブ (Windows ユーザディレクトリ) 内のみで完結
- GitHub Actions secrets はローカルに来ない
- private repo クローンには `gh auth login` で SSH/PAT 認証済前提

## トラブルシューティング

| 症状 | 対処 |
|------|------|
| `gh: command not found` | https://cli.github.com/ から導入、`gh auth login` |
| `rg: command not found` | `winget install BurntSushi.ripgrep.MSVC` |
| クローンが遅い | `--depth=100` を `--depth=30` に変更 (setup.ps1 編集) |
| 容量不足 | `--depth=10` に削減、または不要 repo は手動削除 |
| `gh issue list` が一部 repo で失敗 | Issues 機能 disable な repo の可能性、`[]` で扱われるので無視 |

## 次のステップ

### Phase D: ベクトル検索 (実装済)
`2-intelligence/vector-search/` 参照。

### Phase D-2: Streamlit フィードバック UI (実装済)
`3-interface/kb_feedback_ui.py` 参照。`streamlit run kb_feedback_ui.py` で起動。

### Phase E: バックアップ (実装済)
`./backup.ps1` または `./backup.sh` で月次 git-bundle。

### Phase F: NAS 拡張 (実装済) ★

setup.ps1 は Issue のみカバー。**PR / Releases / Workflow runs / Discussions / Repo メタ** を追加:

```powershell
# 基本拡張 (PR + Releases + Repo meta、+10-30 分)
.\expand.ps1

# Workflow runs も (失敗 CI ログの履歴検索用)
.\expand.ps1 -WithRuns

# Discussions も (該当 repo がある場合)
.\expand.ps1 -WithDiscussions
```

**Captain の見落とし防止に直結**:
- "過去のこの PR で同じ修正したっけ?" → `rg "keyword" ~/.kb/prs/`
- "ClassWeaver の v0.5 release notes" → `~/.kb/releases/class-weaver.json`
- "pet-care-app CI が直近どう失敗してきたか" → `~/.kb/workflow-runs/pet-care-app.json`

### Phase F+: 外部ドキュメント Mirror (実装済)

```bash
./docs-mirror.sh           # 基本: Anthropic/Vercel/MCP/Ollama/Chroma/LlamaIndex
./docs-mirror.sh --full    # 追加: Astro/Next.js/Docker/Vercel/GitHub docs
```

`~/.kb/external-docs/` にミラーされ、ripgrep で横断検索可能。

### Phase G: ローカル LLM (将来)
ハードウェア (RTX 4070+ / Mac Studio 等) 追加時に判断。`案A''`参照。
