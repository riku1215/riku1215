# portal-init.ps1 - Captain Portal 階層構造構築
#
# Usage:
#   .\portal-init.ps1                       # default: %USERPROFILE%\Portal
#   .\portal-init.ps1 -PortalRoot D:\Portal # custom
#   .\portal-init.ps1 -DryRun               # ディレクトリ作成せず確認のみ

param(
    [string]$PortalRoot = "$env:USERPROFILE\Portal",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# === UTF-8 encoding (Japanese Windows) ===
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

# === 階層構造 ===
$layers = @(
    @{id="1-domains"; type="domain"},
    @{id="2-skills"; type="symlink"; target="$env:USERPROFILE\.agents\skills"},
    @{id="3-rules"; type="rules"},
    @{id="4-find-skills"; type="tool"},
    @{id="5-knowledge-base"; type="symlink"; target="$env:USERPROFILE\.kb"},
    @{id="6-meta"; type="symlink"; target="$env:USERPROFILE\riku1215"},
    @{id="99-portal-ui"; type="web"; status="planned"}
)

$domains = @{
    "ai-development" = @("frameworks", "models", "skills", "projects", "research")
    "web-development" = @("frameworks", "deployment", "styling", "projects")
    "data-engineering" = @("databases", "vector", "pipelines", "analytics")
    "devops" = @("ci-cd", "monitoring", "infrastructure", "security")
    "business" = @("strategy", "proposals", "audit", "billing")
}

function Write-Action {
    param([string]$Action, [string]$Path)
    $marker = if ($DryRun) { "[DRY]" } else { "[DO ]" }
    Write-Host "$marker $Action`: $Path" -ForegroundColor Cyan
}

function Make-Directory {
    param([string]$Path)
    Write-Action "mkdir" $Path
    if (-not $DryRun) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Make-Symlink {
    param([string]$LinkPath, [string]$TargetPath)
    if (-not (Test-Path $TargetPath)) {
        Write-Warning "  Target not found: $TargetPath (skipping symlink)"
        return
    }
    Write-Action "symlink" "$LinkPath -> $TargetPath"
    if (-not $DryRun) {
        if (Test-Path $LinkPath) {
            Remove-Item $LinkPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
    }
}

function Write-File {
    param([string]$Path, [string]$Content)
    Write-Action "write " $Path
    if (-not $DryRun) {
        [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
    }
}

# === Step 1: Portal Root ===
Write-Host "===== Captain Portal Initialization =====" -ForegroundColor Green
Write-Host "Portal Root: $PortalRoot" -ForegroundColor Yellow
Write-Host "Mode:        $(if ($DryRun) { 'DRY RUN' } else { 'EXECUTE' })" -ForegroundColor Yellow
Write-Host ""

Make-Directory $PortalRoot

# === Step 2: Root INDEX.md + CLAUDE.md ===
$dateStr = Get-Date -Format 'yyyy-MM-dd'
$rootIndex = @"
---
tags: [portal, captain-portal, navigation, root]
layer: portal-root
audience: [captain-only, claude]
status: active
---

# Captain Portal — Root

``#captain-portal #navigation #portal-root``

C ドライブ全体を巨大なナレッジリポジトリとして運用。
Claude (私) が瞬時に必要情報へ到達できる階層構造。

## 構造

| 層 | パス | 内容 |
|----|------|------|
| 1-domains | 1-domains\ | 分野別 (ai-development / web-development / data-engineering / devops / business) |
| 2-skills | 2-skills\ → ~/.agents/skills/ | 47 Skills |
| 3-rules | 3-rules\ | R1-R10 + R14 + R71 + Section 7 |
| 5-knowledge-base | 5-knowledge-base\ → ~/.kb/ | 46 repo + 1000+ Issue |
| 6-meta | 6-meta\ → ~/riku1215/ | Captain Portal リポ |

最終更新: $dateStr
"@
Write-File "$PortalRoot\INDEX.md" $rootIndex

$rootClaude = @"
# CLAUDE.md — Captain Portal Root

@6-meta/PROFILE.md

## Captain Portal 運用ガイド

Claude (あなた) は本ディレクトリ ($PortalRoot) 配下を Captain のナレッジハブとして利用。
階層化されているので、質問内容に応じて適切な層を即参照すること。

## 起動時必須

1. **INDEX.md (本ディレクトリ)** で全体構造把握
2. **6-meta/PROFILE.md** で Captain プロファイル + Section 7 + Section 8
3. **3-rules/** の R-rules 一覧
4. 質問内容に応じて 1-domains/*/INDEX.md へ

最終更新: $dateStr
"@
Write-File "$PortalRoot\CLAUDE.md" $rootClaude

# === Step 3: 1-domains/ ディレクトリ + INDEX 各層 ===
foreach ($domain in $domains.Keys) {
    $domainPath = "$PortalRoot\1-domains\$domain"
    Make-Directory $domainPath

    $indexContent = @"
---
tags: [domain, $domain, navigation]
layer: domain
---

# $domain

## サブ分野

"@
    foreach ($sub in $domains[$domain]) {
        $subPath = "$domainPath\$sub"
        Make-Directory $subPath
        $indexContent += "- [$sub]($sub/INDEX.md) — TODO`n"

        $subIndex = @"
---
tags: [$domain, $sub, placeholder]
layer: sub-domain
status: draft
---

# $domain / $sub

TODO: 内容追加。

## 関連

- 5-knowledge-base/repos/ で関連 repo 検索
- 5-knowledge-base/issues/ で関連議論検索
- 3-rules/ で R-rules 該当
"@
        Write-File "$subPath\INDEX.md" $subIndex
    }
    Write-File "$domainPath\INDEX.md" $indexContent
}

# === Step 4: Symlinks ===
foreach ($layer in $layers) {
    if ($layer.type -eq "symlink") {
        Make-Symlink "$PortalRoot\$($layer.id)" $layer.target
    }
}

# === Step 5: 3-rules/ ===
Make-Directory "$PortalRoot\3-rules"
Write-File "$PortalRoot\3-rules\INDEX.md" "# 3-rules — R-rules + Section 7`n`n詳細は **6-meta/PROFILE.md Section 5-9** を参照."

# === Step 6: 4-find-skills/ ===
Make-Directory "$PortalRoot\4-find-skills"
Write-File "$PortalRoot\4-find-skills\README.md" "# 4-find-skills`n`nVercel find-skills は ~/.agents/skills/find-skills/ にインストール済 (2-skills 経由参照可)`n`n``npx skills find <query>``で発見、``npx skills add <owner/repo>``で install."

# === Step 7: 99-portal-ui (静的 HTML ポータル UI 配置) ===
Make-Directory "$PortalRoot\99-portal-ui"
$uiSrc = Join-Path $PSScriptRoot "ui-template"
if (Test-Path $uiSrc) {
    foreach ($file in @("index.html", "style.css", "search.js")) {
        $srcFile = Join-Path $uiSrc $file
        $dstFile = Join-Path "$PortalRoot\99-portal-ui" $file
        if (Test-Path $srcFile) {
            Write-Action "copy  " $dstFile
            if (-not $DryRun) {
                Copy-Item -Path $srcFile -Destination $dstFile -Force
            }
        }
    }
}

# === Step 8: indexes (build-indexes.ps1 実行) ===
$buildScript = Join-Path $PSScriptRoot "build-indexes.ps1"
if (Test-Path $buildScript) {
    Write-Action "build " "indexes (build-indexes.ps1)"
    if (-not $DryRun) {
        & $buildScript -PortalRoot $PortalRoot
    }
}

# === Step 9: start.bat / start.sh (ワンクリック起動) ===
$startBat = @"
@echo off
REM Captain Portal Quick Start
REM static UI のみ: file:/// で開く (FastAPI 不要)
REM 意味検索も使う: python portal-api.py を起動
cd /d "%~dp0"
echo Portal: %CD%\99-portal-ui\index.html
echo.
echo [1] 静的 UI のみ (即起動、意味検索なし)
echo [2] API サーバ起動 (意味検索あり、Python + chromadb 要)
set /p choice="Choice [1/2]: "
if "%choice%"=="2" (
    python "%~dp0..\6-meta\4-portal\portal-api.py" --port 8765
) else (
    start "" "%CD%\99-portal-ui\index.html"
)
"@
Write-File "$PortalRoot\start.bat" $startBat

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Portal initialization complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Root: $PortalRoot"
Write-Host "  Mode: $(if ($DryRun) { 'DRY RUN (no changes)' } else { 'EXECUTED' })"
Write-Host ""
Write-Host "Next:" -ForegroundColor Yellow
Write-Host "  方法 1 (静的 UI、即動作):"
Write-Host "    Start-Process `"$PortalRoot\99-portal-ui\index.html`""
Write-Host ""
Write-Host "  方法 2 (FastAPI + 意味検索、推奨):"
Write-Host "    cd $PSScriptRoot"
Write-Host "    pip install fastapi uvicorn[standard] chromadb pyyaml"
Write-Host "    python portal-api.py"
Write-Host "    # → http://127.0.0.1:8765/"
Write-Host ""
Write-Host "  方法 3 (Claude Code 起動):"
Write-Host "    cd $PortalRoot"
Write-Host "    claude  # CLAUDE.md auto-load"
Write-Host ""
Write-Host "  インデックス更新:"
Write-Host "    .\4-portal\build-indexes.ps1"
