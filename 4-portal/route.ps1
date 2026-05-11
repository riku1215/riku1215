# route.ps1 - Captain Portal 階層分岐 dispatcher (Windows / PowerShell 版)
#
# route.sh (Linux/macOS) の機能等価実装。
# routing.yml の rules を上から評価し、最初に match した pipeline を表示。
#
# Usage:
#   .\route.ps1 "pet-care-app PR #52 の CI 失敗を直して"
#   .\route.ps1 -DryRun "新機能を追加したい"
#   .\route.ps1 -Rule new-feature "..."   # 明示指定
#   .\route.ps1 -Help
#
# tags: [captain-portal, routing, dispatcher, harness, windows]

[CmdletBinding()]
param(
    [switch]$DryRun,
    [string]$Rule = "",
    [switch]$Help,
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Input
)

$ErrorActionPreference = "Stop"

# === UTF-8 encoding (Japanese Windows) ===
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RoutingYml = Join-Path $ScriptDir "routing.yml"
$AgentsYml = Join-Path $ScriptDir "agents.yml"
$LogFile = Join-Path $env:USERPROFILE ".kb\routing.log"

if ($Help -or ($Input.Count -eq 0 -and -not $Rule)) {
    @"
Usage: .\route.ps1 [-DryRun] [-Rule <RULE_ID>] "<task description>"

Examples:
  .\route.ps1 "pet-care-app PR #52 の CI 失敗を直して"
  .\route.ps1 -DryRun "新機能を追加したい"
  .\route.ps1 -Rule strategy-decision "Phase 2 で hi-spec マシン買うべき?"

Rules defined in:  $RoutingYml
Agents defined in: $AgentsYml
Log file:          $LogFile
"@ | Write-Host
    exit 0
}

$InputText = $Input -join " "
$InputLower = $InputText.ToLower()

# === Keyword matcher ===
function Match-Keywords {
    param([string[]]$Keywords)
    foreach ($kw in $Keywords) {
        if ($InputLower.Contains($kw.ToLower()) -or $InputText.Contains($kw)) {
            return $true
        }
    }
    return $false
}

function Determine-Rule {
    if ($Rule) { return $Rule }

    # Level 0: explicit mention
    if (Match-Keywords @("@architect","@researcher","@coder","@reviewer","@critic","@historian")) {
        return "explicit-mention"
    }
    # Level 1: urgent
    if (Match-Keywords @("緊急","急ぎ","今すぐ","urgent","asap")) {
        return "urgent-bypass"
    }
    # Level 2: task type
    if (Match-Keywords @("バグ","bug","fix","不具合","エラー","error","落ちる","失敗","直し")) {
        return "bug-fix"
    }
    if (Match-Keywords @("リファクタ","refactor","再構成")) {
        return "refactor"
    }
    if (Match-Keywords @("新規","追加","作って","実装","feature","build","create")) {
        return "new-feature"
    }
    if (Match-Keywords @("戦略","経営","方針","判断","決定","strategy","decide","買うべき")) {
        return "strategy-decision"
    }
    if (Match-Keywords @("調査","過去","先行","事例","research","prior")) {
        return "research-investigation"
    }
    if (Match-Keywords @("レビュー","review","確認して","チェック")) {
        return "review-only"
    }
    if (Match-Keywords @("deploy","デプロイ","リリース","release","公開")) {
        return "deploy"
    }
    if (Match-Keywords @("knowledge","kb","同期","記憶")) {
        return "kb-sync"
    }
    # Level 3: pure question
    if (($InputText.Contains("?") -or $InputText.Contains("？")) -and
        -not (Match-Keywords @("実装","作って","fix","deploy"))) {
        return "pure-question"
    }
    # Level 99: default
    return "default"
}

function Get-Pipeline {
    param([string]$RuleId)
    switch ($RuleId) {
        "explicit-mention"       { return "orchestrator -> <mentioned> -> orchestrator" }
        "urgent-bypass"          { return "orchestrator -> coder -> orchestrator (post-review flag)" }
        "bug-fix"                { return "orchestrator -> researcher -> coder -> reviewer -> historian -> orchestrator" }
        "new-feature"            { return "orchestrator -> researcher -> architect -> critic -> coder -> reviewer -> historian -> orchestrator" }
        "refactor"               { return "orchestrator -> researcher -> architect -> critic -> coder -> reviewer -> historian -> orchestrator" }
        "strategy-decision"      { return "orchestrator -> researcher -> architect -> critic -> orchestrator" }
        "research-investigation" { return "orchestrator -> researcher -> orchestrator" }
        "review-only"            { return "orchestrator -> reviewer -> critic -> orchestrator" }
        "deploy"                 { return "orchestrator -> researcher -> reviewer -> coder -> historian -> orchestrator" }
        "kb-sync"                { return "orchestrator -> historian -> orchestrator" }
        "pure-question"          { return "orchestrator -> researcher -> orchestrator" }
        "default"                { return "orchestrator -> researcher -> architect -> critic -> orchestrator" }
        default                  { return "unknown rule: $RuleId" }
    }
}

$MatchedRule = Determine-Rule
$Pipeline = Get-Pipeline $MatchedRule
$InputHash = [System.BitConverter]::ToString(
    [System.Security.Cryptography.SHA256]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($InputText)
    )
).Replace("-","").Substring(0,8).ToLower()
$Ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "================================================" -ForegroundColor Green
Write-Host "  Captain Portal Router (Windows)" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Input    : $InputText"
Write-Host "  Hash     : $InputHash"
Write-Host "  Matched  : $MatchedRule" -ForegroundColor Yellow
Write-Host "  Pipeline : $Pipeline" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Green

if (-not $DryRun) {
    $LogDir = Split-Path -Parent $LogFile
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
    }
    $LogLine = "[$Ts] hash=$InputHash rule=$MatchedRule pipeline=`"$Pipeline`" input=`"$InputText`""
    Add-Content -Path $LogFile -Value $LogLine -Encoding utf8
    Write-Host "  Logged   : $LogFile"
}

Write-Host ""
Write-Host "Next: Claude (orchestrator) executes the pipeline above." -ForegroundColor Yellow
Write-Host "      Each agent's role / LLM / skills: see $AgentsYml"
