"""scripts/auto-label.py — 既存 Issue 自動ラベル付与 (Phase 1.5a)

Captain 指示反映 (2026-05-11):
「既存 Issue にラベルを貼る作業 (将来見越し) + その過程で agoora の発見・活用」

agora taxonomy (65 unique labels、agora-labels-audit.md) + project-map-grand.md
を基に、既存 Issue を自動分析してラベル提案。dry-run 既定、Captain review 後本適用。

Usage:
    python auto-label.py --repo riku1215/agoora --dry-run
    python auto-label.py --repo riku1215/agora --apply --confirm
    python auto-label.py --repo riku1215/agoora --issue 1 --apply

Env:
    GITHUB_TOKEN (gh CLI 認証済なら不要)

設計 (Section 7-9 並列実行 + R32 Proactive):
1. Issue title + body から keyword match
2. agora-labels-audit.md の 65 label と照合
3. project-map-grand.md L1-L4 で大/中/小 分類
4. 信頼度 (confidence) 付き label list 出力
5. dry-run: 提案表示のみ
6. --apply: gh CLI で実際に add-label

tags: [auto-label, phase-1-5a, dogfooding, agora-taxonomy]
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path


# ===========================================
# Label inference rules (agora taxonomy 反映)
# ===========================================

KEYWORD_RULES: dict[str, list[tuple[str, int]]] = {
    # type:*
    "type:doc":        [("documentation", 8), ("README", 6), ("ドキュメント", 7), ("doc", 5), ("md", 4)],
    "type:milestone":  [("Epic", 9), ("[Meta]", 8), ("milestone", 7), ("Phase", 5), ("マイルストーン", 7)],
    "type:research":   [("research", 7), ("分析", 6), ("調査", 7), ("先行事例", 8), ("benchmark", 6), ("論文", 7)],
    "type:decision":   [("decision", 8), ("方針", 6), ("選定", 7), ("採用", 5), ("ADR", 9), ("判断", 5)],
    "type:retro":      [("war-story", 9), ("失敗", 7), ("教訓", 8), ("post-mortem", 9), ("retrospective", 8), ("ロスト", 7)],
    "type:epic":       [("Epic", 10), ("親 Issue", 9), ("parent", 7), ("統括", 6)],
    "type:strategy":   [("戦略", 8), ("strategy", 8), ("vision", 7), ("ロードマップ", 7), ("roadmap", 7)],
    "type:refactor":   [("refactor", 9), ("リファクタ", 9), ("tech-debt", 8), ("技術負債", 8)],

    # area:*
    "area:llm":           [("LLM", 7), ("Claude", 6), ("Gemini", 6), ("ChatGPT", 6), ("Grok", 6), ("GPT", 5), ("Copilot", 5), ("agent", 4)],
    "area:arch":          [("architecture", 8), ("アーキ", 7), ("framework", 5), ("design", 4)],
    "area:test":          [("test", 7), ("テスト", 7), ("pytest", 8), ("vitest", 8), ("QA", 6), ("lint", 5)],
    "area:ops":           [("deploy", 7), ("デプロイ", 7), ("monitoring", 7), ("production", 6), ("SLO", 8)],
    "area:ui":            [("UI", 7), ("UX", 7), ("画面", 6), ("ユーザ", 5), ("frontend", 6)],
    "area:infra-runtime": [("Docker", 8), ("Compose", 8), ("Kubernetes", 9), ("k8s", 9), ("コンテナ", 7)],
    "area:algorithm":     [("algorithm", 8), ("アルゴ", 8), ("CP-SAT", 9), ("solver", 7), ("heuristic", 7)],
    "area:data":          [("PostgreSQL", 8), ("SQLite", 8), ("MySQL", 8), ("DB", 6), ("データベース", 7), ("schema", 6)],
    "area:infra-vps":     [("VPS", 9), ("sakura", 7), ("さくら", 7), ("vps", 8)],
    "area:integration":   [("integration", 7), ("cross-repo", 8), ("連携", 6)],

    # phase:*
    "phase:00": [("Phase 0", 8), ("phase-0", 8), ("conceptualization", 7)],
    "phase:01": [("Phase 1", 8), ("phase-1", 8), ("仕様策定", 6)],
    "phase:02": [("Phase 2", 8), ("phase-2", 8), ("PoC", 6)],
    "phase:09": [("Phase 9", 9), ("production hosting", 8)],

    # status:*
    "status:done": [("[done]", 10), ("✓ 完了", 8), ("✅ 完了", 8), ("DONE", 6)],

    # priority:*
    "priority:p0": [("critical", 8), ("blocking", 9), ("緊急", 9), ("p0", 9)],

    # agent:*
    "agent:claude":  [("Claude (主体)", 9), ("@claude", 6)],
    "agent:gemini":  [("Gemini", 6), ("ask-gemini", 8)],
    "agent:grok":    [("Grok", 6), ("X 検索", 7)],
    "agent:chatgpt": [("ChatGPT", 6), ("Codex", 7)],

    # doctrine:*
    "doctrine:must":        [("must", 7), ("必須", 6), ("R-rule", 5), ("absolute", 8)],
    "doctrine:instruction": [("instruction", 7), ("CLAUDE.md", 7), ("copilot-instructions", 8)],

    # visibility:* (agoora 提案、agora 未採用)
    "visibility:public":       [("public", 7), ("公開", 6)],
    "visibility:local-only":   [("local-only", 9), ("ローカルのみ", 7)],
    "visibility:captain-only": [("captain-only", 10), ("非公開", 7), ("Captain 専管", 9)],

    # auto-relay
    "auto-relay": [("auto-relay", 10), ("自動リレー", 9)],
}


L1_DOMAIN_RULES: dict[str, list[str]] = {
    "domain:ai-development":   ["AI", "LLM", "Claude", "GPT", "agent", "skills", "RAG", "embedding", "ChromaDB", "DSI"],
    "domain:web-development":  ["frontend", "React", "Vue", "Next.js", "Astro", "Tailwind", "shadcn", "Vercel"],
    "domain:data-engineering": ["database", "DB", "ETL", "pipeline", "vector", "Postgres", "SQLite"],
    "domain:devops":           ["CI/CD", "GitHub Actions", "Docker", "deploy", "monitoring", "infrastructure"],
    "domain:business":         ["billing", "課金", "提案", "monthly", "営業", "audit", "監査", "QUARD"],
}


@dataclass
class LabelSuggestion:
    label: str
    confidence: int       # 0-100
    matched_keywords: list[str] = field(default_factory=list)


def infer_labels(title: str, body: str) -> list[LabelSuggestion]:
    """Issue title + body から ラベル提案 (信頼度付き)."""
    text = (title or "") + "\n" + (body or "")
    text_lower = text.lower()
    suggestions: dict[str, LabelSuggestion] = {}

    # Keyword rules
    for label, rules in KEYWORD_RULES.items():
        for keyword, weight in rules:
            if keyword.lower() in text_lower:
                if label not in suggestions:
                    suggestions[label] = LabelSuggestion(label=label, confidence=0)
                suggestions[label].confidence += weight
                suggestions[label].matched_keywords.append(keyword)

    # L1 domain rules
    for label, keywords in L1_DOMAIN_RULES.items():
        score = sum(5 for k in keywords if k.lower() in text_lower)
        if score > 0:
            if label not in suggestions:
                suggestions[label] = LabelSuggestion(label=label, confidence=0)
            suggestions[label].confidence += score

    # confidence cap at 100
    for s in suggestions.values():
        s.confidence = min(s.confidence, 100)

    # filter: confidence >= 5
    result = [s for s in suggestions.values() if s.confidence >= 5]
    result.sort(key=lambda s: -s.confidence)
    return result


def gh_api(cmd: list[str]) -> dict:
    """gh CLI 呼出 (json 出力前提)."""
    proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if proc.returncode != 0:
        print(f"gh error: {proc.stderr}", file=sys.stderr)
        return {}
    try:
        return json.loads(proc.stdout) if proc.stdout.strip() else {}
    except json.JSONDecodeError:
        return {}


def list_issues(repo: str, limit: int = 100) -> list[dict]:
    return gh_api([
        "gh", "issue", "list", "-R", repo,
        "--state", "all", "--limit", str(limit),
        "--json", "number,title,body,labels,state",
    ]) or []


def get_issue(repo: str, num: int) -> dict:
    return gh_api([
        "gh", "issue", "view", str(num), "-R", repo,
        "--json", "number,title,body,labels,state",
    ]) or {}


def apply_labels(repo: str, num: int, labels: list[str], confirm: bool = True) -> bool:
    if not labels:
        return True
    if confirm:
        ans = input(f"  #{num} に {labels} を適用しますか? [y/N]: ").strip().lower()
        if ans != "y":
            print("  → スキップ")
            return False
    proc = subprocess.run([
        "gh", "issue", "edit", str(num), "-R", repo,
        "--add-label", ",".join(labels),
    ], capture_output=True, text=True, check=False)
    if proc.returncode != 0:
        print(f"  ⚠ 適用失敗: {proc.stderr}")
        return False
    print(f"  ✓ 適用完了")
    return True


def process_repo(repo: str, dry_run: bool, apply: bool, confirm: bool,
                 issue_num: int | None = None, min_confidence: int = 10) -> None:
    print(f"=== {repo} ===")

    if issue_num:
        issues = [get_issue(repo, issue_num)]
        issues = [i for i in issues if i]
    else:
        issues = list_issues(repo, limit=100)

    print(f"  Issues: {len(issues)} 件")

    total_proposed = 0
    total_applied = 0
    for issue in issues:
        num = issue["number"]
        existing = {l["name"] for l in issue.get("labels", [])}
        title = issue.get("title", "")
        body = issue.get("body", "")

        suggestions = infer_labels(title, body)
        new_labels = [s for s in suggestions if s.label not in existing and s.confidence >= min_confidence]

        if not new_labels:
            continue

        print(f"\n  #{num} {title[:60]}")
        print(f"    既存: {sorted(existing) or '(なし)'}")
        print(f"    提案 (confidence >= {min_confidence}):")
        for s in new_labels[:8]:    # top 8
            print(f"      [{s.confidence:3d}] {s.label:30s}  ← {','.join(s.matched_keywords[:3])}")
        total_proposed += len(new_labels)

        if apply and not dry_run:
            top_labels = [s.label for s in new_labels[:5]]   # 上位 5 まで適用
            if apply_labels(repo, num, top_labels, confirm=confirm):
                total_applied += len(top_labels)

    print(f"\n=== 完了 ===")
    print(f"  提案 label 数: {total_proposed}")
    print(f"  適用 label 数: {total_applied}")
    if dry_run:
        print(f"  (dry-run、実適用するには --apply)")


def main() -> None:
    parser = argparse.ArgumentParser(description="agoora auto-label (Phase 1.5a)")
    parser.add_argument("--repo", required=True, help="owner/repo")
    parser.add_argument("--issue", type=int, help="特定 Issue 番号 (省略時は最新 100 件)")
    parser.add_argument("--apply", action="store_true", help="実際に label 適用 (省略時 dry-run)")
    parser.add_argument("--confirm", action="store_true", help="各 Issue で y/N 確認")
    parser.add_argument("--no-confirm", dest="confirm", action="store_false")
    parser.add_argument("--min-confidence", type=int, default=10, help="提案閾値 (default 10)")
    parser.set_defaults(confirm=True)
    args = parser.parse_args()

    process_repo(
        repo=args.repo,
        dry_run=not args.apply,
        apply=args.apply,
        confirm=args.confirm,
        issue_num=args.issue,
        min_confidence=args.min_confidence,
    )


if __name__ == "__main__":
    main()
