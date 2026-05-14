#!/usr/bin/env python3
"""
Session state helper for git-agent.sh.
Manages .runtime/git-agent/sessions.json with safe JSON I/O.
"""
import json
import os
import sys

SESSIONS_FILE = os.environ.get("GIT_AGENT_SESSIONS",
    os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                 ".runtime", "git-agent", "sessions.json"))

def _load():
    if os.path.exists(SESSIONS_FILE):
        with open(SESSIONS_FILE) as f:
            return json.load(f)
    return {"sessions": []}

def _save(data):
    os.makedirs(os.path.dirname(SESSIONS_FILE), exist_ok=True)
    with open(SESSIONS_FILE, "w") as f:
        json.dump(data, f, indent=2)

def cmd_add():
    """Add a new session. Reads JSON from stdin."""
    session = json.load(sys.stdin)
    data = _load()
    data["sessions"].append(session)
    _save(data)
    print(f"Session saved: {session.get('id', '?')}")

def cmd_update():
    """Update session field. Args: session_id, key, value_json"""
    session_id = sys.argv[2]
    key = sys.argv[3]
    value = json.loads(sys.argv[4])
    data = _load()
    for s in data["sessions"]:
        if s.get("id") == session_id:
            s[key] = value
            break
    _save(data)
    print(f"Updated {session_id}: {key}")

def cmd_get():
    """Get a session by ID or name. Prints JSON or 'null'."""
    target = sys.argv[2]
    data = _load()
    for s in data["sessions"]:
        if s.get("id") == target or s.get("name") == target:
            print(json.dumps(s))
            return
    print("null")

def cmd_list():
    """List active sessions with status."""
    data = _load()
    sessions = data.get("sessions", [])
    active = [s for s in sessions if s.get("status") == "active"]
    if not active:
        print("No active sessions.")
        return
    for s in active:
        name = s.get("name", "?")
        sid = s.get("id", "?")
        branch = s.get("branch", "?")
        wp = s.get("worktree_path", "?")
        print(f"{name}  [{sid}]")
        print(f"  Branch: {branch}")
        print(f"  Path:   {wp}")
        if os.path.isdir(wp):
            try:
                import subprocess
                dirty = subprocess.run(
                    ["git", "status", "--porcelain"],
                    cwd=wp, capture_output=True, text=True, timeout=5
                ).stdout.strip()
                commits = subprocess.run(
                    ["git", "log", "--oneline", "main..HEAD"],
                    cwd=wp, capture_output=True, text=True, timeout=5
                ).stdout.strip()
                dirty_count = len(dirty.split("\n")) if dirty else 0
                commit_count = len(commits.split("\n")) if commits else 0
                state = "DIRTY" if dirty_count > 0 else "clean"
                print(f"  State:  {state}, {commit_count} commits")
            except Exception:
                print(f"  State:  error checking worktree")
        else:
            print(f"  State:  worktree missing")
        scope = s.get("safety", {})
        allowed = scope.get("allowed_paths", [])
        if allowed:
            print(f"  Scope:  {', '.join(allowed)}")
        print()

def cmd_find_by_cwd():
    """Find active session for current working directory. Prints session ID or empty."""
    cwd = os.path.realpath(os.getcwd())
    data = _load()
    for s in data["sessions"]:
        wp = os.path.realpath(s.get("worktree_path", ""))
        if s.get("status") == "active" and cwd.startswith(wp):
            print(s.get("id", ""))
            return
    print("")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: _session_helper.py <add|update|get|list|find-by-cwd> [...]")
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "add":
        cmd_add()
    elif cmd == "update" and len(sys.argv) >= 5:
        cmd_update()
    elif cmd == "get" and len(sys.argv) >= 3:
        cmd_get()
    elif cmd == "list":
        cmd_list()
    elif cmd == "find-by-cwd":
        cmd_find_by_cwd()
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)
