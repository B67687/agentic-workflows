# Cross-Project Memory Loop

Use this file when a repo learns something worth preserving beyond that one project.

## Goal

Let each repo keep its own local truth while still feeding reusable lessons back into this central library.

## The Operating Loop

1. Capture the lesson in the repo's local lessons file first.
2. Decide whether it is:
   - repo-specific only
   - transferable across multiple repos
3. Harvest local lessons into this central repo.
4. Build a smaller promotion-review document from the harvested lessons.
5. Generalize and deduplicate the transferable parts here.
6. Update the right central docs or templates.
7. Redistribute the improved templates back to repos.

## What Stays Local

Keep these in the repo:

- maintainer tone and style
- local build or auth pitfalls
- repo-specific architecture rules
- one-off upstream politics or scope boundaries

## What Gets Promoted Here

Promote lessons when they change how work should be done elsewhere too.

Good candidates:

- prompting patterns that repeatedly improve results
- debugging or verification habits that transfer well
- instruction-file structure lessons
- workflow patterns that reduce repeated mistakes
- tooling or setup practices that help across repos

## Merge Rule

Do not copy local lessons here verbatim by default.

Instead:

1. extract the durable insight
2. remove repo-only details unless they are the point
3. compare against existing docs
4. merge into the smallest correct central location
5. leave the repo-specific example in the local lessons file if it still helps there

## Where To Merge Things

- [core-agent-doctrine.md](core-agent-doctrine.md) for durable operating principles
- [daily-prompts.md](daily-prompts.md) for prompt shapes and scenario playbooks
- [token-efficient-prompting.md](token-efficient-prompting.md) for context-efficiency lessons
- [tdd-with-agents.md](tdd-with-agents.md) for test-driven execution patterns
- [repo-tooling.md](repo-tooling.md) for tooling guidance
- [propagate-templates\AGENTS.template.md](../propagate-templates/AGENTS.template.md) for repo-level instruction defaults
- [propagate-templates\topic-insights.template.md](../propagate-templates/topic-insights.template.md) for local memory structure

## Recommended Cadence

- after major PR feedback
- after a repeated failure pattern is understood
- after a new repo convention is confirmed
- after a workflow proves reusable across multiple repos

## Harvest Workflow

Use `scripts/harvest-topic-insights.ps1` to collect topic insights from repos into a central snapshot.

## Promotion Review Workflow

Use `scripts/build-cross-domain-candidates.ps1` to identify lessons worth promoting to the central library.

Each candidate now gets a stable ID and can carry persistent review state across rebuilds through `workflow/cross-domain-review-state.json`.

The suggested destination is only a heuristic.
Treat it as triage help, not as an automatic merge decision.

To mark a candidate after review:

```powershell
& ".\set-promotion-review-status.ps1" `
  -CandidateId "[candidate-id]" `
  -Status promoted `
  -Destination "core-agent-doctrine.md" `
  -GeneralizedWording "[reusable wording]" `
  -Notes "[optional notes]"
```

If the review file comes back empty across existing repos, the usual cause is that those repos still have older lessons files that have not been resynced to the newer template structure yet.
Preview and apply the repo sync first, then rebuild the promotion queue.

## Redistribution Workflow

After updating the central templates, preview:

```powershell
& ".\sync-all-project-instructions.ps1" -CreateMissing
```

Then apply:

```powershell
& ".\sync-all-project-instructions.ps1" -CreateMissing -Apply
```

## Repo Deletion Protocol

When a repo is no longer actively used, run the retirement script:

```powershell
# Preview everything that would happen
.\scripts\retire-repo.ps1 -RepoName "Noise Generator" -DryRun

# Actually retire (harvests lessons, builds promotion candidates,
# archives durable content, marks Archived in registry, deletes folder)
.\scripts\retire-repo.ps1 -RepoName "Noise Generator" -Apply

# Skip harvest if repo has no lessons worth collecting
.\scripts\retire-repo.ps1 -RepoName "SomeTestRepo" -SkipHarvest -Apply
```

The script follows a 7-step workflow:
1. Validate — confirms repo is in registry, not Central Hub, not already Archived
2. Harvest — collects remaining lessons from topic-insights.md
3. Build Candidates — builds cross-domain promotion queue for review
4. Review — prompts you to handle promotion candidates
5. Archive — copies durable content to archive/{RepoName}/
6. Unregister — changes status to "Archived" in cross-domain-registry.md
7. Delete — removes repo folder (only with -Apply)

**Why "Archived" instead of removing from registry?**
Keeps a historical record. Revival is possible. Low cost to keep.

**Why require -Apply?**
No accidental deletions. Consistent with sync-all-project-instructions.ps1 pattern.

## Best Short Summary

Each repo should remember its own lessons locally first. This central repo should only absorb the parts that change how work should be done elsewhere, then push the improved defaults back out.
