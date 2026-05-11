"""scripts/status-broadcaster.py — agoora 開発状況を ~/.agoora-status.json に書込

portal-api.py /events/stream が本ファイルを polling して SSE 配信。
agent/auto-relay/外部 script から呼出されて状況更新。

Usage:
    python status-broadcaster.py --agent researcher --status running --task "agora#82 fetch"
    python status-broadcaster.py --commit-now    # 直近 commit を broadcast
    python status-broadcaster.py --clear         # status 初期化

tags: [agoora, status, broadcaster, realtime]
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path

STATUS_PATH = Path.home() / ".agoora-status.json"


def read_status() -> dict:
    if not STATUS_PATH.exists():
        return {
            "version": 1,
            "agent_pipeline": [],
            "recent_commits": [],
            "captain_messages": [],
            "metrics": {},
            "updated_at": datetime.now().isoformat(timespec="seconds"),
        }
    try:
        return json.loads(STATUS_PATH.read_text(encoding="utf-8"))
    except Exception:
        return {}


def write_status(data: dict) -> None:
    data["updated_at"] = datetime.now().isoformat(timespec="seconds")
    STATUS_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def update_agent(name: str, status: str, task: str) -> None:
    data = read_status()
    pipeline = data.get("agent_pipeline", [])
    # 既存 entry を更新 or 追加
    for entry in pipeline:
        if entry.get("name") == name:
            entry.update({"status": status, "task": task, "ts": datetime.now().isoformat(timespec="seconds")})
            break
    else:
        pipeline.append({
            "name": name,
            "status": status,
            "task": task,
            "ts": datetime.now().isoformat(timespec="seconds"),
        })
    # 最新 12 件まで保持
    data["agent_pipeline"] = pipeline[-12:]
    write_status(data)


def update_commits() -> None:
    data = read_status()
    repo = Path.home() / "riku1215"
    try:
        out = subprocess.check_output(
            ["git", "-C", str(repo), "log", "--pretty=format:%h|%s|%ar|%an", "-10"],
            text=True, encoding="utf-8", errors="replace",
        )
        commits = []
        for line in out.splitlines():
            parts = line.split("|", 3)
            if len(parts) >= 3:
                commits.append({
                    "sha": parts[0],
                    "msg": parts[1],
                    "ago": parts[2],
                    "author": parts[3] if len(parts) > 3 else "",
                })
        data["recent_commits"] = commits
    except Exception as e:
        data["recent_commits"] = [{"error": str(e)}]
    write_status(data)


def push_captain_message(msg: str) -> None:
    data = read_status()
    msgs = data.get("captain_messages", [])
    msgs.append({"ts": datetime.now().isoformat(timespec="seconds"), "msg": msg[:200]})
    data["captain_messages"] = msgs[-20:]
    write_status(data)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--agent", help="Agent name (orchestrator/researcher/architect/critic/coder/reviewer/historian/structural-analyzer/impact-analyst/domain-expert)")
    parser.add_argument("--status", choices=["pending", "running", "completed", "failed"], help="Agent status")
    parser.add_argument("--task", default="", help="Task description")
    parser.add_argument("--commit-now", action="store_true", help="直近 commits を broadcast")
    parser.add_argument("--captain-msg", help="Captain message log")
    parser.add_argument("--clear", action="store_true", help="status 初期化")
    parser.add_argument("--show", action="store_true", help="現状表示")
    args = parser.parse_args()

    if args.clear:
        if STATUS_PATH.exists():
            STATUS_PATH.unlink()
        print(f"Cleared {STATUS_PATH}")
        return

    if args.show:
        print(json.dumps(read_status(), ensure_ascii=False, indent=2))
        return

    if args.commit_now:
        update_commits()
        print(f"Commits updated → {STATUS_PATH}")
        return

    if args.captain_msg:
        push_captain_message(args.captain_msg)
        print(f"Captain message logged")
        return

    if args.agent and args.status:
        update_agent(args.agent, args.status, args.task)
        print(f"Agent '{args.agent}' status updated to '{args.status}'")
        return

    parser.print_help()
    sys.exit(1)


if __name__ == "__main__":
    main()
