---
name: session-handoff
description: Create a session checkpoint with compressed context for resuming later. Use when the conversation reaches 10+ turns, the user indicates they are leaving, a major topic shift occurs, or context compaction is needed.
---

# Session Handoff / Checkpoint

Create a compressed checkpoint so future sessions can resume without re-reading the entire thread.

## Steps

1. **Check turn count**: If 10+ turns, suggest handoff proactively.

2. **Compress context to 5-line summary**:
   - What was the original goal?
   - What decisions were made?
   - What files were changed?
   - What's the current blocker or next step?
   - Any warnings for the next session?

3. **Update `workflow/session-state.json`**:
   ```json
   {
     "status": "paused",
     "interrupted_count": N,
     "next_action": "[specific next step]"
   }
   ```

4. **Present handoff to user**:
   ```
   ## Checkpoint
   
   **Goal:** [original goal]
   **Decisions:** [key decisions]
   **Changed:** [files modified/created]
   **Next:** [what comes next]
   **Warning:** [any gotchas]
   
   Session state updated. Resume by reading workflow/session-state.json.
   ```

## Rules
- Never re-verify previous work after compaction
- The next session should execute `next_action` only
- Include file paths, not full content
- Keep under 200 tokens
