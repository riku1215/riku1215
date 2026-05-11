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

export function activate(context: vscode.ExtensionContext) {
  console.log("agoora VS Code Extension activated");

  context.subscriptions.push(
    vscode.commands.registerCommand("agoora.search", cmdSearch),
    vscode.commands.registerCommand("agoora.openPortal", cmdOpenPortal),
    vscode.commands.registerCommand("agoora.runRoute", cmdRunRoute),
    vscode.commands.registerCommand("agoora.autoLabel", cmdAutoLabel),
  );

  vscode.window.setStatusBarMessage("$(rocket) agoora ready", 3000);
}

export function deactivate() {
  // noop
}
