# CLAUDE.md — profile

@PROFILE.md

Claude Code 運用ガイド。詳細は agora#4 を参照。
ユーザー属性 / 対話スタイル / Claude運用指示は `PROFILE.md` を参照 (上記 import で自動読込)。

## 🔁 セッション開始時の自動ワークフロー (riku1215 共通)

**毎セッション最初に必ず実施**:

1. **agora#4 を fetch** — global Instruction (R1〜R10) を context に焼く
   ```bash
   gh issue view 4 -R riku1215/agora 2>&1 | head -300
   ```
2. **本 repo の open issue 上位 30** を一覧
   ```bash
   gh issue list -R riku1215/profile --state open --limit 30 --json number,title --jq '.[] | "#\(.number) \(.title)"'
   ```
3. **直近 5 コミット** を確認
   ```bash
   git log --oneline -5
   ```
4. **R10 (Batched Authorization) フォーマットで作業計画提示** — user の合意を最初に一括取得

**長セッション時 (30 メッセージ超)**: agora#4 を再 fetch + 直近 5 メッセージを R1-R10 に照らして自己監査

**提案前は必ず R9 Pre-action Checklist 通過** (R1番号付き / R3トークン量 / R5user負担 / R7知識前提 / R8反論余地)

**運用ルール一覧**: agora#4 (https://github.com/riku1215/agora/issues/4)

