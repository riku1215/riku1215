"""agoora auto-relay agent runner

Usage:
    python auto-relay.py --role <researcher|architect|critic|coder|reviewer|historian>

Env:
    ANTHROPIC_API_KEY  (必須)
    GEMINI_API_KEY     (任意、critic で使用)
    GITHUB_TOKEN       (Issue 操作用)
    REPO               (owner/repo)
    ISSUE_NUMBER       (対象 Issue 番号)

各 agent は Issue body + 既存 comments を context として読み、
役割に応じた出力を Issue コメントとして post する。

protocol.md §9 Issue-as-shared-memory 完全実装。

tags: [agoora, auto-relay, agent-runner, phase-2]
"""

from __future__ import annotations

import argparse
import os
import sys
import json
import textwrap
from pathlib import Path
from typing import Any

import requests
from anthropic import Anthropic

ROLE_PROMPTS = {
    "researcher": {
        "system": "あなたは agoora の researcher 役 agent。役割: 過去 議論 / Issue / PR から関連情報を抽出。出力は箇条書きの related_ids + 200 字要約 + 出典明示。",
        "instruction": "以下の Issue 本文を読み、関連する過去議論を ~/.kb/ から検索したと仮定して related_ids (Issue 番号 + URL) を最大 10 件、要約 (200 字)、出典を JSON で出力。",
        "max_tokens": 1500,
    },
    "architect": {
        "system": "あなたは agoora の architect 役 agent。役割: 設計判断、A/B/C 3 案 + trade-off + ★ 推奨度 + R8 反論余地。protocol.md と PROFILE.md Section 7 を意識。",
        "instruction": "Issue 本文 + researcher コメントを踏まえ、設計案 3 件 (★ 推奨度付き)、trade-off 表、R8 反論余地 1 件以上を markdown で出力。",
        "max_tokens": 2000,
    },
    "critic": {
        "system": "あなたは agoora の critic 役 agent (Devil's Advocate)。役割: 反論最低 3 件、リスク確率 × 影響度、代替案。echo chamber 防止 (R14)。",
        "instruction": "architect 案を批判的にレビュー。反論 3 件以上、リスクマトリクス、代替案 1 件を markdown で出力。「現状で問題ない」結論は禁止。",
        "max_tokens": 1500,
        "prefer_llm": "gemini",  # architect が Claude なので critic は別 LLM
    },
    "coder": {
        "system": "あなたは agoora の coder 役 agent。役割: 実装計画 (実コードは生成せず、patch_plan + files + commands + verification 手順を提案のみ)。Safety Breakwater 適用。",
        "instruction": "architect 案 + critic 反論を踏まえ、実装計画を出力: (1) patch_plan (2) files (3) commands (4) verification。実際のコード生成は別 PR で行う。",
        "max_tokens": 1800,
    },
    "reviewer": {
        "system": "あなたは agoora の reviewer 役 agent。役割: severity 判定 (critical / warn / info)、5-gate Definition of Done (R27)、R-rule 違反検出。",
        "instruction": "coder 案を 5-gate (lint/test/type/integration/manual) で評価。severity 別に列挙、修正提案、最終 verdict (approved / changes-requested / blocking) を出力。",
        "max_tokens": 1500,
    },
    "historian": {
        "system": "あなたは agoora の historian 役 agent。役割: セッション全体を 200 字に要約 + 次セッション引継メモ。R66 (md → Issue paste) 徹底。",
        "instruction": "本 Issue の全 agent 出力を統合し、(1) 200 字要約 (2) 重要決定事項 (3) 次セッション引継メモ を markdown で出力。Issue close 提案も含める。",
        "max_tokens": 1200,
    },
}


def gh_api(method: str, path: str, **kwargs) -> dict[str, Any]:
    token = os.environ["GITHUB_TOKEN"]
    repo = os.environ["REPO"]
    url = f"https://api.github.com/repos/{repo}{path}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    r = requests.request(method, url, headers=headers, **kwargs)
    r.raise_for_status()
    return r.json() if r.content else {}


def get_issue(issue_number: int) -> dict[str, Any]:
    return gh_api("GET", f"/issues/{issue_number}")


def get_comments(issue_number: int) -> list[dict[str, Any]]:
    return gh_api("GET", f"/issues/{issue_number}/comments")


def post_comment(issue_number: int, body: str) -> None:
    gh_api("POST", f"/issues/{issue_number}/comments", json={"body": body})


def build_context(issue: dict[str, Any], comments: list[dict[str, Any]]) -> str:
    """Issue + comments を agent context として整形."""
    parts = [
        f"# Issue #{issue['number']}: {issue['title']}",
        f"State: {issue['state']}",
        f"Labels: {', '.join(l['name'] for l in issue.get('labels', []))}",
        "",
        "## Body",
        issue.get("body") or "(empty)",
    ]
    if comments:
        parts.append("\n## 既存コメント (時系列)")
        for c in comments:
            author = c.get("user", {}).get("login", "?")
            parts.append(f"\n### @{author} ({c.get('created_at', '')})\n{c['body']}")
    return "\n".join(parts)


def call_claude(system: str, user: str, max_tokens: int) -> str:
    client = Anthropic()
    msg = client.messages.create(
        model="claude-opus-4-5",   # 最新 Opus (要存在確認、無ければ sonnet-4-5)
        max_tokens=max_tokens,
        system=system,
        messages=[{"role": "user", "content": user}],
    )
    return "".join(b.text for b in msg.content if hasattr(b, "text"))


def call_gemini(system: str, user: str, max_tokens: int) -> str:
    """Optional: Gemini for critic role (R14 別 LLM 強制)."""
    try:
        import google.generativeai as genai
    except ImportError:
        return ""
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return ""
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel("gemini-2.5-pro", system_instruction=system)
    res = model.generate_content(
        user,
        generation_config={"max_output_tokens": max_tokens},
    )
    return getattr(res, "text", "") or ""


def run_role(role: str, issue: dict, comments: list) -> str:
    spec = ROLE_PROMPTS[role]
    ctx = build_context(issue, comments)
    user = f"{spec['instruction']}\n\n---\n\n{ctx}"

    # critic は別 LLM 優先 (R14 echo chamber 防止)
    if role == "critic" and spec.get("prefer_llm") == "gemini":
        gemini_out = call_gemini(spec["system"], user, spec["max_tokens"])
        if gemini_out:
            return gemini_out
        # fallback to Claude

    return call_claude(spec["system"], user, spec["max_tokens"])


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--role", required=True, choices=list(ROLE_PROMPTS.keys()))
    args = parser.parse_args()

    issue_number = int(os.environ["ISSUE_NUMBER"])
    issue = get_issue(issue_number)
    comments = get_comments(issue_number)

    # historian は special: 全 agent 出力を統合
    print(f"[{args.role}] Running on Issue #{issue_number}: {issue['title']}", file=sys.stderr)

    try:
        output = run_role(args.role, issue, comments)
    except Exception as e:
        output = f"⚠ {args.role} 役 実行失敗: {e}\n\nfallback: Captain manual review 推奨。"
        print(f"Error: {e}", file=sys.stderr)

    # Post comment with role tag
    role_icons = {
        "researcher": "🔍", "architect": "🏛", "critic": "⚔",
        "coder": "💻", "reviewer": "✅", "historian": "📚",
    }
    header = f"## {role_icons.get(args.role, '🤖')} {args.role} (auto-relay)\n\n"
    footer = f"\n\n---\n_Generated by agoora auto-relay workflow ({args.role} role)_"
    post_comment(issue_number, header + output + footer)
    print(f"[{args.role}] Done", file=sys.stderr)


if __name__ == "__main__":
    main()
