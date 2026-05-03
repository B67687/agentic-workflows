---
description: Create an isolated short-lived worktree branch for separate work
---

Run:
`bash ./git-worktree-branch.sh "$ARGUMENTS"`

If `$ARGUMENTS` is empty, ask for the branch name in one short sentence.

Then return:
- created branch name
- created path
- what kind of work should happen there
- that the current checkout should stay clean while the isolated work happens there
