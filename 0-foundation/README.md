---
tags: [foundation, doctor, prerequisites, environment]
layer: foundation
audience: [captain-only, claude]
status: active
---

# Layer 0: Foundation

`#foundation #doctor #prerequisites`

**役割**: 環境準備層 — Captain Portal の基盤となる前提条件をチェック・整備

## 含まれるもの

| ファイル | 役割 |
|---------|------|
| `doctor.ps1` | Windows 環境前提チェック (gh/git/rg/jq/Python/Ollama) |
| `doctor.sh` | Linux/macOS 環境前提チェック |

## 使い方

```powershell
# Windows
.\doctor.ps1
```

```bash
# Linux / macOS / WSL
./doctor.sh
```

## 次の層

→ `1-knowledge/` (データ層、setup.ps1 で 46 repo クローン)
