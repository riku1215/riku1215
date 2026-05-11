# Local KB Update (Robust Version) - Phase C + Gemini-reviewed enhancements
#
# Adds: try-catch error handling, structured logging, failure notification
# (BurntToast or fallback to Write-EventLog), retry logic for transient failures.
#
# Usage: .\update-robust.ps1
# Recommended: Task Scheduler daily 09:00

[CmdletBinding()]
param(
    [string]$KbRoot = "$env:USERPROFILE\.kb",
    [int]$MaxRetries = 3,
    [int]$RetryDelaySec = 10,
    [string]$NotifyOnFailure = "toast"  # "toast", "email", "none"
)

$ErrorActionPreference = "Continue"
$reposDir = "$KbRoot\repos"
$issuesDir = "$KbRoot\issues"
$logFile = "$KbRoot\update.log"
$errorLog = "$KbRoot\update-errors.log"

# Ensure base structure
if (-not (Test-Path $reposDir) -or -not (Test-Path $issuesDir)) {
    Write-Error "KB not initialized. Run setup.ps1 first."
    exit 1
}

# === Logging helpers ===
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] [$Level] $Message"
    Add-Content -Path $logFile -Value $line
    if ($Level -eq "ERROR") {
        Add-Content -Path $errorLog -Value $line
    }
    if ($Level -in @("ERROR", "WARN") -or $VerbosePreference -eq "Continue") {
        Write-Host $line
    }
}

function Send-FailureNotification {
    param([string]$Title, [string]$Message)
    if ($NotifyOnFailure -eq "none") { return }

    if ($NotifyOnFailure -eq "toast") {
        if (Get-Module -ListAvailable -Name BurntToast) {
            Import-Module BurntToast
            New-BurntToastNotification -Text $Title, $Message
        } else {
            # Fallback: Windows balloon via PowerShell (works without extra modules)
            Add-Type -AssemblyName System.Windows.Forms
            $notify = New-Object System.Windows.Forms.NotifyIcon
            $notify.Icon = [System.Drawing.SystemIcons]::Warning
            $notify.BalloonTipTitle = $Title
            $notify.BalloonTipText = $Message
            $notify.Visible = $true
            $notify.ShowBalloonTip(10000)
            Start-Sleep -Seconds 11
            $notify.Dispose()
        }
    }
}

# === Retry wrapper ===
function Invoke-WithRetry {
    param([scriptblock]$Action, [string]$Description, [int]$Retries = $MaxRetries)
    $attempt = 0
    while ($attempt -lt $Retries) {
        $attempt++
        try {
            & $Action
            return $true
        } catch {
            Write-Log "Attempt ${attempt}/${Retries} failed for ${Description}: $_" "WARN"
            if ($attempt -lt $Retries) {
                Start-Sleep -Seconds ($RetryDelaySec * $attempt)
            }
        }
    }
    Write-Log "All retries failed for ${Description}" "ERROR"
    return $false
}

# === Verify gh auth ===
$null = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Log "gh CLI not authenticated, aborting" "ERROR"
    Send-FailureNotification -Title "KB Update Failed" -Message "gh auth required. Run: gh auth login"
    exit 1
}

$startTime = Get-Date
Write-Log "=== KB update started ===" "INFO"

# === Re-fetch repo list ===
$ok = Invoke-WithRetry -Description "fetch repo list" -Action {
    gh repo list riku1215 --json name,visibility,defaultBranchRef,updatedAt,description --limit 100 |
        Out-File "$KbRoot\repos.json" -Encoding utf8
    if ($LASTEXITCODE -ne 0) { throw "gh repo list returned $LASTEXITCODE" }
}
if (-not $ok) {
    Send-FailureNotification -Title "KB Update Failed" -Message "Could not fetch repo list. See $errorLog"
    exit 1
}

$repos = Get-Content "$KbRoot\repos.json" | ConvertFrom-Json
$repoCount = $repos.Count

$stats = @{
    new = 0; updated = 0; failed = @(); issuesUpdated = 0
}

foreach ($repo in $repos) {
    $name = $repo.name
    $target = "$reposDir\$name"

    # === Clone if new ===
    if (-not (Test-Path $target)) {
        $cloned = Invoke-WithRetry -Description "clone $name" -Action {
            gh repo clone "riku1215/$name" $target -- --depth=100 --quiet 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) { throw "clone $name failed" }
        }
        if ($cloned) {
            Write-Log "[NEW] cloned $name" "INFO"
            $stats.new++
        } else {
            $stats.failed += $name
            continue
        }
    } else {
        # === Pull existing repo ===
        $pulled = Invoke-WithRetry -Description "pull $name" -Action {
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
                        Write-Log "[UPDATED] $name ($before -> $after)" "INFO"
                        $script:stats.updated++
                    }
                }
            } finally {
                Pop-Location
            }
        }
        if (-not $pulled) {
            $stats.failed += $name
        }
    }

    # === Update issues with retry ===
    $issueFetched = Invoke-WithRetry -Description "fetch issues $name" -Action {
        $oldPath = "$issuesDir\$name.json"
        $oldHash = if (Test-Path $oldPath) { (Get-FileHash $oldPath -ErrorAction SilentlyContinue).Hash } else { "" }

        $issueJson = gh issue list -R "riku1215/$name" --state all --limit 9999 `
            --json number,title,body,labels,comments,state,createdAt,closedAt,updatedAt,author,assignees,url `
            2>$null
        if ($LASTEXITCODE -ne 0) { throw "gh issue list $name failed" }

        $issueJson | Out-File $oldPath -Encoding utf8
        $newHash = (Get-FileHash $oldPath).Hash
        if ($oldHash -ne $newHash) {
            $script:stats.issuesUpdated++
        }
    }
    if (-not $issueFetched) {
        # Save empty array so search.ps1 doesn't break
        "[]" | Out-File "$issuesDir\$name.json" -Encoding utf8
    }
}

# === Disk space check ===
$drive = (Get-Item $KbRoot).PSDrive
$freeGB = [math]::Round($drive.Free / 1GB, 1)
$totalGB = [math]::Round(($drive.Free + $drive.Used) / 1GB, 1)
if ($freeGB -lt 5) {
    Write-Log "Low disk space: $freeGB GB free / $totalGB GB total" "ERROR"
    Send-FailureNotification -Title "KB Update: Low Disk" -Message "Only $freeGB GB free on $($drive.Name): drive"
}

# === Summary ===
$elapsed = ((Get-Date) - $startTime).TotalSeconds
$failedCount = $stats.failed.Count
Write-Log "=== KB update done: new=$($stats.new) updated=$($stats.updated) failed=$failedCount issues=$($stats.issuesUpdated) elapsed=${elapsed}s ===" "INFO"

# === Notification on partial failure ===
if ($failedCount -gt 0) {
    $failedRepos = $stats.failed -join ", "
    Send-FailureNotification -Title "KB Update: $failedCount Failures" `
        -Message "Failed: $failedRepos. See $errorLog"
} elseif ($stats.updated -eq 0 -and $stats.new -eq 0) {
    Write-Log "No changes detected (KB is fresh)" "INFO"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Update complete ($([math]::Round($elapsed, 0))s)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "  New repos:           $($stats.new)"
Write-Host "  Updated repos:       $($stats.updated)"
Write-Host "  Failed:              $failedCount"
Write-Host "  Issue files updated: $($stats.issuesUpdated) / $repoCount"
Write-Host "  Disk free:           $freeGB GB"
Write-Host "  Log:                 $logFile"
if ($failedCount -gt 0) {
    Write-Host "  Errors:              $errorLog" -ForegroundColor Yellow
}
