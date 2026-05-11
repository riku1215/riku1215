---
tags: [agoora, migration, captain-portal, planning, repo-split]
layer: portal
audience: [captain-only, claude]
status: planning
created: 2026-05-11
---

# `riku1215/agoora` repo 移行プラン

`#agoora #migration #repo-split #phase-5`

## 背景

2026-05-11 Captain 決定:
- **agoora** = 本プロダクト名 (repo 名にも採用)
- **agoora.jp** = 商用 SaaS 本サイト (空き、取得予定)
- **agora.quard-web.jp** = 公開デモ (集客導線、QUARD 既存ブランド継承)
- 現状: `riku1215/riku1215` 配下 `4-portal/` で開発中

## 移行戦略 ★ 推奨度付き

### 案 A (★★★★★): 段階的分離
1. **Phase 1 (現状継続)**: `riku1215/riku1215` で開発、PR #19 完成
2. **Phase 2 移行**: 新 repo `riku1215/agoora` 作成、`4-portal/` + 関連を移管
3. **Phase 3 公開**: `agoora` を public 化、agora.quard-web.jp で deploy

### 案 B (★★★): 即時分離
- 今すぐ `riku1215/agoora` 作成、PR #19 のコードを丸ごと初期 commit
- 短所: PR #19 のレビュー履歴が失われる

### 案 C (★★): mono-repo 維持
- riku1215/riku1215 内に `agoora/` ディレクトリ
- 短所: 公開時に sensitive 情報の選別が必要

## 採用: 案 A 段階的分離

### Phase 1 (現セッションで完了)
- ✓ `4-portal/` を agoora ブランドにリブランド (本 PR #19 で完了)
- ✓ `portal-config.yml` に `product:` セクション追加
- ✓ UI 全箇所 agoora 表示
- ✓ 本 MIGRATION 計画ドキュメント配置

### Phase 2 (Captain が claude.ai で実施)

```powershell
# 1. 新 repo 作成 (GitHub UI or gh CLI)
gh repo create riku1215/agoora --private --description "agoora — 個人開発者の知識の集まる場 (Captain's knowledge hub)"

# 2. ローカルで作業ディレクトリ準備
cd $env:USERPROFILE\work
git clone https://github.com/riku1215/agoora.git
cd agoora

# 3. riku1215/riku1215 から移管対象ファイルをコピー
$src = "$env:USERPROFILE\riku1215\4-portal"
Copy-Item -Recurse "$src\agents.yml", "$src\agent_profiles.yaml", `
                   "$src\routing.yml", "$src\protocol.md", `
                   "$src\route.sh", "$src\route.ps1", `
                   "$src\build-indexes.ps1", "$src\portal-init.ps1", `
                   "$src\portal-api.py", "$src\portal-config.yml", `
                   "$src\ui-template", "$src\README.md" .

# 4. 初期 commit
git add -A
git commit -m "init: agoora (Captain's knowledge hub) - migrated from riku1215/riku1215"
git push -u origin main
```

### Phase 3 (商用化、Phase 5 時点)

1. `agoora.jp` ドメイン取得 (空き確認済)
2. agora.quard-web.jp に static deploy (Captain Portal demo)
3. agoora.jp に SaaS 版 deploy (個人 → 法人版へ拡張、Kuuki Design 模倣)
4. GitHub repo は public へ (license: MIT or AGPL 検討)

## 移管対象ファイル一覧

| ファイル | 移管 | 残置 |
|---------|------|------|
| `4-portal/agents.yml` | ✓ agoora へ | — |
| `4-portal/agent_profiles.yaml` | ✓ | — |
| `4-portal/routing.yml` | ✓ | — |
| `4-portal/protocol.md` | ✓ | — |
| `4-portal/route.sh/.ps1` | ✓ | — |
| `4-portal/build-indexes.ps1` | ✓ | — |
| `4-portal/portal-init.ps1` | ✓ | — |
| `4-portal/portal-api.py` | ✓ | — |
| `4-portal/portal-config.yml` | ✓ | — |
| `4-portal/ui-template/` | ✓ | — |
| `4-portal/README.md` | ✓ | — |
| `PROFILE.md` | — | ✓ riku1215 残置 (個人情報) |
| `CLAUDE.md` | — | ✓ |
| `1-knowledge/*` | — | ✓ riku1215 残置 (Local KB 構築 = 個人) |
| `2-intelligence/*` | (部分) | ✓ ChromaDB は agoora 採用、ask-gemini は個人 |
| `3-interface/*` | (部分) | ✓ Streamlit UI は agoora、その他個人 |
| `0-foundation/*` | — | ✓ |

## ライセンス候補 (Phase 3)

- **MIT** ★★★★★: 採用拡散優先、商用利用 OK
- **AGPL-3.0** ★★★: SaaS 競合保護、Kuuki Design 模倣防止
- **Source-available** ★★★★: 個人 free / 商用要 license

## ブランド整合

| URL | 役割 | Phase |
|-----|------|-------|
| `agoora.jp` | SaaS 本サイト | 5 |
| `agora.quard-web.jp` | 公開デモ | 5 |
| `github.com/riku1215/agoora` | OSS repo | 2-3 |
| local `%USERPROFILE%\Portal\` | Captain ローカル | 1 (現在) |

## 関連

- PR #19: 現在の実装 PR (riku1215/riku1215 ベース)
- Issue #18: Phase 1 戦略総括
- PROFILE.md Section 8: Knowledge Base 戦略
- quard-web-jp products: 24 個、agoora をこの 25 番目として登録予定

## 次のアクション

- [ ] PR #19 を Ready for review → master merge
- [ ] Captain が gh CLI で `riku1215/agoora` repo 作成
- [ ] 移管スクリプト実行 (上記)
- [ ] PR #20 (agoora repo) で本格開発開始
- [ ] agoora.jp ドメイン取得 (Phase 5 まで予約のみ)
