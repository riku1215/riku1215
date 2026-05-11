# find-by-tag.ps1 - ラベル / hashtag による KB 検索 (Windows PowerShell)
#
# Usage:
#   .\find-by-tag.ps1 -Tag sakura
#   .\find-by-tag.ps1 -Tag sakura,migration  # AND 検索
#   .\find-by-tag.ps1 -Tag sakura -Mode frontmatter
#   .\find-by-tag.ps1 -Tag sakura -Layer 1-knowledge
#   .\find-by-tag.ps1 -Tag sakura -Mode issues

param(
    [Parameter(Mandatory=$true)][string[]]$Tag,
    [ValidateSet("all", "frontmatter", "inline", "issues")][string]$Mode = "all",
    [string]$Layer = ""
)

$kbRoot = "$env:USERPROFILE\.kb"
$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path

# Determine search roots
$roots = @()
if ($Layer) {
    $layerPath = "$repoRoot\$Layer"
    if (Test-Path $layerPath) { $roots += $layerPath }
} else {
    $roots += $repoRoot
    if (Test-Path $kbRoot) { $roots += $kbRoot }
}

if ($Mode -in @("all", "frontmatter")) {
    Write-Host "=== YAML frontmatter matches ===" -ForegroundColor Cyan
    foreach ($t in $Tag) {
        Write-Host ""
        Write-Host "Tag: #$t" -ForegroundColor Yellow
        foreach ($r in $roots) {
            if (Get-Command rg -ErrorAction SilentlyContinue) {
                rg --max-count=1 -l "^tags:.*\b$t\b" $r 2>$null | Select-Object -First 20
            }
        }
    }
}

if ($Mode -in @("all", "inline")) {
    Write-Host ""
    Write-Host "=== Inline #hashtag matches ===" -ForegroundColor Cyan
    foreach ($t in $Tag) {
        Write-Host ""
        Write-Host "Tag: #$t" -ForegroundColor Yellow
        foreach ($r in $roots) {
            if (Get-Command rg -ErrorAction SilentlyContinue) {
                rg --color always "#$t\b" $r 2>$null | Select-Object -First 10
            }
        }
    }
}

if ($Mode -in @("all", "issues")) {
    $issuesDir = "$kbRoot\issues"
    if (Test-Path $issuesDir) {
        Write-Host ""
        Write-Host "=== GitHub Issue labels (from KB) ===" -ForegroundColor Cyan
        foreach ($t in $Tag) {
            Write-Host ""
            Write-Host "Label: $t" -ForegroundColor Yellow
            Get-ChildItem "$issuesDir\*.json" | ForEach-Object {
                $repoName = $_.BaseName
                try {
                    $issues = Get-Content $_.FullName -Raw | ConvertFrom-Json
                    $issues | Where-Object {
                        $_.labels | Where-Object { $_.name -eq $t }
                    } | Select-Object -First 5 | ForEach-Object {
                        Write-Host "  [$t] $($_.url) - $($_.title)"
                    }
                } catch {}
            }
        }
    }
}
