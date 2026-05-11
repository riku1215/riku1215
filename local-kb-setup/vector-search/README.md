# Phase D: Vector Search Extension

`ripgrep` の全文一致では拾えない「**意味的に近い**」Issue 検索を実現する。

## なぜ必要か

| 入力例 | ripgrep | ベクトル検索 |
|--------|---------|--------------|
| "会員アカウント乗せ替え" | 0件 (該当語なし) | **sakura 会員間移行** が hit |
| "AIが暴走する" | 0件 | **Codex使用上限 / Claude消失** 関連 hit |
| "金が無駄に出てる" | 0件 | **LOPITAL月¥9k / GCP二重** 関連 hit |

## 前提

- Phase A 完了 (`$env:USERPROFILE\.kb\` に repos/ + issues/ がある)
- **Python 3.11+** (`winget install Python.Python.3.12`)
- **Ollama** (https://ollama.com/download)
- Ollama でモデルDL: `ollama pull nomic-embed-text`

## セットアップ (10 分)

```powershell
cd $env:USERPROFILE\local-kb-setup\vector-search
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## 使い方

### 1. 初回インデックス作成 (10〜30 分)

```powershell
python index.py
```

→ `$env:USERPROFILE\.kb\chroma_db\` に永続化。1000 issue で約 200-500 MB。

### 2. 増分更新 (毎日 1〜2 分)

`update.ps1` の最後に `python update.py` を追加するか、Task Scheduler で別途登録。

### 3. CLI 検索

```powershell
python ask.py "会員アカウント乗せ替え"
python ask.py "AIが暴走する" 10  # top 10 (default 8)
```

### 4. Claude Code 連携 (MCP server 経由)

```powershell
# サーバ起動 (常駐 or systemd 風)
python mcp_server.py
```

Claude Code 側設定 (`~/.claude/mcp.json` 等):

```json
{
  "mcpServers": {
    "kb-search": {
      "command": "python",
      "args": ["C:\\Users\\m\\riku1215\\local-kb-setup\\vector-search\\mcp_server.py"]
    }
  }
}
```

→ Claude Code 内で **`search_kb("...")` ツール**として呼出可能に。

## トラブルシューティング

| 症状 | 対処 |
|------|------|
| Ollama API 接続エラー | `ollama serve` が起動しているか確認 |
| Python パッケージ失敗 | VS Build Tools 要、または `pip install --upgrade pip` |
| 検索結果がいまいち | `index.py` 再実行で embedding 再構築 |
| MCP server が認識されない | Claude Code 再起動、`mcp.json` JSON 構文確認 |

## ストレージ消費

| 項目 | 容量 |
|------|------|
| ChromaDB (1000 issue) | 200-500 MB |
| nomic-embed-text モデル | 270 MB |
| Python venv | ~500 MB |
| **合計** | **約 1-1.5 GB** |
