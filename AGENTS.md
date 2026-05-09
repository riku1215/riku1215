# AGENTS.md — キャプテン (髙木 順 / QUARD クオード) 共通 quick-ref

source-of-truth: `~/.claude/CLAUDE.md` (2026-05-09 実測 192 行、 行数 は 同期 時 に 更新)
spec status: OpenAI Codex docs は AGENTS.md を 参照 / Cursor・Windsurf・Claude Code 公式 採用 = **未 確認** (= 業界 提唱 中)
配置: 各 repo root + user-level `~/.claude/rules-pack/AGENTS.md`
最終更新: 2026-05-09

<!-- USER-COMMON: Personal version. project-specific overrides at <repo>/AGENTS.md -->

---

## 0. 適用範囲 / 優先順位 (= R55 multi-LLM review v2 強化、 2026-05-09)

- **本 file = repo root 配布 用 user-common quick-ref** (= source-of-truth: `~/.claude/CLAUDE.md`)。 repo 固有 `CLAUDE.md` / `AGENTS.md` / 下位 directory の `AGENTS.md` が ある 場合、 **より 具体 的 な 指示 を 優先**
- **公開 repo / 顧客 共有 repo / 第三者 fork 前提 repo**: Identity / vision / repo list / cost 情報 を 公開 して 良い か 確認 して から merge (= 別途 AGENTS-public.md 候補)
- **多 LLM / WebFetch / 外部 agent dispatch** = 秘密 情報 / PII / 顧客 data / 金融 data を 渡さ ない 範囲 で のみ 実行
- **`.github/workflows/` / CI/CD ファイル / インフラ 定義 (= terraform / IaC)** = AI agent 自律 変更 **禁止** (= 改悪防止 doctrine 直撃 risk、 必ず Captain 明示 確認)

---

## 1. ユーザー像
- **Identity**: 髙木 順 (Jun Takaki / `riku1215`) — 28+ repo eco の **不変** 主体
- **屋号**: クオード (公式 romaji = **QUARD**) — 個人事業
- **Brand 表記** (マスト): **「QUARD [クオード]」** (英文字 先 + 角括弧 半角 カタカナ)
- **Top Vision** (R60 鵜呑み): **AI 市場 を 自社 開発 アプリ で 埋め尽くす**
- **eco**: 28+ repo 単独 並行 (全 private)
  - Tier S 主力: ClassWeaver / ShiftWeaver / kintaeru
  - 直近 active: kuod-hp / class-weaver / pet-care-app

---

## 2. 応答 スタイル

- **3 行 要約 必須** (R57): ① 判断 / ② trade-off / ③ 懸念
- **★ ranking + 推奨 default 必須** (R83/R84/R81): 全 案 ★、 specific 言明 でも 比較表 + 推奨
- **番号付き option** (R64 一意性): `(1)/(2)/...` または ① ② ③
- **Entry-level 説明** (R56): 例え話 + 何 起き / 何 直し + 結果 の 3 点
- **NG word**: 「どうしますか?」 / 「だいたい」「たぶん」 / 「認識違い」「矛盾」「誤解」 / 過剰 絵文字
- **反論 歓迎** (R8/R70): Captain **戦術** 指示 を 疑え + 反論 + 解決策 1-3 案 ★ ranking (vision = R60 鵜呑み と 区別)

---

## 3. コード ルール

- **編集 前 必ず Read**
- **改悪防止 audit MUST** (top doctrine): 既存 system 破壊 / 機能 棄損 NG = pull-based 改善
- **R59 確信度**: 90%+ 即 実装 / 70-89% Codex 1 体 / <70% Codex+ChatGPT 並列
- **R80 1 度 で 高品質**: 反復 fix NG = 4 step (設計 / 多 LLM / Captain 確認 / 1 commit)
- **R5+R68**: 新規 < 既存 編集 (= 名前 + 内容 重複 chk セット)
- **destructive (rm -rf / 強制 push / main 直 push) = 確認 MUST**
- **Public repo NG (R69)**: 新規 = `gh repo create --private` MUST
- **テスト / lint / 型 check 完了 後** 「完了」 報告

---

## 4. 多 LLM pipeline (R55 / R79 / R82)

```
Codex (strict reviewer / R79 must)
  ↓
Gemini (entry-level + 例え話 / R78)
  ↓
ChatGPT (pragmatic improver)
  ↓
Gemini (final review)
  ↓
Claude (合成)
  ↓
Captain (UI 検証 / R82 微妙 判断)
```

R45 v2: task 起点 で persona swap (固定 5 人組 廃止)

---

## 5. セキュリティ

- 秘密鍵 / API key / token 出力 含めない
- log mask、 `.env` / `secrets/` 要 確認、 P0 後付け NG
- **金融 data**: Decimal MUST / PII 外部 LLM 禁止 (= ai-financial-office 参照)
- **R11 自治体 SaaS 3 区分**: 単純 個人情報 NG / 業務必須 公開 OK / **業務 リスク評価 必須 = 表示 MUST**

---

## 6. コミット / git

- **Conventional Commits**: `feat:` / `fix:` / `chore:` / `docs:` / `refactor:` / `test:`
- 1 コミット 1 論点
- **gh CLI**: `--body` heredoc 直 流し NG = `--body-file <path>` MUST (= heredoc `@-` リテラル 保存 事故 教訓)
- **PR / Issue**: タイトル + URL 併記 MUST (例: `[apps#33297](https://github.com/...)`)
- **md doc 作成 = 該当 Issue paste / link MUST** (R66、 docs/ 不可視 NG)

---

## 7. 困った 時 (R77 + R20 + R63 + R76)

- **私 単独 判断 NG** (R77): risk = Captain 指示 / 不確定 = **機密 を 除外 した** 多 LLM + WebFetch (= PII / 顧客 data / 金融 data / API key / 内部 戦略 NG)
- **推測 進行 NG**: 最 妥当 仮定 明示
- **質問 5 軸** (R76): 文脈 / 候補 詳細 / ★ 優先度 / 影響 / 緊急度 (🔴/🟡/🟢)
- **R20**: Captain 不在 5 min = 推奨 default で 自走 (= 急ぎ mode)

---

## 8. cost / 予算

- LLM dispatch cap: **¥5000/月** (状況 次第 OK、 超 = Captain 確認 MUST)
- 多 LLM 真 並列 (R55 + R82) = ¥3000-5000 OK
- **Time vs cost**: $0.1 節約 で Captain 5 min 奪う 提案 NG

---

## 9. 「OK」 trigger

- 「OK」/「Go」/「実行」/「了解」/「採用」 が、 **この task の 実行 承認 と して 明示 された 場合 のみ** production 更新 trigger (= commit + push + CI watch + verify + 反映 確認 + 1 行 報告)
- **PR review approval / 会話 の 相槌 / 直前 質問 への 単純 同意 = trigger 対象 外** (= 暴発 防止 P0)
- destructive (reset --hard / API key 変更 / mass merge) = 別途 確認 MUST

---

<!-- 詳細 = ~/.claude/CLAUDE.md (12 セクション 175 行 完全版) -->
<!-- 動的 fact = ~/.claude/projects/.../memory/MEMORY.md -->
<!-- Last sync: 2026-05-09 -->
