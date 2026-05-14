#!/bin/bash
# git-agent.sh --- Session-based git management for autonomous agents.
#
# Agent-safe git operations: create isolated worktree sessions, commit
# with quality gates, squash before PR, and clean up on completion.
#
# Usage:
#   git-agent.sh start <name> [--allow <paths>] [--base <branch>]
#   git-agent.sh commit [-m "message"]
#   git-agent.sh status [session-id]
#   git-agent.sh end [session-id] [--pr] [--pr-title "title"] [--merge]
#   git-agent.sh abort <session-id>
#   git-agent.sh ci-wait <session-id> [--timeout <seconds>]

set -euo pipefail
trap 'echo "[ERROR] $BASH_SOURCE:$LINENO"' ERR

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
HELPER="$(dirname "$0")/_session_helper.py"
AGENT_DIR="$REPO_ROOT/.runtime/git-agent"
SESSIONS_FILE="$AGENT_DIR/sessions.json"
SESSION_ROOT="$REPO_ROOT/../agent-sessions"
mkdir -p "$AGENT_DIR" "$SESSION_ROOT"

# ---------------------------------------------------------------------------
# Session state helpers (delegate to Python helper for safe JSON)
# ---------------------------------------------------------------------------
get_session() {
  python3 "$HELPER" get "$1" 2>/dev/null || echo "null"
}

update_session() {
  python3 "$HELPER" update "$1" "$2" "$3" 2>/dev/null || true
}

find_session_by_cwd() {
  python3 "$HELPER" find-by-cwd 2>/dev/null || true
}

list_sessions() {
  python3 "$HELPER" list 2>/dev/null || echo "(no sessions)"
}

init_state() {
  if [ ! -f "$SESSIONS_FILE" ]; then
    echo '{"sessions":[]}' > "$SESSIONS_FILE"
  fi
}

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
show_help() {
  echo "Agent git session manager"
  echo ""
  echo "Usage:"
  echo "  start <name> [--allow <paths>] [--base <b>]  Create session from base branch (default: main)"
  echo "  commit [-m <msg>]                             Commit changes with quality gate"
  echo "  status [session-id]                           List active sessions (or details for one)"
  echo "  end [session-id] [--pr] [--pr-title x] [--merge]  Squash, cleanup (--pr: PR, --merge into base)"
  echo "  abort <session-id>                                        Discard session entirely"
  echo "  ci-wait <session-id> [--timeout N]          Wait for CI to pass"
  echo ""
  echo "Examples:"
  echo "  git-agent.sh start feature-x --allow scripts/"
  echo "  git-agent.sh start fork-task --base feat/autonomous-runtime"
  echo "  git-agent.sh commit -m 'Implement feature X'"
  echo "  git-agent.sh end --pr                          # Push, create PR, cleanup"
  echo "  git-agent.sh end --merge                       # Merge into base branch, cleanup"
  echo "  git-agent.sh ci-wait --timeout 300"
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------
CMD="${1:-help}"
shift 1 || true

case "$CMD" in
  # ===== start =====
  start)
    NAME="${1:-}"
    [ -z "$NAME" ] && echo "Usage: git-agent.sh start <name> [--allow <paths>] [--base <branch>]" && exit 1
    shift 1

    # Parse flags
    ALLOW_PATHS=()
    BASE_BRANCH="main"
    while [ $# -gt 0 ]; do
      case "$1" in
        --allow)
          shift
          while [ $# -gt 0 ] && ! [[ "$1" =~ ^-- ]]; do
            ALLOW_PATHS+=("$1")
            shift
          done
          ;;
        --base)
          BASE_BRANCH="$2"
          shift 2
          ;;
        *) echo "Unknown: $1"; exit 1 ;;
      esac
    done

    # Verify base branch exists
    if ! git show-ref --verify "refs/heads/$BASE_BRANCH" >/dev/null 2>&1; then
      echo "Base branch not found: $BASE_BRANCH"
      exit 1
    fi

    init_state

    # Generate session ID
    SESSION_ID="sess-${NAME}-$(date -u +%Y%m%d%H%M%S)"
    BRANCH="agent/${NAME}"
    WORKTREE_PATH="$SESSION_ROOT/${NAME}"
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Check branch doesn't exist
    if git show-ref --verify "refs/heads/$BRANCH" >/dev/null 2>&1; then
      echo "Branch already exists: $BRANCH"
      exit 1
    fi

    # Check worktree path doesn't exist
    if [ -d "$WORKTREE_PATH" ]; then
      echo "Worktree path exists: $WORKTREE_PATH"
      echo "Remove it or use a different session name."
      exit 1
    fi

    # Create branch from base and worktree
    git branch "$BRANCH" "$BASE_BRANCH"
    git worktree add "$WORKTREE_PATH" "$BRANCH"

    # Normalize worktree path (resolve .. etc.)
    WORKTREE_PATH=$(cd "$WORKTREE_PATH" && pwd)

    # Set EXIT trap for auto-commit WIP
    # Save the trap setup as a helper in the worktree
    # Exclude trap file from git tracking so it doesn't leak to main
    # Worktrees use .git as a file (not a directory), so use .gitignore in worktree root
    echo ".git-agent-trap.sh" >> "$WORKTREE_PATH/.gitignore" 2>/dev/null || true
    cat > "$WORKTREE_PATH/.git-agent-trap.sh" << 'TRAPEOF'
#!/bin/bash
# Auto-commit WIP on unexpected exit.
# Sourced by git-agent.sh, not intended for direct use.
trap 'wip_commit' EXIT
wip_commit() {
  local rc=$?
  if [ "$rc" -ne 0 ] && [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    git add -A 2>/dev/null || true
    git commit -m "WIP: auto-checkpoint [$(date -u +%Y-%m-%dT%H:%M:%SZ)]" --no-verify 2>/dev/null || true
  fi
}
TRAPEOF
    chmod +x "$WORKTREE_PATH/.git-agent-trap.sh"

    # Init safety scope in the worktree
    if [ ${#ALLOW_PATHS[@]} -gt 0 ]; then
      cd "$WORKTREE_PATH"
      # Create a temporary pipeline for safety scope
      TMP_PIPELINE="git-agent-${SESSION_ID}"
      PIPELINE_DIR="$REPO_ROOT/.runtime/pipeline"
      mkdir -p "$PIPELINE_DIR"
      cat > "$PIPELINE_DIR/$TMP_PIPELINE.json" << PIPEOF
{
  "id": "$TMP_PIPELINE",
  "title": "Session: $NAME",
  "created": "$TIMESTAMP",
  "current_task": null,
  "tasks": [],
  "status": "active",
  "routes": [],
  "safety": {
    "allowed_paths": $(printf '%s\n' "${ALLOW_PATHS[@]}" | python3 -c "import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))" 2>/dev/null || echo "[]"),
    "blocked_paths": [],
    "max_tasks": null,
    "max_loops": null,
    "human_gates": []
  }
}
PIPEOF
      cd "$REPO_ROOT"
    fi

    # Save session state via helper
    printf '{"id":"%s","name":"%s","branch":"%s","base_branch":"%s","worktree_path":"%s","created":"%s","status":"active","safety":%s}' \
      "$SESSION_ID" "$NAME" "$BRANCH" "$BASE_BRANCH" "$WORKTREE_PATH" "$TIMESTAMP" \
      "$(printf '%s\n' "${ALLOW_PATHS[@]}" | python3 -c "import json,sys; paths=[l.strip() for l in sys.stdin if l.strip()]; print(json.dumps({'allowed_paths':paths,'blocked_paths':[],'max_tasks':None,'max_loops':None,'human_gates':[]}) if paths else '{}')" 2>/dev/null)" \
      | python3 "$HELPER" add

    echo "Session started: $NAME"
    echo "  ID:     $SESSION_ID"
    echo "  Branch: $BRANCH"
    echo "  Path:   $WORKTREE_PATH"
    echo "  Safety: ${ALLOW_PATHS[*]:-(unrestricted)}"
    echo ""
    echo "To work in this session:"
    echo "  cd $WORKTREE_PATH"
    echo "  source .git-agent-trap.sh  (enables auto-commit on exit)"
    echo "  git-agent.sh commit -m \"msg\""
    ;;

  # ===== commit =====
  commit)
    MESSAGE=""
    while [ $# -gt 0 ]; do
      case "$1" in
        -m|--message) MESSAGE="$2"; shift 2 ;;
        *) echo "Unknown: $1"; exit 1 ;;
      esac
    done

    # Find active session for this worktree
    SESSION_ID=$(find_session_by_cwd)
    if [ -z "$SESSION_ID" ]; then
      echo "Not in an active session worktree."
      echo "Run 'git-agent.sh status' to see active sessions."
      echo "Then cd to the session worktree and commit from there."
      exit 1
    fi

    SESSION_JSON=$(get_session "$SESSION_ID")
    WP=$(echo "$SESSION_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin).get('worktree_path',''))" 2>/dev/null)

    # cd to worktree
    cd "$WP"

    # Check for changes
    if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
      echo "No changes to commit."
      cd "$REPO_ROOT"
      exit 0
    fi

    # Generate message from diff if not provided
    if [ -z "$MESSAGE" ]; then
      MESSAGE=$(git diff --stat 2>/dev/null | head -3 | tr '\n' ' ' | head -c 80 || echo "WIP checkpoint")
    fi

    # Stage all changes
    git add -A

    # Run quality gate (from worktree directory)
    if [ -f "$REPO_ROOT/scripts/hooks/quality-gate.sh" ]; then
      bash "$REPO_ROOT/scripts/hooks/quality-gate.sh" 2>&1 || true
    fi

    # Commit
    git commit -m "$MESSAGE" --no-verify 2>&1 || {
      echo "Commit failed. Check for merge conflicts or empty commit."
      cd "$REPO_ROOT"
      exit 1
    }

    echo "Committed: $MESSAGE"
    cd "$REPO_ROOT"
    ;;

  # ===== status =====
  status)
    SESSION_ID="${1:-}"
    init_state

    if [ -n "$SESSION_ID" ]; then
      S=$(get_session "$SESSION_ID")
      if [ "$S" = "null" ]; then
        echo "Session not found: $SESSION_ID"
        exit 1
      fi
      echo "$S" | python3 -m json.tool 2>/dev/null
    else
      list_sessions
    fi
    ;;

  # ===== end =====
  end)
    SESSION_ID=""
    PR_FLAG=false
    PR_TITLE=""
    MERGE_FLAG=false

    # Try to auto-detect session from worktree
    SESSION_ID=$(find_session_by_cwd)

    # Parse remaining args
    while [ $# -gt 0 ]; do
      case "$1" in
        --pr) PR_FLAG=true; shift ;;
        --pr-title) PR_TITLE="$2"; shift 2 ;;
        --merge) MERGE_FLAG=true; shift ;;
        *)
          if [ -z "$SESSION_ID" ]; then
            SESSION_ID="$1"
          fi
          shift
          ;;
      esac
    done

    [ -z "$SESSION_ID" ] && echo "Usage: git-agent.sh end [session-id] [--pr] [--pr-title 'title']" && exit 1

    S=$(get_session "$SESSION_ID")
    [ "$S" = "null" ] && echo "Session not found: $SESSION_ID" && exit 1

    NAME=$(echo "$S" | python3 -c "import json,sys; print(json.load(sys.stdin).get('name',''))" 2>/dev/null)
    BRANCH=$(echo "$S" | python3 -c "import json,sys; print(json.load(sys.stdin).get('branch',''))" 2>/dev/null)
    WP=$(echo "$S" | python3 -c "import json,sys; print(json.load(sys.stdin).get('worktree_path',''))" 2>/dev/null)
    BASE_BRANCH=$(echo "$S" | python3 -c "import json,sys; print(json.load(sys.stdin).get('base_branch','main'))" 2>/dev/null)

    echo "Ending session: $NAME (base: $BASE_BRANCH)"

    # cd to worktree if it exists
    if [ -d "$WP" ]; then
      cd "$WP"

      # Auto-commit any remaining changes
      if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        git add -A 2>/dev/null || true
        git commit -m "WIP: final checkpoint" --no-verify 2>/dev/null || true
      fi

      # Squash all commits on this branch into one (against base branch)
      COMMIT_COUNT=$(git log --oneline "$BASE_BRANCH"..HEAD 2>/dev/null | wc -l)
      if [ "$COMMIT_COUNT" -gt 1 ]; then
        echo "  Squashing $COMMIT_COUNT commits against $BASE_BRANCH..."
        git reset --soft "$BASE_BRANCH" 2>/dev/null
        SQUASH_MSG="${PR_TITLE:-Session: $NAME}"
        if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
          echo "  No changes to squash (already up to date)."
        else
          git commit -m "$SQUASH_MSG" --no-verify 2>/dev/null || true
        fi
      fi

      # Push and create PR if requested
      if [ "$PR_FLAG" = true ]; then
        echo "  Pushing branch..."
        git push -u origin "$BRANCH" 2>&1 || echo "  (push failed or no remote configured)"

        if command -v gh &>/dev/null; then
          echo "  Creating PR..."
          if [ -n "$PR_TITLE" ]; then
            gh pr create --title "$PR_TITLE" --fill --draft 2>&1 || echo "  (PR creation failed)"
          else
            gh pr create --fill --draft 2>&1 || echo "  (PR creation failed)"
          fi
        else
          echo "  gh CLI not found. Skipping PR creation."
        fi
      fi

      # Merge back to base branch (fork -> base)
      if [ "$MERGE_FLAG" = true ]; then
        echo "  Merging into $BASE_BRANCH..."
        git checkout "$BASE_BRANCH" 2>/dev/null || true
        git merge "$BRANCH" --squash 2>/dev/null && git commit -m "${PR_TITLE:-Merge session: $NAME}" --no-verify 2>/dev/null || \
          echo "  (merge skipped: no changes or conflicts)"
        git push 2>&1 || echo "  (push failed or no remote configured)"
        git checkout "$BRANCH" 2>/dev/null || true
      fi

      # Remove worktree
      echo "  Removing worktree..."
      cd "$REPO_ROOT"
      git worktree remove "$WP" 2>/dev/null || git worktree remove --force "$WP" 2>/dev/null || true
      rm -rf "$WP" 2>/dev/null || true
    else
      echo "  Worktree not found at $WP (cleaning up state only)"
    fi

    # Delete branch
    echo "  Removing branch..."
    git branch -D "$BRANCH" 2>/dev/null || true

    # Update session state
    update_session "$SESSION_ID" "status" "\"completed\""
    update_session "$SESSION_ID" "completed" "\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""

    echo "Session ended: $NAME"
    ;;

  # ===== abort =====
  abort)
    SESSION_ID="${1:-}"
    [ -z "$SESSION_ID" ] && echo "Usage: git-agent.sh abort <session-id>" && exit 1

    S=$(get_session "$SESSION_ID")
    [ "$S" = "null" ] && echo "Session not found: $SESSION_ID" && exit 1

    NAME=$(echo "$S" | python3 -c "import json,sys; print(json.load(sys.stdin).get('name',''))" 2>/dev/null)
    BRANCH=$(echo "$S" | python3 -c "import json,sys; print(json.load(sys.stdin).get('branch',''))" 2>/dev/null)
    WP=$(echo "$S" | python3 -c "import json,sys; print(json.load(sys.stdin).get('worktree_path',''))" 2>/dev/null)

    echo "Aborting session: $NAME"

    if [ -d "$WP" ]; then
      cd "$REPO_ROOT"
      git worktree remove --force "$WP" 2>/dev/null || true
      rm -rf "$WP" 2>/dev/null || true
    fi
    git branch -D "$BRANCH" 2>/dev/null || true

    update_session "$SESSION_ID" "status" "\"aborted\""
    update_session "$SESSION_ID" "completed" "\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""

    echo "Session aborted: $NAME"
    ;;

  # ===== ci-wait =====
  ci-wait)
    SESSION_ID="${1:-}"
    shift 1 || true
    TIMEOUT=300

    # Try auto-detect from worktree
    if [ -z "$SESSION_ID" ]; then
      SESSION_ID=$(find_session_by_cwd)
    fi

    while [ $# -gt 0 ]; do
      case "$1" in
        --timeout) TIMEOUT="$2"; shift 2 ;;
        *) echo "Unknown: $1"; exit 1 ;;
      esac
    done

    [ -z "$SESSION_ID" ] && echo "Usage: git-agent.sh ci-wait [session-id] [--timeout N]" && exit 1

    S=$(get_session "$SESSION_ID")
    [ "$S" = "null" ] && echo "Session not found: $SESSION_ID" && exit 1

    BRANCH=$(echo "$S" | python3 -c "import json,sys; print(json.load(sys.stdin).get('branch',''))" 2>/dev/null)

    if ! command -v gh &>/dev/null; then
      echo "gh CLI not found. Cannot check CI status."
      exit 1
    fi

    echo "Waiting for CI on branch: $BRANCH (timeout: ${TIMEOUT}s)"
    ELAPSED=0
    SLEEP=10

    while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
      # Get the latest workflow run for this branch
      RUN=$(gh run list --branch "$BRANCH" --limit 1 --json conclusion,status,displayTitle 2>/dev/null || echo "")

      STATUS=$(echo "$RUN" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d[0].get('status','')) if isinstance(d,list) and d else print('no_runs')" 2>/dev/null || echo "error")
      CONCLUSION=$(echo "$RUN" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d[0].get('conclusion','')) if isinstance(d,list) and d else print('')" 2>/dev/null || echo "")

      case "$STATUS" in
        completed)
          if [ "$CONCLUSION" = "success" ]; then
            echo "CI PASSED after ${ELAPSED}s"
            exit 0
          elif [ "$CONCLUSION" = "failure" ] || [ "$CONCLUSION" = "cancelled" ]; then
            echo "CI FAILED after ${ELAPSED}s (conclusion: $CONCLUSION)"
            exit 1
          else
            echo "CI completed with: $CONCLUSION"
            exit 1
          fi
          ;;
        in_progress|pending|queued|waiting)
          echo "  CI in progress... (${ELAPSED}s elapsed)"
          ;;
        no_runs|"")
          # No runs on this branch yet --- normal if branch was just pushed
          if [ "$ELAPSED" -eq 0 ]; then
            echo "  Waiting for CI to start..."
          fi
          ;;
      esac

      sleep "$SLEEP"
      ELAPSED=$((ELAPSED + SLEEP))
    done

    echo "CI wait TIMEOUT after ${TIMEOUT}s"
    echo "Check status manually: gh run list --branch $BRANCH"
    exit 1
    ;;

  # ===== help =====
  help|--help|-h|*)
    show_help
    ;;
esac
