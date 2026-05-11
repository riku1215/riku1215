---
tags: [portal, captain-portal, level-3, navigation]
layer: portal
audience: [captain-only, claude]
status: active
---

# Layer 4: Portal — `agoora` (Captain's knowledge hub)

`#agoora #captain-portal #level-3 #navigation`

> **agoora** — 個人開発者の知識の集まる場。46 repo + 1000+ Issue + 47 skills + R-rules を GitHub と同じ操作感で横断検索できるローカルナレッジハブ。

| 用途 | URL / 場所 |
|------|------------|
| **本体 (Captain ローカル)** | `%USERPROFILE%\Portal\99-portal-ui\index.html` |
| **デモ版 (公開)** | https://agora.quard-web.jp (Phase 5 計画中) |
| **将来 SaaS 本サイト** | https://agoora.jp (Phase 5 商用化、ドメイン確保済) |

**役割**: C ドライブ全体を巨大階層リポジトリ化、GitHub IA を完全再現したローカル UI を提供。

## 含まれるもの

### 骨格生成 (Phase 1 step 1)
| ファイル | 役割 |
|---------|------|
| `portal-config.yml` | 階層構造定義 (single source of truth) |
| `portal-init.ps1` | Captain Windows で実行、Portal を `%USERPROFILE%\Portal\` に構築 |
| `README.md` | 本ファイル |

### ハーネス核 (Phase 1 step 2、Issue #18 / PR #19)
| ファイル | 役割 |
|---------|------|
| `agents.yml` | 7 役定義 (architect/researcher/coder/reviewer/critic/historian/orchestrator) × LLM × skills × knowledge スコープ |
| `routing.yml` | 階層分岐 decision tree (Dify 代替の核心) |
| `protocol.md` | R-rules 結合 + 効果測定基準 |
| `route.sh` | dispatcher (bash, Linux/macOS) |
| `route.ps1` | dispatcher (PowerShell, Windows) |

## ハーネス使い方 (Windows)

```powershell
# タスク分岐確認
.\4-portal\route.ps1 -DryRun "pet-care-app PR #52 の CI 失敗を直して"
# → Matched: bug-fix
# → Pipeline: orchestrator -> researcher -> coder -> reviewer -> historian -> orchestrator

.\4-portal\route.ps1 -DryRun "Phase 2 で hi-spec マシン買うべき?"
# → Matched: strategy-decision

.\4-portal\route.ps1 -DryRun "@critic この設計どう思う?"
# → Matched: explicit-mention

# 明示ルール指定
.\4-portal\route.ps1 -Rule new-feature "..."

# ログ記録 (~/.kb/routing.log)
.\4-portal\route.ps1 "..."
```

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
