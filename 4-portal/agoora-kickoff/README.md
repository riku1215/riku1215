# agoora-kickoff/ — 起点 Issue 投稿用素材

> `riku1215/agoora` リポに **#1 起点 Issue + 6 comments** を投稿するための markdown 一式。
> 本ディレクトリのファイルを Captain Windows から `gh CLI` で順次投稿。

## ファイル構成

| ファイル | 用途 | 行数目安 |
|---------|------|---------|
| `00-issue-body.md` | Issue #1 本文 (概要 + 経緯 + ロードマップ) | ~210 |
| `01-grok-prior-art.md` | コメント 1: Grok 90 日 X/Reddit 5 事例 | ~100 |
| `02-gemini-design.md` | コメント 2: Gemini 3 大設計要素 | ~110 |
| `03-chatgpt-retrieval.md` | コメント 3: ChatGPT retrieval policy + agent_profiles.yaml | ~130 |
| `04-naming-and-branding.md` | コメント 4: 命名検討 + dual-track | ~80 |
| `05-ui-evolution.md` | コメント 5: UI 進化 (Many-Worlds → GitHub IA) | ~120 |
| `06-implementation-summary.md` | コメント 6: PR #19 内訳 + 次タスク | ~140 |

## 投稿手順 (Captain Windows)

### Step 1: 最新を pull

```powershell
cd $env:USERPROFILE\riku1215
git pull origin claude/claude-app-recovery-options-KIAig
```

### Step 2: Issue #1 を起点 markdown で作成

```powershell
gh issue create -R riku1215/agoora `
  --title "agoora — 起点 Issue (Phase 1 完成 + 経緯 + ロードマップ)" `
  --body-file $env:USERPROFILE\riku1215\4-portal\agoora-kickoff\00-issue-body.md
```

→ 出力に Issue URL (例: `https://github.com/riku1215/agoora/issues/1`)。
番号 (`1`) を覚えて次へ。

### Step 3: コメント 6 件を順次投稿

```powershell
$N = 1   # 上で取得した Issue 番号
$KICKOFF = "$env:USERPROFILE\riku1215\4-portal\agoora-kickoff"

gh issue comment $N -R riku1215/agoora --body-file "$KICKOFF\01-grok-prior-art.md"
gh issue comment $N -R riku1215/agoora --body-file "$KICKOFF\02-gemini-design.md"
gh issue comment $N -R riku1215/agoora --body-file "$KICKOFF\03-chatgpt-retrieval.md"
gh issue comment $N -R riku1215/agoora --body-file "$KICKOFF\04-naming-and-branding.md"
gh issue comment $N -R riku1215/agoora --body-file "$KICKOFF\05-ui-evolution.md"
gh issue comment $N -R riku1215/agoora --body-file "$KICKOFF\06-implementation-summary.md"
```

### Step 4: ブラウザで確認

```powershell
gh issue view $N -R riku1215/agoora --web
```

## 設計意図

| ファイル | 設計意図 |
|---------|---------|
| 00 | **「最初に読めば全部わかる」** 起点 Issue。経緯 + 機能 + Phase 構成 |
| 01-03 | **R14 多 LLM レビュー 3 サイクル**の知見保存 (Grok / Gemini / ChatGPT) |
| 04 | **命名根拠** = 後日「なぜ agoora?」と聞かれた時の即答資料 |
| 05 | **UI 進化** = 設計判断の脈絡 (Many-Worlds → GitHub IA 切替の理由) |
| 06 | **完成形 + 次タスク** = 引継ぎ + 計画書 |

→ Issue を読むだけで新参 Claude / Gemini / 他 LLM が **キャッチアップ完了**できる構造。

## 関連 Issue (riku1215/riku1215)

本 kickoff Issue の親 Issue:
- [riku1215/riku1215#18](https://github.com/riku1215/riku1215/issues/18) — Phase 1 戦略総括
- [riku1215/riku1215 PR#19](https://github.com/riku1215/riku1215/pull/19) — 実装本体

`#agoora #kickoff #r14 #setup`
