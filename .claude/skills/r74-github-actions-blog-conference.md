---
name: r74-github-actions-blog-conference
description: GitHub Actions + 公式 Blog + カンファレンス情報 自動 sweep (= 28+ repo eco の 外向き 知見 蒐集)
type: r-rule
version: 1.0.0
source: agora#4 R74 (R73 Phase 2.2 Skill 化、 2026-05-07 制定)
related-rules: [R32, R35, R55, R62, R66, R67, R73]
---

# R74: GitHub Actions + Blog + Conference sweep

## 3 軸

### 軸 1: Cross-repo Issue Sweep (= 内 R62 連動)
- `agora/.github/workflows/cross-repo-issue-sweep.yml`
- cron 6 時起点 + workflow_dispatch
- 14 repo (Tier S/A) sweep → agora#73 自動 paste
- ⚠ cross-repo = `CROSS_REPO_PAT` secret 必要 (= 既 PoC 立証)

### 軸 2: GitHub Blog Weekly Digest
- 月曜 6 時 cron
- `https://github.blog/feed/` → ChatGPT digest → agora#4 paste

### 軸 3: Conference 情報 sweep
- GitHub Universe / OSS Summit / KubeCon / Devsumi / JTF / AWS re:Invent / Google I/O
- CFP 締切 + 新技術 trend + LT 投稿 path

## 連動 R-rule

R32 (Proactive Info Gathering) / R35 (Stuck Issue Patrol) / R55 (全 LLM) / R62 (時間トリガー 統計) / R66 (md→Issue) / R67 (Chrome 可視化) / R73 (Skill 化)
