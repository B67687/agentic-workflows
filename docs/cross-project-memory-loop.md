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

- (Superseded) `core-agent-doctrine.md` for durable operating principles (see ADRs)
- [daily-prompts.md](daily-prompts.md) for prompt shapes and scenario playbooks
- [token-efficient-prompting.md](token-efficient-prompting.md) for context-efficiency lessons
- [tdd-with-agents.md](tdd-with-agents.md) for test-driven execution patterns
- [repo-tooling.md](repo-tooling.md) for tooling guidance
- [propagation\AGENTS.template.md](../propagation/AGENTS.template.md) for repo-level instruction defaults
- [propagation\topic-insights.template.md](../propagation/topic-insights.template.md) for local memory structure

## Recommended Cadence

- after major PR feedback
- after a repeated failure pattern is understood
- after a new repo convention is confirmed
- after a workflow proves reusable across multiple repos

## Harvest Workflow

Use the bash harvester to collect repo-owned topic insights from topic folders into a central snapshot:

```bash
bash ./scripts/harvest-topic-insights.sh
```

The harvest step is read-only against topic repos. It only reads local `topic-insights.md` files and writes hub workflow output.

## Promotion Review Workflow

Use the candidate builder to identify lessons worth promoting to the central library:

```bash
bash ./scripts/build-cross-domain-candidates.sh
```

The suggested destination is only a heuristic.
Treat it as triage help, not as an automatic merge decision.

Promotion is manual. After review, merge the approved lesson explicitly:

```bash
bash ./scripts/merge-and-propagate.sh \
  --id "[candidate-id]" \
  --target "archive/superseded/core-agent-doctrine.md" \
  --wording "[reusable wording]"
```

`workflow/cross-domain-review-state.json` may be retained for future tooling, but explicit review plus explicit merge is the current source of truth.

## Redistribution Workflow

After updating a central doc or managed template, preview propagation:

```bash
bash ./scripts/propagate-to-all.sh
```

Then apply:

```bash
bash ./scripts/propagate-to-all.sh --apply
```

## Repo Retirement

Repo retirement is not currently part of the supported bash-first automation contract.

If a repo is no longer actively used:

1. harvest any durable lessons first
2. archive the repo history you still care about
3. update `workflow/cross-domain-registry.md` manually if the registry should record retirement
4. delete the repo folder only after that review is complete

## Best Short Summary

Each repo should remember its own lessons locally first. This central repo should only absorb the parts that change how work should be done elsewhere, then push the improved defaults back out.
