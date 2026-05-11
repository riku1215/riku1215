# 次セッション kickoff — Phase 1.5「活かす」スタート

`#next-session #phase-1-5 #kickoff #captain-action`

> 本セッション 14h+ 自走完了 → PR #19 (~15,300 行 / 41 commits) master merged → 次セッション準備。

## 0. 直前完了 (本セッション末)

- PR #19 → master merged (commit `2b7d108`、2026-05-11)
- 全 41 commits history 保持 (merge method = merge)
- agoora 完成形 v1.5 確定

## 1. 次セッション開始時 Captain Windows 手順 (10 分)

### Step 1: master 最新化

```powershell
cd $env:USERPROFILE\riku1215
git checkout master
git pull origin master
git log --oneline -5
```

### Step 2: agoora UI 動作確認

```powershell
.\4-portal\build-indexes.ps1
cd 4-portal
pip install fastapi "uvicorn[standard]" chromadb pyyaml requests
python portal-api.py
# → http://127.0.0.1:8765/
```

ブラウザで 8 tab 表示確認、`/` キー検索 focus、`g i` で Issues。

### Step 3: agoora-vscode 拡張 build (任意)

```powershell
cd 5-product\agoora-vscode
npm install
npm run compile
# F5 で Extension Development Host
```

### Step 4: Live tab SSE 確認

```powershell
python scripts\status-broadcaster.py --agent researcher --status running --task "kintaeru Phase 1"
python scripts\status-broadcaster.py --commit-now
```

## 2. kintaeru Phase 1.5d-1 dogfooding

```powershell
cd $env:USERPROFILE\.kb\repos
gh repo clone riku1215/kintaeru
gh issue list -R riku1215/kintaeru --state all --limit 20
```

試行 task 8 step (researcher → architect → critic → coder → structural-analyzer → impact-analyst → reviewer → historian → orchestrator)。

KPI:
- 1 セッション完了 Issue: 1-3 件
- agoora 経由/手動: 0.5x
- agoora 弱点: ≥ 5

## 3. 3 LLM レビュー配布

`agoora-kickoff/10-llm-review-disruptive-i1-i5.md` の 3 packets を Captain がコピペで配布。

## 4. agora#83 起票

```powershell
gh issue create -R riku1215/agora `
  --title "[doctrine] R83-R88 + 5 hygiene + DSI integration" `
  --body-file 4-portal\agoora-kickoff\08-agora-83-issue-draft.md
```

## 5. agoora repo (work/agoora) sync

rsync で 4-portal / 1-knowledge / 3-rules / scripts / 5-product 同期。

## 6. 次セッション最初の Claude action items

1. ★★★★★ agora#4 fetch (Section 7-2 違反防止)
2. ★★★★★ 本 doc 読込
3. ★★★★★ kintaeru researcher tenfold-rd で 5 Issue 候補生成
4. ★★★★ Captain Windows 動作確認結果を historian で記録
5. ★★★★ I1-I5 + counterfactual dogfooding 実走
6. ★★★ agoora repo sync (work/agoora)

## 7. 引継メモ (200 字、R57)

agoora は Phase 1 完成形 v1.5 (PR #19 merged、~15,300 行 / 41 commits)。
本 thesis (Skills baton × hashtag × failure-driven) + 5 disruptive 機構 +
counterfactual skill + LLM dispatch protocol が全 commit に integrated 済。
次は kintaeru で実走、agoora の真価を実証検証するフェーズ。
Captain 確定の dual-track style を継続。

## 8. 関連

- PR #19 (merged): https://github.com/riku1215/riku1215/pull/19
- master commit 2b7d108
- 4-portal/agoora-kickoff/09-3h-autonomous-report-part2.md
- 1-knowledge/agoora-dogfooding-candidates.md
- 1-knowledge/llm-dispatch-protocol.md
- 1-knowledge/skill-baton-hashtag-thesis.md

`#next-session #phase-1-5 #kickoff #post-merge`
