---
tags: [vscode, cost-reduction, dsi-integration, agoora, captain-economics]
layer: business
audience: [captain-only, claude]
status: active
created: 2026-05-11
---

# VS Code 一本化 + dsi-wizard 機能取込 — 月額経費削減効果

`#vscode #cost-reduction #dsi-integration #agoora`

## 0. Captain 指示の本質

> **dsi-wizard は agoora の VS Code 拡張版に他ならない**
> → この機能も取り込むべき → VS Code 利用で**経費削減効果**が見込まれる

= **agoora-vscode に dsi-wizard 全機能 (F1-F7 + tenfold-rd) を統合**
= **VS Code + Claude Code + agoora-vscode の 3 点セットで他サブスク不要**

## 1. 統合後の agoora-vscode 機能 (10 commands)

### Core (4)
- `agoora.search` — knowledge 横断検索
- `agoora.openPortal` — Web UI を開く
- `agoora.runRoute` — routing.yml dispatch
- `agoora.autoLabel` — Issue 自動 label

### DSI integration ★ 新 (6、dsi-wizard 機能取り込み)
- `agoora.newDsiWorkspace` (F1+F2) — 業界 × 言語 × 規模 QuickPick
- `agoora.previewPreset` (F3) — 配置プレビュー
- `agoora.applyDsi` (F4) — Mixer CLI 呼出
- `agoora.editYaml` (F5) — `*.dsi.yaml` 編集
- `agoora.checkDsiVersion` (F6) — バージョン管理
- `agoora.tenfoldRd` (dsi-wizard#13) — 10 通り R&D wizard

## 2. 月額経費削減 (定量化)

### Before (現状想定)
| サービス | 月額 | 用途 |
|---------|------|------|
| Claude Pro/Max | ¥3,000 / ¥20,000 | Claude Code |
| Cursor | $20 (¥3,000) | AI 補完 IDE |
| ChatGPT Plus | $20 (¥3,000) | technical-detail relay |
| Copilot | $10 (¥1,500) | inline 補完 |
| (Captain 既知の月額固定費) | ¥152,734 | 他 |
| **合計** | **~¥160,000-170,000** | |

### After (VS Code 一本化)
| サービス | 月額 | 用途 |
|---------|------|------|
| Claude Pro/Max | ¥3,000-20,000 | **VS Code 内 Claude Code** で完結 |
| Cursor | ¥0 | **不要** (Claude Code + agoora-vscode で代替) |
| ChatGPT Plus | ¥0 | **不要** (Captain 経由 LLM relay で問題ない頻度) |
| Copilot | ¥0-1,500 | optional |
| 他既知固定費 | ¥152,734 | 維持 (削減は別案件) |
| **合計** | **~¥155,000-175,000** | |

### 削減効果
- **月額**: ¥4,500-6,000 削減 (Cursor + ChatGPT Plus 解約)
- **年額**: ¥54,000-72,000 削減
- ※ 既に解約済の LOPITAL ¥9,000/月 + 計画中の GCP 整理 ¥10,000/月 と合わせて、**累計年 ¥282,000-348,000** の削減 path

## 3. なぜ VS Code 一本化が成立するか

### Claude Code (VS Code 拡張) の機能カバー範囲
- ✅ AI 補完 (Cursor 代替)
- ✅ chat (ChatGPT 代替)
- ✅ multi-file edit
- ✅ MCP 連携 (agoora portal-api 統合可)
- ✅ Skills 47 個利用可

### agoora-vscode 追加機能で完成
- ✅ knowledge 横断検索 (46 repo + 1000 Issue)
- ✅ routing.yml dispatch (agent 自動選択)
- ✅ DSI 配置 (dsi-wizard 機能取り込み)
- ✅ Auto-label (Phase 1.5a)
- ✅ tenfold-rd wizard (R&D 自動生成)

### 残るのは Captain LLM 経由 relay
- Gemini (戦略判断): ask-gemini.sh で API 直呼出 (本セッション既実装)
- Grok (リアルタイム): Captain 経由 (月 $25 一括購入で常用可)
- ChatGPT: 必要時のみ (Plus 解約、無料枠で十分か pay-as-you-go)

## 4. 段階移行計画

### Phase A (即時): Cursor / Copilot 試用停止
- VS Code + Claude Code のみで 1 週間運用試行
- 不便なら次 phase で復活

### Phase B (1 ヶ月後): ChatGPT Plus 解約評価
- agoora.tenfoldRd / routing.yml で technical-detail カバー率測定
- Captain relay 頻度が許容範囲なら解約

### Phase C (3 ヶ月後): agoora-vscode Marketplace 公開
- 他個人開発者向け SaaS としても提供開始
- Phase 5 商用化への布石

## 5. 反論余地 (R8)

1. **Cursor の AI 補完精度が Claude Code を上回る場合**
   → 反論: 2026 年時点で Claude Sonnet 4.x / Opus 4.x の補完精度はトップクラス、Cursor 独自利点減少
2. **ChatGPT Plus は GPT-5 + DALL-E 等の付加価値あり**
   → 反論: 開発主目的なら不要、画像生成は Gemini で代替可
3. **VS Code 拡張化で開発工数増加**
   → 反論: dsi-wizard scaffold 流用、agoora-vscode 既に scaffold + DSI integration 完了 (本 commit)

## 6. 関連

- `5-product/agoora-vscode/` (本 commit で DSI integration 追加)
- `1-knowledge/dsi-ecosystem-integration.md`
- `1-knowledge/skills-strategy-integration.md` (Instructions > Skills、年 ¥330k 削減と統合)
- PROFILE.md Section 6 (月額ランニング ¥152,734、改善余地)

## 7. Captain 次セッション action

1. ★★★★★ VS Code + Claude Code 一本化 1 週間試行
2. ★★★★ Cursor 試用停止 (もし契約中)
3. ★★★ ChatGPT Plus 利用頻度測定 (1 ヶ月後解約判断)
4. ★★★ agoora-vscode 動作確認 (npm install → F5 デバッグ)

`#vscode #cost-reduction #captain-economics #agoora`
