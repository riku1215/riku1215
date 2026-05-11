# build-indexes.ps1 - Captain Portal 統合検索インデックス生成
#
# ~/Portal/indexes/ に以下 6 JSON を生成:
#   - files.json    : 全 md ファイル (path/title/tags/mtime/visibility)
#   - hashtags.json : ハッシュタグ → file 群 (横断検索用)
#   - skills.json   : 47 skills 一覧 (name/description/tags)
#   - rules.json    : R1-R71 + Section 7 失敗パターン
#   - issues.json   : ~/.kb/issues/*.json から上位 200 (OPEN 100 + CLOSED 100)
#   - graph.json    : Cytoscape.js elements (nodes + edges、共起 graph)
#
# Usage:
#   .\build-indexes.ps1
#   .\build-indexes.ps1 -PortalRoot D:\Portal
#   .\build-indexes.ps1 -Verbose
#
# tags: [captain-portal, indexes, search, hashtags, knowledge]

[CmdletBinding()]
param(
    [string]$PortalRoot = "$env:USERPROFILE\Portal",
    [string]$KbRoot = "$env:USERPROFILE\.kb",
    [string]$RepoRoot = "$env:USERPROFILE\riku1215",
    [string]$SkillsRoot = "$env:USERPROFILE\.agents\skills"
)

$ErrorActionPreference = "Continue"

# === UTF-8 encoding ===
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$indexDir = Join-Path $PortalRoot "indexes"
if (-not (Test-Path $indexDir)) {
    New-Item -ItemType Directory -Force -Path $indexDir | Out-Null
}

Write-Host "===== Captain Portal Index Builder =====" -ForegroundColor Green
Write-Host "Output: $indexDir" -ForegroundColor Yellow

# === ヘルパー: frontmatter 抽出 (YAML --- ... ---) ===
function Get-Frontmatter {
    param([string]$Content)
    $fm = @{}
    if ($Content -match "(?s)^---\s*\r?\n(.*?)\r?\n---\s*\r?\n") {
        $yamlBlock = $matches[1]
        foreach ($line in ($yamlBlock -split "`r?`n")) {
            if ($line -match "^\s*([a-zA-Z_][a-zA-Z0-9_-]*)\s*:\s*(.+?)\s*$") {
                $key = $matches[1]
                $val = $matches[2].Trim()
                if ($val -match "^\[(.*)\]$") {
                    # 配列 [a, b, c]
                    $fm[$key] = @($matches[1] -split "\s*,\s*" | ForEach-Object { $_.Trim('"').Trim("'") })
                } else {
                    $fm[$key] = $val.Trim('"').Trim("'")
                }
            }
        }
    }
    return $fm
}

# === ヘルパー: #hashtag 抽出 ===
function Get-Hashtags {
    param([string]$Content)
    $tags = @()
    # ` で囲まれた `#tag1 #tag2` パターンも対応
    foreach ($m in [regex]::Matches($Content, "#([a-zA-Z][a-zA-Z0-9_-]+)")) {
        $tag = $m.Groups[1].Value
        if ($tags -notcontains $tag) { $tags += $tag }
    }
    return $tags
}

# === ヘルパー: 先頭 H1 タイトル抽出 ===
function Get-Title {
    param([string]$Content, [string]$FallbackPath)
    if ($Content -match "(?m)^#\s+(.+?)\s*$") { return $matches[1] }
    return [System.IO.Path]::GetFileNameWithoutExtension($FallbackPath)
}

# ===========================================
# 1. files.json - 全 md ファイル
# ===========================================
Write-Host "[1/6] Scanning md files..." -ForegroundColor Cyan
$mdFiles = @()
$searchPaths = @()
if (Test-Path $RepoRoot) { $searchPaths += $RepoRoot }
if (Test-Path "$KbRoot\repos") { $searchPaths += "$KbRoot\repos" }

foreach ($basePath in $searchPaths) {
    Get-ChildItem -Path $basePath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "node_modules|\.git\\|venv\\|\.venv\\" } |
        ForEach-Object {
            $content = ""
            try { $content = Get-Content $_.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue } catch { return }
            if (-not $content) { return }
            $fm = Get-Frontmatter $content
            $bodyTags = Get-Hashtags $content
            $allTags = @()
            if ($fm.tags) {
                if ($fm.tags -is [array]) { $allTags += $fm.tags } else { $allTags += @($fm.tags) }
            }
            $allTags += $bodyTags
            $allTags = $allTags | Where-Object { $_ } | Sort-Object -Unique

            $mdFiles += [PSCustomObject]@{
                path     = $_.FullName.Replace($env:USERPROFILE, '~').Replace('\','/')
                title    = Get-Title $content $_.FullName
                tags     = $allTags
                mtime    = $_.LastWriteTime.ToString("yyyy-MM-ddTHH:mm:ssK")
                size     = $_.Length
                layer    = if ($fm.layer) { $fm.layer } else { "" }
                status   = if ($fm.status) { $fm.status } else { "" }
                visibility = if ($fm.visibility) { $fm.visibility } else { "local-only" }
                audience = if ($fm.audience) { $fm.audience } else { @() }
            }
        }
}
$mdFiles | ConvertTo-Json -Depth 5 -Compress |
    Out-File (Join-Path $indexDir "files.json") -Encoding utf8 -NoNewline
Write-Host "      $($mdFiles.Count) md files indexed" -ForegroundColor Gray

# ===========================================
# 2. hashtags.json - tag → files 逆引き
# ===========================================
Write-Host "[2/6] Building hashtag index..." -ForegroundColor Cyan
$tagMap = @{}
foreach ($f in $mdFiles) {
    foreach ($t in $f.tags) {
        if (-not $tagMap.ContainsKey($t)) {
            $tagMap[$t] = @{ tag = $t; files = @(); count = 0 }
        }
        $tagMap[$t].files += @{ path = $f.path; title = $f.title }
        $tagMap[$t].count++
    }
}
$tagArr = $tagMap.Values | Sort-Object -Property count -Descending
$tagArr | ConvertTo-Json -Depth 5 -Compress |
    Out-File (Join-Path $indexDir "hashtags.json") -Encoding utf8 -NoNewline
Write-Host "      $($tagArr.Count) unique hashtags" -ForegroundColor Gray

# ===========================================
# 3. skills.json - ~/.agents/skills/ から
# ===========================================
Write-Host "[3/6] Scanning skills..." -ForegroundColor Cyan
$skills = @()
if (Test-Path $SkillsRoot) {
    Get-ChildItem -Path $SkillsRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $skillDir = $_.FullName
        $skillName = $_.Name
        $desc = ""
        $tags = @()
        # skill.json / manifest / README から description 抽出
        $manifest = Get-ChildItem -Path $skillDir -Filter "*.json" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($manifest) {
            try {
                $json = Get-Content $manifest.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
                if ($json.description) { $desc = $json.description }
                if ($json.tags) { $tags = $json.tags }
            } catch { }
        }
        if (-not $desc) {
            $readme = Get-ChildItem -Path $skillDir -Filter "README*" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($readme) {
                $content = Get-Content $readme.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                if ($content -match "(?m)^#\s+(.+?)\s*$") {
                    $desc = $matches[1]
                }
            }
        }
        $skills += [PSCustomObject]@{
            name = $skillName
            description = $desc
            tags = $tags
            path = $skillDir.Replace($env:USERPROFILE, '~').Replace('\','/')
        }
    }
}
$skills | ConvertTo-Json -Depth 5 -Compress |
    Out-File (Join-Path $indexDir "skills.json") -Encoding utf8 -NoNewline
Write-Host "      $($skills.Count) skills" -ForegroundColor Gray

# ===========================================
# 4. rules.json - R-rules + Section 7 抽出
# ===========================================
Write-Host "[4/6] Extracting R-rules..." -ForegroundColor Cyan
$rules = @()
$profilePath = Join-Path $RepoRoot "PROFILE.md"
if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath -Raw -Encoding UTF8
    # R1-R99 抽出 (#### or ### で始まる R-rule 段落)
    foreach ($m in [regex]::Matches($profileContent, "(?m)^(##+)\s+(R\d+(?:-[a-zA-Z0-9_-]+)?)[\s:]\s*(.+?)$")) {
        $rules += [PSCustomObject]@{
            id = $m.Groups[2].Value
            title = $m.Groups[3].Value.Trim()
            source = "PROFILE.md"
        }
    }
    # Section 7 失敗パターン (7-1 〜 7-10)
    foreach ($m in [regex]::Matches($profileContent, "(?m)^###\s+(7-\d+)\.\s+(.+?)$")) {
        $rules += [PSCustomObject]@{
            id = "Section " + $m.Groups[1].Value
            title = $m.Groups[2].Value.Trim()
            source = "PROFILE.md Section 7"
        }
    }
}
$rules | ConvertTo-Json -Depth 5 -Compress |
    Out-File (Join-Path $indexDir "rules.json") -Encoding utf8 -NoNewline
Write-Host "      $($rules.Count) R-rules / failure patterns" -ForegroundColor Gray

# ===========================================
# 5b. prs.json - ~/.kb/prs/*.json (PR 一覧)
# ===========================================
Write-Host "[5b/7] Collecting PRs..." -ForegroundColor Cyan
$prs = @()
if (Test-Path "$KbRoot\prs") {
    Get-ChildItem -Path "$KbRoot\prs" -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
        $repoName = $_.BaseName
        try {
            $arr = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            foreach ($pr in $arr) {
                $prs += [PSCustomObject]@{
                    repo   = $repoName
                    number = $pr.number
                    title  = $pr.title
                    state  = $pr.state
                    url    = $pr.url
                    updated = $pr.updatedAt
                    isDraft = $pr.isDraft
                }
            }
        } catch { }
    }
}
$prs = $prs | Sort-Object -Property updated -Descending | Select-Object -First 200
$prs | ConvertTo-Json -Depth 5 -Compress |
    Out-File (Join-Path $indexDir "prs.json") -Encoding utf8 -NoNewline
Write-Host "      $($prs.Count) PRs (top 200 by updated)" -ForegroundColor Gray

# ===========================================
# 5. issues.json - OPEN 100 + CLOSED 100 (agora#82 status:done knowledge 保持)
# ===========================================
Write-Host "[5/7] Collecting issues (open + closed)..." -ForegroundColor Cyan
$openIssues = @()
$closedIssues = @()
if (Test-Path "$KbRoot\issues") {
    Get-ChildItem -Path "$KbRoot\issues" -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object {
        $repoName = $_.BaseName
        try {
            $arr = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            foreach ($iss in $arr) {
                $obj = [PSCustomObject]@{
                    repo   = $repoName
                    number = $iss.number
                    title  = $iss.title
                    labels = @($iss.labels | ForEach-Object { $_.name })
                    state  = $iss.state
                    url    = $iss.url
                    updated = $iss.updatedAt
                    closed_at = $iss.closedAt
                }
                $st = $iss.state.ToString().ToUpper()
                if ($st -eq "OPEN") {
                    $openIssues += $obj
                } elseif ($st -eq "CLOSED") {
                    $closedIssues += $obj
                }
            }
        } catch { }
    }
}
$openIssues = $openIssues | Sort-Object -Property updated -Descending | Select-Object -First 100
$closedIssues = $closedIssues | Sort-Object -Property updated -Descending | Select-Object -First 100
$allIssues = $openIssues + $closedIssues
$allIssues | ConvertTo-Json -Depth 5 -Compress |
    Out-File (Join-Path $indexDir "issues.json") -Encoding utf8 -NoNewline
Write-Host "      $($openIssues.Count) open + $($closedIssues.Count) closed (each top 100 by updated)" -ForegroundColor Gray

# ===========================================
# 6. graph.json - Cytoscape.js elements (共起 graph)
# ===========================================
Write-Host "[6/6] Building co-occurrence graph..." -ForegroundColor Cyan
$nodes = @()
$edges = @()
$nodeIds = @{}

# tag ノード
foreach ($t in $tagArr) {
    $id = "tag:" + $t.tag
    $nodes += @{ data = @{ id = $id; label = "#" + $t.tag; type = "tag"; weight = $t.count } }
    $nodeIds[$id] = $true
}
# file ノード (上位 200 個まで、tag 数で sort)
$topFiles = $mdFiles | Sort-Object { $_.tags.Count } -Descending | Select-Object -First 200
foreach ($f in $topFiles) {
    $id = "file:" + $f.path
    $nodes += @{ data = @{ id = $id; label = $f.title; type = "file"; visibility = $f.visibility; path = $f.path } }
    $nodeIds[$id] = $true
    # file → tag エッジ
    foreach ($t in $f.tags) {
        $tagId = "tag:" + $t
        if ($nodeIds.ContainsKey($tagId)) {
            $edges += @{ data = @{ source = $id; target = $tagId } }
        }
    }
}

$graph = @{
    nodes = $nodes
    edges = $edges
    meta = @{
        generated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssK")
        nodeCount = $nodes.Count
        edgeCount = $edges.Count
    }
}
$graph | ConvertTo-Json -Depth 10 -Compress |
    Out-File (Join-Path $indexDir "graph.json") -Encoding utf8 -NoNewline
Write-Host "      $($nodes.Count) nodes, $($edges.Count) edges" -ForegroundColor Gray

# ===========================================
# Summary
# ===========================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Index build complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
$totalBytes = (Get-ChildItem $indexDir -File | Measure-Object Length -Sum).Sum
Write-Host ("  Total size:  {0:N1} KB" -f ($totalBytes / 1KB))
Write-Host "  Files:       $($mdFiles.Count)"
Write-Host "  Hashtags:    $($tagArr.Count)"
Write-Host "  Skills:      $($skills.Count)"
Write-Host "  R-rules:     $($rules.Count)"
Write-Host "  Issues:      $($issues.Count)"
Write-Host "  Graph:       $($nodes.Count) nodes / $($edges.Count) edges"
Write-Host ""
Write-Host "Next: open $PortalRoot\99-portal-ui\index.html in browser" -ForegroundColor Yellow
