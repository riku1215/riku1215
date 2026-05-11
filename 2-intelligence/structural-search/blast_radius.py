"""structural-search/blast_radius.py — 関数の被参照数 (Repowise pattern)

Usage:
    python blast_radius.py --function <name> --repo <path> [--language python]

Output:
    {
      "function": "calc_score",
      "definition": {"file": "scoring.py", "line": 42},
      "called_by": [
        {"file": "solver.py", "line": 88, "in_function": "solve_cpsat"},
        ...
      ],
      "blast_radius": {
        "callers_count": N,
        "scope": "high | medium | low",
        "affected_files": [...]
      }
    }

agents.yml impact-analyst 役の skill: blast-radius-calc を駆動。
PR 前に変更対象関数の影響範囲を可視化。

tags: [tree-sitter, blast-radius, impact-analyst, repowise]
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from analyze import analyze_repo


def compute_blast_radius(repo_path: Path, function_name: str, language: str) -> dict[str, Any]:
    data = analyze_repo(repo_path, language)
    if "error" in data:
        return data

    # 関数定義を検索
    definitions = [f for f in data["functions"] if f["name"] == function_name]
    if not definitions:
        return {"error": f"Function '{function_name}' not found"}

    # 呼出元を検索
    callers = [c for c in data["calls"] if c["to"] == function_name]
    affected_files = sorted(set(c["from"].split("::")[0] for c in callers))

    # blast radius スコア (簡易: caller 数で判定)
    n = len(callers)
    if n >= 10:
        scope = "high"
    elif n >= 3:
        scope = "medium"
    else:
        scope = "low"

    return {
        "function": function_name,
        "definitions": definitions,
        "called_by": [
            {
                "file": c["from"].split("::")[0],
                "in_function": c["from"].split("::")[1] if "::" in c["from"] else "",
                "line": c["line"],
            }
            for c in callers
        ],
        "blast_radius": {
            "callers_count": n,
            "scope": scope,
            "affected_files": affected_files,
            "affected_files_count": len(affected_files),
        },
        "recommendation": (
            "🔴 high impact: 変更前に全 caller に test を追加、PR レビュー必須" if scope == "high"
            else "🟡 medium impact: 主要 caller に対する後方互換性確認推奨" if scope == "medium"
            else "🟢 low impact: 局所修正、通常 PR で OK"
        ),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--function", required=True, help="Target function name")
    parser.add_argument("--repo", required=True, help="Repository root path")
    parser.add_argument("--language", default="python")
    args = parser.parse_args()

    repo_path = Path(args.repo).resolve()
    if not repo_path.exists():
        sys.exit(f"Repo not found: {repo_path}")

    result = compute_blast_radius(repo_path, args.function, args.language)
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
