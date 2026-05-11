# GitHub Actions Workflows

## auto-relay.yml — agoora 1 Issue 起点完全自動リレー

**Phase 2 KPI** ([Issue #18](../../issues/18) / Gemini 提案 / protocol.md §11)

### 動作

1. Issue に label `auto-relay` を付与
2. 6 段階 agent パイプライン自動実行:
   - 🔍 researcher → 🏛 architect → ⚔ critic → 💻 coder → ✅ reviewer → 📚 historian
3. 各 agent が結果を **Issue にコメント** として投稿 (Issue-as-shared-memory)
4. 完了時 auto-relay label 自動除去 (再実行防止)

### 必要な GitHub Secrets

| Secret | 必須 | 用途 |
|--------|------|------|
| `ANTHROPIC_API_KEY` | ✓ | Claude API (全 agent) |
| `GEMINI_API_KEY` | optional | critic で R14 別 LLM 強制 (echo chamber 防止) |
| `GITHUB_TOKEN` | 自動付与 | Issue 読み書き |

### Setup (Captain Windows)

```powershell
# 1. ANTHROPIC_API_KEY 設定
gh secret set ANTHROPIC_API_KEY -R riku1215/agoora

# 2. (任意) GEMINI_API_KEY 設定 ← R14 強化推奨
gh secret set GEMINI_API_KEY -R riku1215/agoora

# 3. label `auto-relay` 作成 (色 #FF6B35)
gh label create auto-relay -R riku1215/agoora --color FF6B35 --description "1 Issue 起点自動リレー trigger"

# 4. workflow + script を agoora repo に転送
cp .github/workflows/auto-relay.yml ../work/agoora/.github/workflows/
cp scripts/auto-relay.py ../work/agoora/scripts/
cd ../work/agoora
git add .github scripts
git commit -m "feat: 1 Issue 起点自動リレー workflow + auto-relay.py"
git push
```

### 試行

```powershell
# 既存 Issue (#1 等) に label 付与で trigger
gh issue edit 1 -R riku1215/agoora --add-label auto-relay

# 進捗確認
gh run watch -R riku1215/agoora
```

### 安全策 (Safety Breakwater 適用)

- ✓ コードは**生成提案のみ** (実 patch は別 PR で Captain 承認後)
- ✓ historian が auto-relay label を実行完了時に**自動除去** (無限ループ防止)
- ✓ concurrency group で同 Issue の重複実行を queue
- ✓ critic 失敗時は Claude にフォールバック
- ✓ historian は `if: always()` で他 agent 失敗時もログ記録

### 関連

- [riku1215/riku1215 #18](../../../riku1215/issues/18) Phase 1 戦略総括
- [riku1215/riku1215 PR #19](../../../riku1215/pull/19) Phase 1 実装
- `4-portal/agents.yml` 7 役定義
- `4-portal/routing.yml` `auto-relay` ルール
- `4-portal/protocol.md` §9 Issue-as-shared-memory + §10 Safety Breakwater + §11 Phase 1 KPI
- `scripts/auto-relay.py` agent runner
