# Phase F: NAS-like expansion (Windows PowerShell)
# Fetches PRs, Releases, Workflow runs, Wikis, Discussions, Repo meta.
#
# Usage:
#   .\expand.ps1                          # PRs + Releases + Meta
#   .\expand.ps1 -WithRuns                # + Workflow runs
#   .\expand.ps1 -WithDiscussions         # + Discussions
#   .\expand.ps1 -WithRuns -WithDiscussions  # Full NAS treatment

param(
    [switch]$WithRuns,
    [switch]$WithDiscussions
)

$ErrorActionPreference = "Continue"
$kbRoot = "$env:USERPROFILE\.kb"
$prsDir = "$kbRoot\prs"
$releasesDir = "$kbRoot\releases"
$runsDir = "$kbRoot\workflow-runs"
$discussionsDir = "$kbRoot\discussions"
$metaDir = "$kbRoot\repo-meta"
$logFile = "$kbRoot\expand.log"

if (-not (Test-Path "$kbRoot\repos.json")) {
    Write-Error "Run setup.ps1 first."
    exit 1
}

$null = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "gh not authenticated. Run: gh auth login"
    exit 1
}

New-Item -ItemType Directory -Force -Path $prsDir, $releasesDir, $metaDir | Out-Null
if ($WithRuns) { New-Item -ItemType Directory -Force -Path $runsDir | Out-Null }
if ($WithDiscussions) { New-Item -ItemType Directory -Force -Path $discussionsDir | Out-Null }

function Write-Log {
    param([string]$msg)
    $ts = Get-Date -Format "HH:mm:ss"
    Add-Content -Path $logFile -Value "[$ts] $msg"
    Write-Host "[$ts] $msg"
}

$repos = Get-Content "$kbRoot\repos.json" | ConvertFrom-Json
$repoCount = $repos.Count
Write-Log "=== Phase F expansion: $repoCount repos ==="

$totalPRs = 0
$totalReleases = 0
$i = 0
foreach ($repo in $repos) {
    $i++
    $name = $repo.name
    Write-Log "  [$i/$repoCount] $name"

    # === Pull Requests ===
    $prJson = gh pr list -R "riku1215/$name" --state all --limit 9999 `
        --json number,title,body,state,createdAt,closedAt,updatedAt,mergedAt,author,assignees,labels,reviews,comments,reviewRequests,changedFiles,additions,deletions,baseRefName,headRefName,url,isDraft,mergeable `
        2>$null
    if ($LASTEXITCODE -eq 0 -and $prJson) {
        $prJson | Out-File "$prsDir\$name.json" -Encoding utf8
        $count = ($prJson | ConvertFrom-Json).Count
        $totalPRs += $count
    } else {
        "[]" | Out-File "$prsDir\$name.json" -Encoding utf8
    }

    # === Releases ===
    $relJson = gh release list -R "riku1215/$name" --limit 100 `
        --json name,tagName,createdAt,publishedAt,isDraft,isPrerelease,isLatest,url `
        2>$null
    if ($LASTEXITCODE -eq 0 -and $relJson) {
        $relJson | Out-File "$releasesDir\$name.json" -Encoding utf8
        $count = ($relJson | ConvertFrom-Json).Count
        $totalReleases += $count
    } else {
        "[]" | Out-File "$releasesDir\$name.json" -Encoding utf8
    }

    # === Repo metadata ===
    $metaJson = gh repo view "riku1215/$name" `
        --json name,description,topics,languages,defaultBranchRef,createdAt,pushedAt,homepageUrl,visibility,isArchived,isFork,licenseInfo,diskUsage,stargazerCount,forkCount,openIssues,owner `
        2>$null
    if ($LASTEXITCODE -eq 0 -and $metaJson) {
        $metaJson | Out-File "$metaDir\$name.json" -Encoding utf8
    } else {
        "{}" | Out-File "$metaDir\$name.json" -Encoding utf8
    }

    # === Workflow runs (optional, heavy) ===
    if ($WithRuns) {
        $runJson = gh run list -R "riku1215/$name" --limit 50 `
            --json databaseId,name,displayTitle,event,status,conclusion,workflowName,headBranch,createdAt,updatedAt,url `
            2>$null
        if ($LASTEXITCODE -eq 0 -and $runJson) {
            $runJson | Out-File "$runsDir\$name.json" -Encoding utf8
        } else {
            "[]" | Out-File "$runsDir\$name.json" -Encoding utf8
        }
    }

    # === Discussions (optional, GraphQL) ===
    if ($WithDiscussions) {
        $query = "{ repository(owner: \`"riku1215\`", name: \`"$name\`") { discussions(first: 50) { nodes { number title body createdAt updatedAt url category { name } author { login } } } } }"
        $discJson = gh api graphql -f "query=$query" 2>$null
        if ($LASTEXITCODE -eq 0 -and $discJson) {
            $discJson | Out-File "$discussionsDir\$name.json" -Encoding utf8
        } else {
            "{}" | Out-File "$discussionsDir\$name.json" -Encoding utf8
        }
    }
}

# === Summary ===
$kbSize = (Get-ChildItem $kbRoot -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB
Write-Log "=== Phase F expansion done ==="
Write-Log "  Total PRs collected:      $totalPRs"
Write-Log "  Total releases collected: $totalReleases"
Write-Log "  KB size now:              $([math]::Round($kbSize, 1)) MB"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Phase F expansion complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "  PRs:               $totalPRs"
Write-Host "  Releases:          $totalReleases"
Write-Host "  Repo meta:         $repoCount"
if ($WithRuns) { Write-Host "  Workflow runs:     done" }
if ($WithDiscussions) { Write-Host "  Discussions:       done" }
Write-Host "  KB size:           $([math]::Round($kbSize, 1)) MB"
Write-Host ""
Write-Host "Next:" -ForegroundColor Yellow
Write-Host "  Search PRs:        rg 'keyword' $prsDir\"
Write-Host "  Re-index Phase D:  cd vector-search; python index.py"
