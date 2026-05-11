# agoora-vscode — VS Code Extension (Phase 5 prep)

`#agoora #vscode-extension #dsi-wizard-pair #phase-5`

> agoora を **VS Code 内から直接利用**するための拡張。
> dsi-wizard と**同 IDE 内で連携**可能、Captain の主開発環境を強化。

## 4 Commands

| Command | 機能 |
|---------|------|
| `agoora: Search knowledge` | 検索 QuickPick (役割別 retrieval policy 適用) |
| `agoora: Open web portal in browser` | http://127.0.0.1:8765/ を開く |
| `agoora: Dispatch task via routing.yml` | タスク → pipeline 分岐提案 |
| `agoora: Auto-label current Issue` | scripts/auto-label.py 呼出 (Phase 1.5a) |

## 設定 (settings.json)

```json
{
  "agoora.portalApiUrl": "http://127.0.0.1:8765",
  "agoora.defaultRole": "researcher",
  "agoora.kbRoot": "${env:USERPROFILE}/.kb"
}
```

## 開発・ビルド (Captain Windows)

```powershell
cd $env:USERPROFILE\work\agoora\5-product\agoora-vscode
npm install
npm run compile
npm run package    # → agoora-vscode-0.1.0.vsix
```

### ローカルインストール
```powershell
code --install-extension agoora-vscode-0.1.0.vsix
```

### F5 デバッグ
`code .` → F5 で Extension Development Host 起動。

## dsi-wizard との関係

| 観点 | dsi-wizard | agoora-vscode |
|------|-----------|--------------|
| 目的 | プロジェクトに DSI 配置 | knowledge 横断検索 + ハーネス操作 |
| Mixer 統合 | Yes (本体機能) | Phase 2 (portal-api `/dsi/apply`) |
| 役割 | 配置 (write) | 検索 (read) + dispatch |
| インストール先 | 任意 | Captain 個人 |

→ **2 拡張を同時 install** で setup + 運用が IDE 完結。

## Phase 計画

| Phase | 内容 |
|-------|------|
| **5.0** | 本 scaffolding (現在) |
| 5.1 | npm install + vsce package で動作確認 |
| 5.2 | VS Code Marketplace 公開 |
| 5.3 | Mixer CLI 統合 (`agoora: New DSI Workspace`) |
| 5.4 | dsi-wizard 公式連携 (cross-extension messaging) |

## 関連

- `4-portal/agents.yml` (10 役、本拡張が呼出)
- `4-portal/routing.yml` (cmdRunRoute がローカル実装)
- `4-portal/portal-api.py` (本拡張の通信相手)
- `scripts/auto-label.py` (cmdAutoLabel が呼出)
- `1-knowledge/dsi-ecosystem-integration.md` (戦略的位置付け)
- dsi-wizard repo (本拡張の sister product)

## License

MIT (agoora repo 全体と同)
