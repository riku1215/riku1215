"""
kbignore.py - Load .kbignore patterns and provide path matching.

Used by index.py and update.py to filter noise from vector embedding
(Gemini 2.5 Pro review suggestion #2).

Pattern syntax: gitignore-like (one per line, # for comments, ** for recursive)
Patterns are applied to paths relative to repos/<name>/.

Supported syntax:
- **/foo/      → any directory named foo at any depth
- foo/         → directory foo at top level only
- *.ext        → files with extension at top level
- **/*.ext     → files with extension at any depth
- **/*.{a,b}   → brace expansion
- !pattern     → negation (not yet supported, treated as comment)
"""
from pathlib import Path
from fnmatch import fnmatch


def load_kbignore(kbignore_path: Path | None = None) -> list[str]:
    """Load .kbignore patterns. Returns list of patterns (excluding comments and blanks)."""
    if kbignore_path is None:
        candidates = [
            Path.home() / ".kb" / ".kbignore",
            Path(__file__).parent.parent / ".kbignore",
            Path.cwd() / ".kbignore",
        ]
        for c in candidates:
            if c.exists():
                kbignore_path = c
                break

    if kbignore_path is None or not kbignore_path.exists():
        return []

    patterns = []
    for line in kbignore_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or line.startswith("!"):
            continue
        patterns.append(line)
    return patterns


def _expand_braces(pattern: str) -> list[str]:
    """Expand {a,b,c} brace patterns into multiple patterns."""
    if "{" not in pattern or "}" not in pattern:
        return [pattern]

    start = pattern.index("{")
    end = pattern.index("}", start)
    prefix = pattern[:start]
    suffix = pattern[end + 1:]
    options = pattern[start + 1:end].split(",")

    results = []
    for opt in options:
        opt = opt.strip()
        results.extend(_expand_braces(prefix + opt + suffix))
    return results


def _match_single(path: str, pattern: str) -> bool:
    """Match a single (no-brace) pattern against path."""
    p = path
    pat = pattern

    # Directory pattern (ends with /)
    is_dir_pat = pat.endswith("/")
    if is_dir_pat:
        pat = pat.rstrip("/")

    # Strip leading **/
    has_recursive = pat.startswith("**/")
    if has_recursive:
        pat = pat[3:]

    if is_dir_pat:
        # Match if any path component equals/matches the pattern
        components = p.split("/")
        for c in components:
            if fnmatch(c, pat):
                return True
        return False
    else:
        # File pattern
        if has_recursive:
            # Match against last component (basename) OR full path
            basename = p.rsplit("/", 1)[-1]
            if fnmatch(basename, pat):
                return True
            if fnmatch(p, pat):
                return True
            if fnmatch(p, f"*/{pat}"):
                return True
        else:
            # Top-level only
            if fnmatch(p, pat):
                return True
    return False


def is_ignored(path: str | Path, patterns: list[str]) -> bool:
    """Return True if path matches any kbignore pattern."""
    path_str = str(path).replace("\\", "/")

    for pat in patterns:
        for expanded in _expand_braces(pat):
            if _match_single(path_str, expanded):
                return True
    return False


if __name__ == "__main__":
    import sys
    patterns = load_kbignore()
    print(f"Loaded {len(patterns)} patterns from .kbignore")

    test_paths = sys.argv[1:] or [
        "node_modules/foo/index.js",
        "src/main.py",
        "build/output.js",
        ".env.production",
        ".env.local",
        "docs/image.png",
        "README.md",
        "lib/vendor/package.json",
        ".vscode/settings.json",
        "logs/error.log",
        "secrets/api.key",
        "src/.cache/build",
        "tests/__snapshots__/foo.snap",
    ]

    for p in test_paths:
        result = is_ignored(p, patterns)
        marker = "IGNORE" if result else "  keep"
        print(f"  [{marker}] {p}")
