# Phase E: Monthly Backup - Windows PowerShell
# Usage: .\backup.ps1 [-Output <path>]
# Creates git-bundle of all repos for offline backup.

param(
    [string]$Output = "$env:USERPROFILE\.kb\backups"
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
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Write-Host "Creating bundles in: $backupDir" -ForegroundColor Cyan

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

# Also backup issue JSONs as tarball
$issuesDir = "$kbRoot\issues"
if (Test-Path $issuesDir) {
    $issuesArchive = "$backupDir\issues-$timestamp.zip"
    Compress-Archive -Path "$issuesDir\*" -DestinationPath $issuesArchive -Force
    Write-Host "Issues archived: $issuesArchive" -ForegroundColor Green
}

$size = (Get-ChildItem $backupDir -Recurse | Measure-Object Length -Sum).Sum / 1MB
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Backup complete: $timestamp" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
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
