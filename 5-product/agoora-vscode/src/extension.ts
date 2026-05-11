/**
 * agoora VS Code Extension — entry point
 *
 * Captain's knowledge hub を VS Code 内から直接利用するための拡張。
 * dsi-wizard と同 IDE 内で動作、agoora portal-api (FastAPI) と通信。
 *
 * Commands:
 *   - agoora.search        : 検索 QuickPick (researcher 役)
 *   - agoora.openPortal    : Web portal をブラウザで開く
 *   - agoora.runRoute      : routing.yml で task pipeline 提案
 *   - agoora.autoLabel     : 現 Issue に自動 label 付与 (Phase 1.5a)
 *
 * tags: [agoora, vscode-extension, phase-5-prep, dsi-wizard-pair]
 */

import * as vscode from "vscode";

const PORTAL_API_DEFAULT = "http://127.0.0.1:8765";

interface SearchHit {
  rank: number;
  source?: string;
  score: number;
  text: string;
  chunk_hash?: string;
}

async function fetchJson<T>(url: string): Promise<T | null> {
  try {
    // Node 22+ global fetch
    const res = await fetch(url);
    if (!res.ok) {
      vscode.window.showWarningMessage(`agoora API ${res.status}: ${url}`);
      return null;
    }
    return (await res.json()) as T;
  } catch (e) {
    vscode.window.showErrorMessage(`agoora API 接続失敗: ${e}. portal-api 起動済みですか?`);
    return null;
  }
}

async function cmdSearch() {
  const config = vscode.workspace.getConfiguration("agoora");
  const apiUrl = config.get<string>("portalApiUrl", PORTAL_API_DEFAULT);
  const role = config.get<string>("defaultRole", "researcher");

  const query = await vscode.window.showInputBox({
    prompt: "agoora: knowledge search (across 46 repos + 1000+ Issues)",
    placeHolder: "例: sakura 会員間 / R32 Proactive / ChromaDB 代替",
  });
  if (!query) return;

  vscode.window.withProgress(
    {
      location: vscode.ProgressLocation.Notification,
      title: `agoora 検索中 (role: ${role})…`,
      cancellable: false,
    },
    async () => {
      const url = `${apiUrl}/search?q=${encodeURIComponent(query)}&role=${role}`;
      const data = await fetchJson<{ hits: SearchHit[] }>(url);
      if (!data || !data.hits?.length) {
        vscode.window.showInformationMessage("該当なし");
        return;
      }
      const items = data.hits.map((h) => ({
        label: `[${h.rank}] ${h.source || "(no source)"}`,
        description: `score ${h.score.toFixed(3)}`,
        detail: h.text.slice(0, 200),
      }));
      const picked = await vscode.window.showQuickPick(items, {
        title: `agoora 検索結果 — "${query}" (${data.hits.length} hits)`,
        matchOnDescription: true,
        matchOnDetail: true,
      });
      if (picked) {
        const doc = await vscode.workspace.openTextDocument({
          content: `# agoora 検索結果\n\n## クエリ\n${query}\n\n## ヒット\n\n${picked.detail}`,
          language: "markdown",
        });
        vscode.window.showTextDocument(doc);
      }
    },
  );
}

async function cmdOpenPortal() {
  const config = vscode.workspace.getConfiguration("agoora");
  const apiUrl = config.get<string>("portalApiUrl", PORTAL_API_DEFAULT);
  vscode.env.openExternal(vscode.Uri.parse(apiUrl + "/"));
}

async function cmdRunRoute() {
  const task = await vscode.window.showInputBox({
    prompt: "agoora: タスク内容 (routing.yml で pipeline 決定)",
    placeHolder: "例: pet-care-app PR#52 の CI 失敗を直して",
  });
  if (!task) return;

  // Simple rule replication of route.sh
  const lower = task.toLowerCase();
  let rule = "default";
  let pipeline = "orchestrator → researcher → architect → critic → orchestrator";

  if (/@architect|@researcher|@coder|@reviewer|@critic|@historian/.test(task)) {
    rule = "explicit-mention";
    pipeline = "orchestrator → <mentioned> → orchestrator";
  } else if (/緊急|急ぎ|urgent|asap/i.test(task)) {
    rule = "urgent-bypass";
    pipeline = "orchestrator → coder → orchestrator";
  } else if (/バグ|bug|fix|不具合|エラー|失敗|直し/i.test(task)) {
    rule = "bug-fix";
    pipeline = "orchestrator → researcher → coder → reviewer → historian → orchestrator";
  } else if (/新規|追加|作って|feature|build|create/i.test(task)) {
    rule = "new-feature";
    pipeline = "orchestrator → researcher → architect → critic → coder → reviewer → historian → orchestrator";
  } else if (/戦略|経営|方針|判断|strategy|decide|買うべき/i.test(task)) {
    rule = "strategy-decision";
    pipeline = "orchestrator → researcher → architect → critic → orchestrator";
  } else if (/影響度|blast|impact|breaking/i.test(task)) {
    rule = "impact-analysis";
    pipeline = "orchestrator → researcher → structural-analyzer → impact-analyst → orchestrator";
  }

  const msg = `🎯 agoora routing 提案\n\n入力: ${task}\nMatched rule: ${rule}\nPipeline: ${pipeline}`;
  vscode.window.showInformationMessage(msg, { modal: false });

  const doc = await vscode.workspace.openTextDocument({
    content: `# agoora 分岐結果\n\n## 入力\n${task}\n\n## 適用ルール\n\`${rule}\`\n\n## Pipeline\n${pipeline}\n\n## 詳細\n4-portal/routing.yml を参照。\nClaude (orchestrator) が本 pipeline を実行。`,
    language: "markdown",
  });
  vscode.window.showTextDocument(doc);
}

async function cmdAutoLabel() {
  const issueNumStr = await vscode.window.showInputBox({
    prompt: "agoora auto-label: Issue 番号 (現 repo 内)",
    placeHolder: "例: 1",
    validateInput: (v) => (/^\d+$/.test(v) ? null : "数値のみ"),
  });
  if (!issueNumStr) return;

  // Use VS Code terminal to run scripts/auto-label.py
  const repoFolders = vscode.workspace.workspaceFolders;
  if (!repoFolders || repoFolders.length === 0) {
    vscode.window.showErrorMessage("ワークスペースを開いてください");
    return;
  }
  const term = vscode.window.createTerminal({ name: "agoora auto-label" });
  term.show();
  // repo path detection (assumes github.com remote)
  term.sendText(`gh repo view --json nameWithOwner -q .nameWithOwner | xargs -I {} python scripts/auto-label.py --repo {} --issue ${issueNumStr} --dry-run`);
}

// =====================================================
// DSI integration (dsi-wizard 機能取り込み、2026-05-11)
// =====================================================

const INDUSTRIES = ["public", "finance", "retail", "ai-development", "web-development"];
const LANGUAGES = ["python", "typescript", "java", "go", "rust"];
const SCALES = ["S (1-3 dev)", "M (4-10 dev)", "L (10+ dev)"];

async function cmdNewDsiWorkspace() {
  // F1 + F2 統合: Command Palette + 業界 × 言語 × 規模 QuickPick
  const industry = await vscode.window.showQuickPick(INDUSTRIES, {
    title: "agoora DSI: 業界選択",
    placeHolder: "業界を選択",
  });
  if (!industry) return;

  const language = await vscode.window.showQuickPick(LANGUAGES, {
    title: `agoora DSI: ${industry} の主言語`,
    placeHolder: "言語を選択",
  });
  if (!language) return;

  const scale = await vscode.window.showQuickPick(SCALES, {
    title: `agoora DSI: ${industry}/${language} の規模`,
    placeHolder: "規模を選択",
  });
  if (!scale) return;

  const choice = await vscode.window.showInformationMessage(
    `agoora DSI: ${industry} × ${language} × ${scale}\n\n適用しますか?`,
    { modal: true },
    "Preview",
    "Apply",
    "Cancel",
  );
  if (choice === "Cancel" || !choice) return;
  if (choice === "Preview") {
    await cmdPreviewPreset(industry, language, scale);
  } else {
    await applyDsiInternal(industry, language, scale);
  }
}

async function cmdPreviewPreset(industry?: string, language?: string, scale?: string) {
  // F3: Preset 差分表示
  if (!industry || !language || !scale) {
    industry = (await vscode.window.showQuickPick(INDUSTRIES, { title: "業界" })) || undefined;
    language = (await vscode.window.showQuickPick(LANGUAGES, { title: "言語" })) || undefined;
    scale = (await vscode.window.showQuickPick(SCALES, { title: "規模" })) || undefined;
  }
  if (!industry || !language || !scale) return;

  const preview = `# agoora DSI Preset Preview

## 設定
- Industry: ${industry}
- Language: ${language}
- Scale: ${scale}

## 配置予定ファイル (Mixer CLI 互換)
- \`.claude/skills/${industry}-${language}/\` (3-5 Skills)
- \`CLAUDE.md\` (Instructions、agora#82 R-rules import)
- \`.github/copilot-instructions.md\` (Copilot 用、同内容)
- \`*.dsi.yaml\` (Mixer 設定)

## 期待効果 (skills-strategy#2 由来)
- Instructions 効果: 月 15-45h 節約
- Skills 効果: 月 ~8h 節約
- = 2-6 倍効果差

## 経費削減 (VS Code 一本化)
- Cursor サブスク: $20/月 → $0 (Claude Code + agoora-vscode で代替)
- ChatGPT Plus: $20/月 → $0 (VS Code 内 Claude Code で完結)
- 計 月 $40-60 / 年 $480-720 削減

## 実適用
\`Apply\` を選択してください。Mixer CLI 経由で配置されます (Phase 2)。
`;

  const doc = await vscode.workspace.openTextDocument({
    content: preview,
    language: "markdown",
  });
  vscode.window.showTextDocument(doc);
}

async function applyDsiInternal(industry: string, language: string, scale: string) {
  // F4: ワークスペース適用 (Mixer CLI 呼出、Phase 2 で portal-api /dsi/apply に統合予定)
  const config = vscode.workspace.getConfiguration("agoora");
  const apiUrl = config.get<string>("portalApiUrl", PORTAL_API_DEFAULT);

  const wf = vscode.workspace.workspaceFolders;
  if (!wf || wf.length === 0) {
    vscode.window.showErrorMessage("ワークスペースを開いてください");
    return;
  }
  const target = wf[0].uri.fsPath;

  const term = vscode.window.createTerminal({ name: "agoora DSI apply" });
  term.show();
  // Phase 1: dsi-kit-library Mixer 直接呼出
  // Phase 2: portal-api /dsi/apply に置換
  term.sendText(`# Phase 2 までは Mixer 直接呼出`);
  term.sendText(`# python -m dsi_kit_library.mixer --config "${language}-${scale.charAt(0).toLowerCase()}-${industry}.dsi.yaml" --target "${target}"`);
  term.sendText(`curl -X POST "${apiUrl}/dsi/apply" -H "Content-Type: application/json" -d '{"target":"${target}","industry":"${industry}","language":"${language}","scale":"${scale.charAt(0)}"}'`);

  vscode.window.showInformationMessage(`DSI 適用コマンドをターミナルに出力済 (${industry}/${language}/${scale})`);
}

async function cmdApplyDsi() {
  return cmdNewDsiWorkspace();   // alias
}

async function cmdEditYaml() {
  // F5: *.dsi.yaml 編集
  const files = await vscode.workspace.findFiles("**/*.dsi.yaml", "**/node_modules/**", 10);
  if (files.length === 0) {
    const create = await vscode.window.showInformationMessage(
      "*.dsi.yaml が見つかりません。新規作成しますか?",
      "Yes",
      "No",
    );
    if (create === "Yes") {
      await cmdNewDsiWorkspace();
    }
    return;
  }
  const picked = await vscode.window.showQuickPick(
    files.map((f) => ({ label: vscode.workspace.asRelativePath(f), uri: f })),
    { title: "Edit *.dsi.yaml" },
  );
  if (picked) {
    vscode.window.showTextDocument(picked.uri);
  }
}

async function cmdCheckDsiVersion() {
  // F6: バージョン管理 + 更新通知
  const wf = vscode.workspace.workspaceFolders;
  if (!wf || wf.length === 0) return;
  const versionFile = vscode.Uri.joinPath(wf[0].uri, ".dsi-version");
  try {
    const content = await vscode.workspace.fs.readFile(versionFile);
    const current = Buffer.from(content).toString("utf8").trim();
    vscode.window.showInformationMessage(`Current DSI version: ${current}\n最新版チェック: dsi-kit-library リリース確認推奨`);
  } catch {
    vscode.window.showWarningMessage(".dsi-version が見つかりません。DSI 未適用?");
  }
}

async function cmdTenfoldRd() {
  // dsi-wizard#13 「10 通り R&D wizard」
  const topic = await vscode.window.showInputBox({
    prompt: "agoora DSI tenfold-rd: Topic name",
    placeHolder: "例: timetable_optimization",
  });
  if (!topic) return;

  const domain = await vscode.window.showInputBox({
    prompt: "agoora DSI tenfold-rd: Domain",
    placeHolder: "例: education / scheduling",
  });
  if (!domain) return;

  const nStr = await vscode.window.showInputBox({
    prompt: "N variants (default 10)",
    value: "10",
    validateInput: (v) => (/^\d+$/.test(v) ? null : "数値のみ"),
  });
  const n = parseInt(nStr || "10", 10);

  const mStr = await vscode.window.showInputBox({
    prompt: "M cases (default 5)",
    value: "5",
    validateInput: (v) => (/^\d+$/.test(v) ? null : "数値のみ"),
  });
  const m = parseInt(mStr || "5", 10);

  const result = `# agoora tenfold-rd Wizard 結果

## 設定
- Topic: ${topic}
- Domain: ${domain}
- N variants: ${n}
- M cases: ${m}
- Citations: 5-7 (default)

## 生成予定 (実生成は portal-api /research/tenfold endpoint、Phase 2)
1. Parent Issue: \`[R&D] ${topic} — ${n} variants tenfold study\`
2. Child Issues (${n} 件):
${Array.from({ length: n }, (_, i) => `   - [R&D-${i + 1}] ${topic} variant ${i + 1}`).join("\n")}
3. Harness skeleton: \`research/${topic}/{${Array.from({ length: n }, (_, i) => `variant-${i + 1}`).join(",")}}/\`

## 出典
- dsi-wizard#13 (https://github.com/riku1215/dsi-wizard/issues/13)
- class-weaver#113 (10 combos R&D の原典)
- agora#59 (K1-K10 knowledge hub)

## 次のアクション
agoora researcher 役が本 wizard を実行 → 結果を Issue + harness 配置。
`;
  const doc = await vscode.workspace.openTextDocument({ content: result, language: "markdown" });
  vscode.window.showTextDocument(doc);
}

export function activate(context: vscode.ExtensionContext) {
  console.log("agoora VS Code Extension activated (with DSI integration)");

  context.subscriptions.push(
    // Core
    vscode.commands.registerCommand("agoora.search", cmdSearch),
    vscode.commands.registerCommand("agoora.openPortal", cmdOpenPortal),
    vscode.commands.registerCommand("agoora.runRoute", cmdRunRoute),
    vscode.commands.registerCommand("agoora.autoLabel", cmdAutoLabel),
    // DSI integration (dsi-wizard 機能取り込み)
    vscode.commands.registerCommand("agoora.newDsiWorkspace", cmdNewDsiWorkspace),
    vscode.commands.registerCommand("agoora.previewPreset", () => cmdPreviewPreset()),
    vscode.commands.registerCommand("agoora.applyDsi", cmdApplyDsi),
    vscode.commands.registerCommand("agoora.editYaml", cmdEditYaml),
    vscode.commands.registerCommand("agoora.checkDsiVersion", cmdCheckDsiVersion),
    vscode.commands.registerCommand("agoora.tenfoldRd", cmdTenfoldRd),
  );

  vscode.window.setStatusBarMessage("$(rocket) agoora ready (with DSI)", 3000);
}

export function deactivate() {
  // noop
}
