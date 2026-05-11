# kb-stats.ps1 - KB size monitoring (Windows PowerShell)
# Grok レビュー結果: 10K docs で Semantic Collapse (Stanford 論文)
# Usage: .\kb-stats.ps1 [-Json]

param([switch]$Json)

$kbRoot = "$env:USERPROFILE\.kb"
$issuesDir = "$kbRoot\issues"
$prsDir = "$kbRoot\prs"
$releasesDir = "$kbRoot\releases"

$SAFE = 5000
$WARN = 8000
$CRIT = 10000

function Count-Docs($dir) {
    if (-not (Test-Path $dir)) { return 0 }
    $total = 0
    Get-ChildItem -Path $dir -Filter *.json -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $arr = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
            if ($arr -is [array]) { $total += $arr.Count }
        } catch {}
    }
    return $total
}

$issueCount = Count-Docs $issuesDir
$prCount = Count-Docs $prsDir
$releaseCount = Count-Docs $releasesDir

$repoCount = 0
if (Test-Path "$kbRoot\repos") {
    $repoCount = (Get-ChildItem "$kbRoot\repos" -Directory).Count
}

$totalDocs = $issueCount + $prCount + $releaseCount

# KB size
$kbSizeMB = 0
if (Test-Path $kbRoot) {
    $kbSizeMB = [math]::Round((Get-ChildItem $kbRoot -Recurse -ErrorAction SilentlyContinue |
        Measure-Object Length -Sum).Sum / 1MB, 1)
}

# Status
if ($totalDocs -lt $SAFE) {
    $status = "SAFE"
    $advice = "Phase D ベクトル検索は最適に動作中"
} elseif ($totalDocs -lt $WARN) {
    $status = "GROWING"
    $advice = "re-ranker 導入を計画開始推奨"
} elseif ($totalDocs -lt $CRIT) {
    $status = "WARN"
    $advice = "re-ranker 必須 (Phase H 着手)"
} else {
    $status = "CRITICAL"
    $advice = "Semantic Collapse 領域、即 re-ranker / hybrid search 導入"
}

if ($Json) {
    @{
        kb_root = $kbRoot
        kb_size_mb = $kbSizeMB
        repo_count = $repoCount
        issues = $issueCount
        prs = $prCount
        releases = $releaseCount
        total_docs = $totalDocs
        status = $status
        thresholds = @{safe = $SAFE; warn = $WARN; critical = $CRIT}
        advice = $advice
    } | ConvertTo-Json -Depth 3
} else {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  KB Stats - $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  KB root:        $kbRoot"
    Write-Host "  KB size:        $kbSizeMB MB"
    Write-Host "  Repos:          $repoCount"
    Write-Host ""
    Write-Host "  Document counts:"
    Write-Host "    Issues:       $issueCount"
    Write-Host "    PRs:          $prCount"
    Write-Host "    Releases:     $releaseCount"
    Write-Host "    TOTAL:        $totalDocs" -ForegroundColor Yellow
    Write-Host ""
    $statusColor = switch ($status) {
        "SAFE" { "Green" }
        "GROWING" { "Yellow" }
        "WARN" { "Yellow" }
        "CRITICAL" { "Red" }
    }
    Write-Host "  Status: $status" -ForegroundColor $statusColor
    Write-Host ""
    Write-Host "  Thresholds (Grok レビュー / Stanford 論文 Semantic Collapse):"
    Write-Host "    < $SAFE:    SAFE"
    Write-Host "    < $WARN:    GROWING (re-ranker 計画)"
    Write-Host "    < $CRIT:    WARN (re-ranker 必須)"
    Write-Host "    >= $CRIT:   CRITICAL (Semantic Collapse 領域)"
    Write-Host ""
    Write-Host "  Advice: $advice" -ForegroundColor $statusColor
    Write-Host "========================================" -ForegroundColor Cyan
}
