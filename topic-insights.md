# Topic Insights

Insights, lessons, and patterns discovered while building the agentic-workflows harness.

## Key Learnings

- **Deterministic by default**: Every gate and check starts as a script. Only promote to deliberative when evidence proves judgment is required.
- **Phase discipline works**: The research→plan→implement→verify cycle prevents skipping directly to code. Each phase has bounded scope and exit criteria.
- **Goal tree as north star**: Hierarchical goal tracking (`goal-tree.sh`) makes progress visible and prevents scope creep. The tree is the source of truth for what's active.

## Transferable Lessons

- Propagate workflow patterns before extension code. The harness (agentic-workflows) is the proving ground; Pi-Star is the extension target.
- Quality standards only work when enforced by a gate. A doc without a check is aspirational.
- Session handover automation (`generate-handover.sh`) replaces the "what did I do last time?" problem with a data-driven generated summary.
- Supply missing structure when safe — the core operating principle of the AGENTS.md contract.

## Mistakes To Avoid Repeating

- **Audit scripts should handle frontmatter**: The original H1 check used `head -n1`, which failed on files with YAML frontmatter or leading HTML comments. Always test against real file structures.
- **Quality gate at commit-only is too late**: The `quality-gate.sh` hook was only called by `checkpoint-commit.sh`, meaning quality issues could fester through research and plan phases. Quality should be checked at every phase transition.
- **Scripts are the right first approach**: Before building deliberative/human-in-loop checks, write a deterministic script first. If it can be automated, it should be.

## Update Rule

When a new insight is discovered, add it here before continuing similar work.
