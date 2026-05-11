# Phase E: Daily Backup - Windows PowerShell
# Usage:
#   .\backup.ps1                      # default: keep last 30 daily backups
#   .\backup.ps1 -Output D:\kb-backup # custom location
#   .\backup.ps1 -Keep 7              # keep only last 7 days
#
# Recommended: Task Scheduler daily at 02:00

param(
    [string]$Output = "$env:USERPROFILE\.kb\backups",
    [int]$Keep = 30
)

$ErrorActionPreference = "Continue"
$kbRoot = "$env:USERPROFILE\.kb"
$reposDir = "$kbRoot\repos"

if (-not (Test-Path $reposDir)) {
    Write-Error "KB not initialized. Run setup.ps1 first."
    exit 1
}

$timestamp = Get-Date -Format "yyyy-MM-dd"
$backupDir = "$Output\$timestamp"

# Idempotent: skip if today's backup already exists
if (Test-Path $backupDir) {
    Write-Host "Today's backup already exists at $backupDir" -ForegroundColor Yellow
    exit 0
}

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "Creating daily bundles in: $backupDir" -ForegroundColor Cyan

$repos = Get-ChildItem -Path $reposDir -Directory
$total = $repos.Count
$i = 0
$failed = @()

foreach ($repo in $repos) {
    $i++
    $name = $repo.Name
    $bundleFile = "$backupDir\$name.bundle"

    Write-Host "  [$i/$total] $name" -ForegroundColor White
    Push-Location $repo.FullName
    try {
        git bundle create $bundleFile --all 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "  Failed: $name"
            $failed += $name
        }
    } catch {
        Write-Warning "  Error: $name : $_"
        $failed += $name
    } finally {
        Pop-Location
    }
}

# Issue JSONs
$issuesDir = "$kbRoot\issues"
if (Test-Path $issuesDir) {
    $issuesArchive = "$backupDir\issues-$timestamp.zip"
    Compress-Archive -Path "$issuesDir\*" -DestinationPath $issuesArchive -Force
    Write-Host "Issues archived: $issuesArchive" -ForegroundColor Green
}

# Feedback DB (Phase D-2) if exists
$feedbackDb = "$kbRoot\feedback.sqlite3"
if (Test-Path $feedbackDb) {
    Copy-Item $feedbackDb "$backupDir\feedback.sqlite3"
    Write-Host "Feedback DB backed up" -ForegroundColor Green
}

# Retention: delete backups older than $Keep days
$cutoff = (Get-Date).AddDays(-$Keep)
$oldBackups = Get-ChildItem -Path $Output -Directory -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match '^\d{4}-\d{2}-\d{2}$' -and $_.LastWriteTime -lt $cutoff
}
if ($oldBackups) {
    Write-Host ""
    Write-Host "Removing backups older than $Keep days:" -ForegroundColor Yellow
    foreach ($old in $oldBackups) {
        Write-Host "  - $($old.Name)" -ForegroundColor Gray
        Remove-Item -Recurse -Force $old.FullName
    }
}

$size = (Get-ChildItem $backupDir -Recurse | Measure-Object Length -Sum).Sum / 1MB
$totalBackupSize = (Get-ChildItem $Output -Recurse | Measure-Object Length -Sum).Sum / 1MB
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Daily backup complete: $timestamp" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Total stored:    $([math]::Round($totalBackupSize, 1)) MB ($Keep days retention)"
Write-Host "  Location:        $backupDir"
Write-Host "  Repos bundled:   $($total - $failed.Count) / $total"
Write-Host "  Size:            $([math]::Round($size, 1)) MB"
if ($failed.Count -gt 0) {
    Write-Host "  Failed:          $($failed -join ', ')" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Restore example (1 repo):" -ForegroundColor Cyan
Write-Host "  git clone $backupDir\<repo>.bundle restored-<repo>"
Write-Host ""
Write-Host "Recommended: copy $backupDir to external SSD or OneDrive monthly"
