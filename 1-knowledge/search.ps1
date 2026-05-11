# KB Search Helper
# Usage:
#   .\search.ps1 -Query "sakura"                 # all sources
#   .\search.ps1 -Query "sakura" -Type titles    # issue titles only
#   .\search.ps1 -Query "deploy" -Type files     # code files only
#   .\search.ps1 -Query "PR#52" -Type issues     # issue bodies + comments
#   .\search.ps1 -Query "billing" -Repo agora    # restrict to specific repo

param(
    [Parameter(Mandatory=$true)][string]$Query,
    [ValidateSet("all","files","issues","titles","labels")][string]$Type = "all",
    [string]$Repo = "",
    [int]$Max = 50
)

$kbRoot = "$env:USERPROFILE\.kb"

if (-not (Test-Path $kbRoot)) {
    Write-Error "KB not initialized. Run setup.ps1 first."
    exit 1
}

# Check ripgrep
if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
    Write-Warning "ripgrep (rg) not found. Install: winget install BurntSushi.ripgrep.MSVC"
    Write-Warning "Falling back to slow Select-String..."
    $useRg = $false
} else {
    $useRg = $true
}

$searchRepos = if ($Repo) { "$kbRoot\repos\$Repo" } else { "$kbRoot\repos" }
$searchIssues = if ($Repo) { "$kbRoot\issues\$Repo.json" } else { "$kbRoot\issues" }

# === Files (source code) ===
if ($Type -eq "all" -or $Type -eq "files") {
    Write-Host "===== Repository Files =====" -ForegroundColor Cyan
    if ($useRg) {
        rg --color=always --max-count=3 -i $Query $searchRepos 2>$null | Select-Object -First $Max
    } else {
        Get-ChildItem -Path $searchRepos -Recurse -File -ErrorAction SilentlyContinue |
            Select-String -Pattern $Query -SimpleMatch -ErrorAction SilentlyContinue |
            Select-Object -First $Max
    }
}

# === Issue bodies + comments ===
if ($Type -eq "all" -or $Type -eq "issues") {
    Write-Host "`n===== Issue Bodies & Comments =====" -ForegroundColor Cyan
    if ($useRg) {
        rg --color=always --max-count=3 -i $Query $searchIssues 2>$null | Select-Object -First $Max
    } else {
        Get-ChildItem -Path $searchIssues -Filter *.json -ErrorAction SilentlyContinue |
            Select-String -Pattern $Query -SimpleMatch -ErrorAction SilentlyContinue |
            Select-Object -First $Max
    }
}

# === Issue titles (structured) ===
if ($Type -eq "all" -or $Type -eq "titles") {
    Write-Host "`n===== Issue Titles =====" -ForegroundColor Cyan
    $files = if ($Repo) {
        @("$kbRoot\issues\$Repo.json")
    } else {
        Get-ChildItem "$kbRoot\issues\*.json"
    }
    foreach ($f in $files) {
        if (-not (Test-Path $f)) { continue }
        $repoName = ([System.IO.Path]::GetFileNameWithoutExtension($f))
        $issues = Get-Content $f -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
        if (-not $issues) { continue }
        $matched = $issues | Where-Object { $_.title -match $Query }
        foreach ($iss in $matched) {
            $state = if ($iss.state -eq "OPEN") { "OPEN " } else { "closed" }
            Write-Host "  [$state] $repoName#$($iss.number): $($iss.title)" -ForegroundColor Yellow
            Write-Host "    $($iss.url)" -ForegroundColor DarkGray
        }
    }
}

# === Labels ===
if ($Type -eq "labels") {
    Write-Host "`n===== Issues with matching labels =====" -ForegroundColor Cyan
    $files = if ($Repo) {
        @("$kbRoot\issues\$Repo.json")
    } else {
        Get-ChildItem "$kbRoot\issues\*.json"
    }
    foreach ($f in $files) {
        if (-not (Test-Path $f)) { continue }
        $repoName = ([System.IO.Path]::GetFileNameWithoutExtension($f))
        $issues = Get-Content $f -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
        if (-not $issues) { continue }
        $matched = $issues | Where-Object {
            $_.labels | Where-Object { $_.name -match $Query }
        }
        foreach ($iss in $matched) {
            $labelNames = ($iss.labels | ForEach-Object { $_.name }) -join ", "
            Write-Host "  [$repoName#$($iss.number)] $($iss.title)" -ForegroundColor Yellow
            Write-Host "    Labels: $labelNames" -ForegroundColor DarkGray
        }
    }
}
