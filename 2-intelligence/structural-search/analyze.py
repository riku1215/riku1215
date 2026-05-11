"""structural-search/analyze.py — Tree-sitter で単一 repo の関数定義 + 呼出抽出

Usage:
    python analyze.py <repo_path> --language python [--output json|text]

Output (JSON):
    {
      "repo": "<path>",
      "language": "python",
      "functions": [{"name": ..., "file": ..., "line": ..., "params": [...]}],
      "calls": [{"from": "<file>::<func>", "to": "<func_name>", "line": ...}],
      "summary": {"functions_count": N, "calls_count": M, "files_scanned": K}
    }

agents.yml structural-analyzer 役の skill: tree-sitter-query を駆動。

tags: [tree-sitter, structural-search, analyze, poc]
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

try:
    from tree_sitter_language_pack import get_parser
except ImportError:
    sys.exit("Install: pip install tree-sitter tree-sitter-language-pack")


def find_files(repo_path: Path, extensions: list[str]) -> list[Path]:
    """指定拡張子のファイルを再帰的に収集 (.git / node_modules / venv 除外)."""
    ignore = {".git", "node_modules", "venv", ".venv", "__pycache__", "dist", "build"}
    files = []
    for ext in extensions:
        for p in repo_path.rglob(f"*{ext}"):
            if any(part in ignore for part in p.parts):
                continue
            files.append(p)
    return files


def extract_python(tree, source: bytes, file_path: Path) -> tuple[list[dict], list[dict]]:
    """Python AST から function 定義 + call 抽出."""
    functions = []
    calls = []
    current_func = None

    def walk(node, parent_func=None):
        nonlocal current_func
        if node.type == "function_definition":
            # 関数定義
            name_node = node.child_by_field_name("name")
            params_node = node.child_by_field_name("parameters")
            if name_node:
                name = source[name_node.start_byte:name_node.end_byte].decode("utf8", errors="replace")
                params = []
                if params_node:
                    params_text = source[params_node.start_byte:params_node.end_byte].decode("utf8", errors="replace")
                    params = [p.strip() for p in params_text.strip("()").split(",") if p.strip()]
                functions.append({
                    "name": name,
                    "file": str(file_path),
                    "line": node.start_point[0] + 1,
                    "params": params,
                })
                parent_func = name
        elif node.type == "call":
            # 関数呼出
            func_node = node.child_by_field_name("function")
            if func_node:
                # attribute (e.g. obj.method) or identifier
                callee = source[func_node.start_byte:func_node.end_byte].decode("utf8", errors="replace")
                # ドット記法から最終要素抽出 (例: foo.bar.baz → baz)
                callee_simple = callee.split(".")[-1].split("(")[0].strip()
                if parent_func and callee_simple:
                    calls.append({
                        "from": f"{file_path}::{parent_func}",
                        "to": callee_simple,
                        "line": node.start_point[0] + 1,
                    })
        for child in node.children:
            walk(child, parent_func)

    walk(tree.root_node)
    return functions, calls


# 言語別マッピング
LANGUAGE_CONFIG = {
    "python":     {"extensions": [".py"],          "extractor": extract_python},
    "typescript": {"extensions": [".ts", ".tsx"],  "extractor": extract_python},  # TODO: ts 用
    "javascript": {"extensions": [".js", ".jsx"],  "extractor": extract_python},  # TODO: js 用
}


def analyze_repo(repo_path: Path, language: str) -> dict[str, Any]:
    cfg = LANGUAGE_CONFIG.get(language)
    if not cfg:
        return {"error": f"Unsupported language: {language}"}

    try:
        parser = get_parser(language)
    except Exception as e:
        return {"error": f"Parser load failed: {e}"}

    files = find_files(repo_path, cfg["extensions"])
    all_functions = []
    all_calls = []
    scanned = 0

    for f in files:
        try:
            source = f.read_bytes()
            tree = parser.parse(source)
            funcs, calls = cfg["extractor"](tree, source, f.relative_to(repo_path))
            all_functions.extend(funcs)
            all_calls.extend(calls)
            scanned += 1
        except Exception as e:
            print(f"⚠ Skip {f}: {e}", file=sys.stderr)

    return {
        "repo": str(repo_path),
        "language": language,
        "functions": all_functions,
        "calls": all_calls,
        "summary": {
            "functions_count": len(all_functions),
            "calls_count": len(all_calls),
            "files_scanned": scanned,
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("repo", help="Repository root path")
    parser.add_argument("--language", default="python", choices=list(LANGUAGE_CONFIG.keys()))
    parser.add_argument("--output", default="json", choices=["json", "text"])
    args = parser.parse_args()

    repo_path = Path(args.repo).resolve()
    if not repo_path.exists():
        sys.exit(f"Repo not found: {repo_path}")

    result = analyze_repo(repo_path, args.language)

    if args.output == "json":
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print(f"Repo: {result['repo']}")
        print(f"Language: {result['language']}")
        print(f"Files scanned: {result['summary']['files_scanned']}")
        print(f"Functions: {result['summary']['functions_count']}")
        print(f"Calls: {result['summary']['calls_count']}")
        print("\n=== Top 10 functions ===")
        for f in result["functions"][:10]:
            print(f"  {f['file']}:{f['line']} :: {f['name']}({', '.join(f['params'])})")


if __name__ == "__main__":
    main()
