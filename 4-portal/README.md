---
tags: [portal, captain-portal, level-3, navigation]
layer: portal
audience: [captain-only, claude]
status: active
---

# Layer 4: Portal — Captain Portal Level 3 構築

`#captain-portal #level-3 #navigation`

**役割**: Captain 専用ナレッジハブ構築 — C ドライブ全体を巨大階層リポジトリ化。

## 含まれるもの

| ファイル | 役割 |
|---------|------|
| `portal-config.yml` | 階層構造定義 (single source of truth) |
| `portal-init.ps1` | Captain Windows で実行、Portal を `%USERPROFILE%\Portal\` に構築 |
| `README.md` | 本ファイル |

## 構築フロー

```powershell
# 1. 最新取得
cd $env:USERPROFILE\riku1215
git pull origin master

# 2. Portal 構築 (dry run で確認)
.\4-portal\portal-init.ps1 -DryRun

# 3. 問題なければ本実行
.\4-portal\portal-init.ps1

# 4. Claude 起動 (CLAUDE.md auto-load)
cd $env:USERPROFILE\Portal
claude
```

## 生成される構造

```
C:\Users\m\Portal\
├── INDEX.md, CLAUDE.md
├── 1-domains\
│   ├── ai-development\ (frameworks/models/skills/projects/research)
│   ├── web-development\ (frameworks/deployment/styling/projects)
│   ├── data-engineering\ (databases/vector/pipelines/analytics)
│   ├── devops\ (ci-cd/monitoring/infrastructure/security)
│   └── business\ (strategy/proposals/audit/billing)
├── 2-skills\         → ~/.agents/skills/ symlink (47 skills)
├── 3-rules\          # R-rules + Section 7
├── 4-find-skills\
├── 5-knowledge-base\ → ~/.kb/ symlink
├── 6-meta\           → ~/riku1215/ symlink
└── 99-portal-ui\     # Astro UI (Phase 2)
```

## Phase 構成

| Phase | 内容 | 状態 |
|-------|------|------|
| **Phase 1 (本 PR)** | 骨格生成 (ディレクトリ + 雛形 md + symlink) | ✓ 実装済 |
| Phase 2 | Astro Web UI (`99-portal-ui\`、quard-web-jp 参考) | 計画中 |
| Phase 3 | 検索 UI (ripgrep + Phase D vector) 統合 | 計画中 |
| Phase 4 | ダッシュボード | 計画中 |
| Phase 5 | QUARD SaaS 商用化 | Level 5 |
