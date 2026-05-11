# Phase A Prerequisites Check - Windows PowerShell
# Usage: .\doctor.ps1
# Verifies environment before running setup.ps1

$ErrorActionPreference = "Continue"

function Check-Tool {
    param([string]$Name, [string]$Cmd, [string]$Install)
    Write-Host -NoNewline "  $Name`: "
    if (Get-Command $Cmd -ErrorAction SilentlyContinue) {
        $ver = & $Cmd --version 2>$null | Select-Object -First 1
        Write-Host "OK ($ver)" -ForegroundColor Green
        return $true
    } else {
        Write-Host "MISSING" -ForegroundColor Red
        Write-Host "    Install: $Install" -ForegroundColor Yellow
        return $false
    }
}

function Check-Disk {
    param([string]$Drive, [int]$MinGB)
    $info = Get-PSDrive $Drive -ErrorAction SilentlyContinue
    if (-not $info) {
        Write-Host "  Drive $Drive`: NOT FOUND" -ForegroundColor Red
        return $false
    }
    $freeGB = [math]::Round($info.Free / 1GB, 1)
    Write-Host -NoNewline "  Drive $Drive free space: $freeGB GB "
    if ($freeGB -ge $MinGB) {
        Write-Host "(>= $MinGB GB OK)" -ForegroundColor Green
        return $true
    } else {
        Write-Host "(< $MinGB GB INSUFFICIENT)" -ForegroundColor Red
        return $false
    }
}

Write-Host "===== Phase A Doctor =====" -ForegroundColor Cyan
Write-Host ""

Write-Host "=== Required tools ===" -ForegroundColor Cyan
$tools_ok = $true
$tools_ok = (Check-Tool "Git" "git" "winget install Git.Git") -and $tools_ok
$tools_ok = (Check-Tool "GitHub CLI" "gh" "winget install GitHub.cli") -and $tools_ok
$tools_ok = (Check-Tool "ripgrep" "rg" "winget install BurntSushi.ripgrep.MSVC") -and $tools_ok
$tools_ok = (Check-Tool "jq (optional)" "jq" "winget install jqlang.jq") -and $tools_ok

Write-Host ""
Write-Host "=== GitHub authentication ===" -ForegroundColor Cyan
$null = gh auth status 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  gh auth: OK" -ForegroundColor Green
    gh auth status 2>&1 | Select-Object -First 5 | ForEach-Object { Write-Host "    $_" }
} else {
    Write-Host "  gh auth: NOT AUTHENTICATED" -ForegroundColor Red
    Write-Host "    Run: gh auth login" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Disk space ===" -ForegroundColor Cyan
$disk_ok = Check-Disk "C" 20

Write-Host ""
Write-Host "=== Optional: Phase D prerequisites ===" -ForegroundColor Cyan
$null = Check-Tool "Python" "python" "winget install Python.Python.3.12"
$null = Check-Tool "Ollama" "ollama" "Download from https://ollama.com/download"

Write-Host ""
Write-Host "===== Summary =====" -ForegroundColor Cyan
if ($tools_ok -and $disk_ok) {
    Write-Host "Ready to run: .\setup.ps1" -ForegroundColor Green
} else {
    Write-Host "Fix missing prerequisites before running setup.ps1" -ForegroundColor Red
}
Write-Host ""
