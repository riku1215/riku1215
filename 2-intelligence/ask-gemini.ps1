# Ask Gemini (Windows PowerShell) - Quick consultation for decision support
#
# Usage:
#   .\ask-gemini.ps1 "your question"
#   .\ask-gemini.ps1 -Model gemini-2.5-flash "lighter query"
#
# Trigger pattern (per PROFILE.md Section 7-10):
#   1. 進め方で迷ったとき
#   2. 複数の選択肢があるとき
#   3. 客観的な意見が欲しいとき

param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Question,
    [string]$Model = "gemini-2.5-pro"
)

$questionText = $Question -join ' '

# Load API key
if (-not $env:GEMINI_API_KEY) {
    if (Test-Path "$env:USERPROFILE\.kb\gemini.env") {
        Get-Content "$env:USERPROFILE\.kb\gemini.env" | ForEach-Object {
            if ($_ -match '^([A-Z_]+)=(.+)$') {
                [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
            }
        }
    }
}

if (-not $env:GEMINI_API_KEY) {
    Write-Error "GEMINI_API_KEY not set. Set via: `$env:GEMINI_API_KEY = 'AIza...'"
    exit 1
}

$system = @'
あなたは Captain (個人事業主、AI戦略コンサル兼AI駆動アプリ開発者、46 GitHub repo + 1000+ Issue 単独運用) の意思決定を助ける独立コンサルタントです。

回答原則:
- 結論を先頭 200 字以内で明示
- ★ 推奨度 (5段階) または 確信度 (%) を付与
- 反論余地・代替案を明示 (R8)
- Codex 形式併用可: ① 判断 / ② trade-off / ③ 懸念
- Captain 提示案に追従しない (独立判断を出す)
- 不明点は逆質問

評価対象は Claude の提案 / Captain の判断 / 業務上の選択肢など多岐。
'@

$body = @{
    systemInstruction = @{ parts = @(@{ text = $system }) }
    contents = @(@{ role = "user"; parts = @(@{ text = $questionText }) })
    generationConfig = @{
        temperature = 0.4
        maxOutputTokens = 4096
    }
} | ConvertTo-Json -Depth 10 -Compress

$uri = "https://generativelanguage.googleapis.com/v1beta/models/${Model}:generateContent?key=$env:GEMINI_API_KEY"

try {
    $response = Invoke-RestMethod -Method Post -Uri $uri `
        -Headers @{ "Content-Type" = "application/json" } `
        -Body $body -TimeoutSec 60

    foreach ($cand in $response.candidates) {
        foreach ($part in $cand.content.parts) {
            Write-Output $part.text
        }
    }

    $usage = $response.usageMetadata
    Write-Host ""
    Write-Host "---" -ForegroundColor DarkGray
    Write-Host "Model: $Model" -ForegroundColor DarkGray
    Write-Host "Tokens: prompt=$($usage.promptTokenCount), output=$($usage.candidatesTokenCount)" -ForegroundColor DarkGray
} catch {
    Write-Error "Gemini API error: $_"
    exit 1
}
