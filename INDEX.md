# riku1215 — INDEX

このリポジトリは Captain (キャプテン) のプロフィール・運用基盤を管理する**メタリポ**です。
46 repo を統括する司令塔の役割。

## アーキテクチャ図

```mermaid
flowchart TB
    subgraph "GitHub (Cloud)"
        GH_REPOS["46 リポジトリ<br/>(riku1215/*)"]
        GH_ISSUES["1000+ Issues<br/>(全 repo 横断)"]
        GH_ACTIONS["GitHub Actions<br/>(月次 snapshot 用)"]
        AGORA["agora#4<br/>(R-rules global<br/>instruction)"]
    end

    subgraph "Captain Windows PC (Cドライブ完結)"
        subgraph "C:\Users\m\.kb (Phase A)"
            LOCAL_REPOS["repos/<br/>(46 個の clone)"]
            LOCAL_ISSUES["issues/*.json<br/>(全 Issue)"]
            LOCAL_BACKUP["backups/YYYY-MM/<br/>(月次 git-bundle)"]
        end
        subgraph "Phase D"
            CHROMA["chroma_db/<br/>(ベクトル DB)"]
            MCP["mcp_server.py<br/>(意味検索)"]
        end
        CLAUDE_DESKTOP["Claude Code Desktop<br/>or CLI"]
    end

    subgraph "Claude on Web (このセッション)"
        CLAUDE_WEB["Claude Code web<br/>(scope: riku1215/riku1215)"]
        GH_MCP["GitHub MCP<br/>(scope-locked)"]
    end

    GH_REPOS -->|setup.ps1<br/>初回 clone| LOCAL_REPOS
    GH_ISSUES -->|gh issue list| LOCAL_ISSUES
    LOCAL_REPOS -->|update.ps1<br/>毎朝 09:00| LOCAL_REPOS
    LOCAL_ISSUES -->|index.py| CHROMA
    LOCAL_REPOS -->|backup.ps1<br/>月次| LOCAL_BACKUP
    GH_ACTIONS -.->|kb-snapshot<br/>月次| GH_ISSUES

    LOCAL_REPOS -->|cd ~/.kb<br/>+ ripgrep| CLAUDE_DESKTOP
    LOCAL_ISSUES -->|search_kb<br/>MCP tool| CLAUDE_DESKTOP
    CHROMA --> MCP
    MCP --> CLAUDE_DESKTOP

    CLAUDE_WEB <-->|git push<br/>commit| GH_REPOS
    GH_MCP -.->|read-only<br/>limited scope| GH_REPOS

    AGORA -.->|reference| CLAUDE_DESKTOP
    AGORA -.->|reference| CLAUDE_WEB

    classDef cloud fill:#e1f5ff,stroke:#0288d1
    classDef local fill:#fff3e0,stroke:#f57c00
    classDef vector fill:#f3e5f5,stroke:#7b1fa2
    classDef web fill:#e8f5e9,stroke:#388e3c
    class GH_REPOS,GH_ISSUES,GH_ACTIONS,AGORA cloud
    class LOCAL_REPOS,LOCAL_ISSUES,LOCAL_BACKUP,CLAUDE_DESKTOP local
    class CHROMA,MCP vector
    class CLAUDE_WEB,GH_MCP web
```

**色凡例**: 青 = GitHub クラウド / 橙 = Captain ローカル (Cドライブ) / 紫 = Phase D ベクトル / 緑 = Web Claude

## ファイル構成

| パス | 内容 | 状態 |
|------|------|------|
| `CLAUDE.md` | Claude Code セッション初期設定 (`@PROFILE.md` で import) | 稼働 |
| `PROFILE.md` | キャプテンプロフィール + R-rules + Section 7 失敗パターン + Section 8 KB戦略 | 稼働 |
| `README.md` | リポジトリ説明 (公開向け) | 稼働 |
| `work-prompts/` | plan-first mode (R71) で生成されたタスクプロンプト ×6 | 構築済 |
| `1-knowledge/` | GitHub knowledge をローカル化する Phase A-E 基盤 (PowerShell + bash) | 構築済 |
| `2-intelligence/vector-search/` | Phase D ベクトル検索 (ChromaDB + Ollama + MCP server) | 構築済 |
| `.github/workflows/` | GitHub Actions (月次 cloud backup 等) | 構築済 |

## 進行中タスク (Issues)

| # | タスク | 担当 | 削減/効果 |
|---|--------|------|----------|
| [#4](../../issues/4) | sakura quard-web.jp 会員間移行 | Captain | 二重契約解消 |
| [#5](../../issues/5) | quard-web.jp 公開 (Step 2-4) | Captain + Claude | 自社HP本稼働 |
| [#6](../../issues/6) | PayPal LOPITAL 月¥9k 解約 | Captain | **年¥108,000** |
| [#7](../../issues/7) | GCP 二重課金整理 | Captain | **年¥120,000** |
| [#8](../../issues/8) | pet-care-app PR#52 CI再実行 | Captain + Claude (要scope) | deploy 再開 |
| [#9](../../issues/9) | MCP scope 拡張 / デスクトップ移行 | Captain | 業務継続 |
| [#10](../../issues/10) | ローカル KB 構築 (Phase A) | Captain | **見落とし・手戻り根絶** |

## クイックスタート

### 新規セッション開始時 (Claude Code)

```powershell
cd C:\Users\m\riku1215
git pull
claude
# → CLAUDE.md → @PROFILE.md が自動読込
```

### ローカル KB 構築済の場合 (Phase A 完了後)

```powershell
cd $env:USERPROFILE\.kb
claude
# → 46 repo + 1000+ Issue 全体が context
```

### タスク実行 (work-prompts/)

```powershell
cat work-prompts/01-sakura-domain-migration.md
cat work-prompts/03-paypal-lopital-cancel.md
# etc...
```

## R-rules 参照

詳細は **agora#4** (private、global instruction)。本リポでは PROFILE.md Section 5/6/7/8 に運用要点。

## 2026-05-10 セッション成果サマリ

このリポへのコントリビューションは全て **PR #3** に集約:
- 屋号 QUARD 明記、46 repo 反映
- Section 7 (Claude 失敗パターン恒久化 9項目)
- work-prompts/ (6 タスク自己完結プロンプト)
- 1-knowledge/ (Phase A: クローン+検索+同期)
- 2-intelligence/vector-search/ (Phase D: 意味検索 + MCP server)

完了後、各 Issue で進捗管理。
