# Local KB Update - Sync all repos + issues
# Usage: .\update.ps1
# Recommended: Schedule daily 09:00 via Task Scheduler

$ErrorActionPreference = "Continue"

# === UTF-8 encoding fix (Japanese Windows / CP932 mojibake 対策) ===
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$kbRoot = "$env:USERPROFILE\.kb"
$reposDir = "$kbRoot\repos"
$issuesDir = "$kbRoot\issues"

if (-not (Test-Path $reposDir) -or -not (Test-Path $issuesDir)) {
    Write-Error "KB not initialized. Run setup.ps1 first."
    exit 1
}

$startTime = Get-Date
Write-Host "[$($startTime.ToString('yyyy-MM-dd HH:mm:ss'))] KB update started" -ForegroundColor Cyan

# === Re-fetch repo list (catch new repos) ===
gh repo list riku1215 --json name,visibility,defaultBranchRef,updatedAt,description --limit 100 |
    Out-File "$kbRoot\repos.json" -Encoding utf8

$repos = Get-Content "$kbRoot\repos.json" | ConvertFrom-Json
$repoCount = $repos.Count

$newRepos = 0
$updatedRepos = 0
$failedRepos = 0
$updatedIssues = 0

foreach ($repo in $repos) {
    $name = $repo.name
    $target = "$reposDir\$name"

    # === Clone if new ===
    if (-not (Test-Path $target)) {
        Write-Host "  [NEW] $name" -ForegroundColor Green
        gh repo clone "riku1215/$name" $target -- --depth=100 --quiet 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $newRepos++ } else { $failedRepos++ }
    } else {
        # === Pull existing repo ===
        Push-Location $target
        try {
            git fetch --all --quiet 2>$null
            $defaultBranchRef = git symbolic-ref refs/remotes/origin/HEAD 2>$null
            if ($defaultBranchRef) {
                $branch = ($defaultBranchRef -replace "refs/remotes/origin/", "")
                $before = git rev-parse HEAD 2>$null
                git checkout $branch --quiet 2>$null
                git pull origin $branch --rebase --quiet 2>$null
                $after = git rev-parse HEAD 2>$null
                if ($before -ne $after) {
                    Write-Host "  [UPDATED] $name ($before -> $after)" -ForegroundColor Yellow
                    $updatedRepos++
                }
            }
        } catch {
            Write-Warning "  Failed to pull $name : $_"
            $failedRepos++
        } finally {
            Pop-Location
        }
    }

    # === Update issues ===
    $issueJson = gh issue list -R "riku1215/$name" --state all --limit 9999 `
        --json number,title,body,labels,comments,state,createdAt,closedAt,updatedAt,author,assignees,url `
        2>$null

    if ($LASTEXITCODE -eq 0 -and $issueJson) {
        # Check if content changed
        $oldPath = "$issuesDir\$name.json"
        $oldHash = if (Test-Path $oldPath) { (Get-FileHash $oldPath).Hash } else { "" }
        $issueJson | Out-File $oldPath -Encoding utf8
        $newHash = (Get-FileHash $oldPath).Hash
        if ($oldHash -ne $newHash) {
            $updatedIssues++
        }
    } else {
        "[]" | Out-File "$issuesDir\$name.json" -Encoding utf8
    }
}

# === Summary ===
$elapsed = ((Get-Date) - $startTime).TotalSeconds
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Update complete ($([math]::Round($elapsed, 0))s)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "  New repos:       $newRepos" -ForegroundColor Cyan
Write-Host "  Updated repos:   $updatedRepos"
Write-Host "  Failed:          $failedRepos"
Write-Host "  Issue files updated: $updatedIssues / $repoCount"
Write-Host ""

# === Optional: append to log ===
$logFile = "$kbRoot\update.log"
"[$($startTime.ToString('yyyy-MM-dd HH:mm:ss'))] new=$newRepos updated=$updatedRepos failed=$failedRepos issues=$updatedIssues elapsed=${elapsed}s" |
    Out-File -Append $logFile -Encoding utf8
