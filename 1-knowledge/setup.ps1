# Local KB Setup - Initial clone of all riku1215 repos + issues
# Usage: .\setup.ps1
# Prerequisites: gh CLI authenticated, git, ripgrep installed

$ErrorActionPreference = "Continue"

# === UTF-8 encoding fix (Japanese Windows / CP932 mojibake 対策) ===
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$kbRoot = "$env:USERPROFILE\.kb"
$reposDir = "$kbRoot\repos"
$issuesDir = "$kbRoot\issues"

# === Prerequisites check ===
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "gh CLI is not installed. Install from https://cli.github.com/"
    exit 1
}

$null = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "gh is not authenticated. Run 'gh auth login' first."
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git is not installed."
    exit 1
}

# === Setup directories ===
New-Item -ItemType Directory -Force -Path $reposDir, $issuesDir | Out-Null

# === Step 1: Fetch repo list ===
Write-Host "[1/3] Fetching repo list from riku1215..." -ForegroundColor Cyan
$reposJson = gh repo list riku1215 --json name,visibility,defaultBranchRef,updatedAt,description --limit 100
[System.IO.File]::WriteAllText("$kbRoot\repos.json", $reposJson, $utf8NoBom)

$repos = Get-Content "$kbRoot\repos.json" -Raw -Encoding UTF8 | ConvertFrom-Json
$repoCount = $repos.Count
Write-Host "Found $repoCount repos." -ForegroundColor Green

# === Step 2: Clone all repos ===
Write-Host "`n[2/3] Cloning $repoCount repos (depth=100)..." -ForegroundColor Cyan
$i = 0
$failed = @()
foreach ($repo in $repos) {
    $i++
    $name = $repo.name
    $target = "$reposDir\$name"

    if (Test-Path $target) {
        Write-Host "  [$i/$repoCount] $name (skip - already exists)" -ForegroundColor Gray
        continue
    }

    Write-Host "  [$i/$repoCount] cloning $name..." -ForegroundColor White
    gh repo clone "riku1215/$name" $target -- --depth=100 --quiet 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "    Failed to clone $name"
        $failed += $name
    }
}

if ($failed.Count -gt 0) {
    Write-Warning "Failed to clone: $($failed -join ', ')"
}

# === Step 3: Fetch issues for all repos ===
Write-Host "`n[3/3] Fetching issues for $repoCount repos..." -ForegroundColor Cyan
$i = 0
foreach ($repo in $repos) {
    $i++
    $name = $repo.name
    Write-Host "  [$i/$repoCount] $name issues..." -ForegroundColor White

    $issueJson = gh issue list -R "riku1215/$name" --state all --limit 9999 `
        --json number,title,body,labels,comments,state,createdAt,closedAt,updatedAt,author,assignees,url `
        2>$null

    if ($LASTEXITCODE -eq 0 -and $issueJson) {
        [System.IO.File]::WriteAllText("$issuesDir\$name.json", $issueJson, $utf8NoBom)
    } else {
        # Issues disabled or no access, save empty array
        [System.IO.File]::WriteAllText("$issuesDir\$name.json", "[]", $utf8NoBom)
    }
}

# === Summary ===
$totalIssues = 0
Get-ChildItem "$issuesDir\*.json" | ForEach-Object {
    $count = (Get-Content $_.FullName -Raw | ConvertFrom-Json).Count
    $totalIssues += $count
}

$kbSize = (Get-ChildItem $kbRoot -Recurse | Measure-Object Length -Sum).Sum / 1MB

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Knowledge base: $kbRoot" -ForegroundColor Cyan
Write-Host "  Repos cloned:   $($repoCount - $failed.Count) / $repoCount"
Write-Host "  Total issues:   $totalIssues"
Write-Host "  Size:           $([math]::Round($kbSize, 1)) MB"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Search:       rg `"keyword`" $kbRoot"
Write-Host "  2. Helper:       .\search.ps1 -Query `"keyword`""
Write-Host "  3. Claude Code:  cd $kbRoot; claude"
Write-Host "  4. Daily update: .\update.ps1 (recommend Task Scheduler at 09:00)"
Write-Host ""
