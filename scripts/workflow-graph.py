#!/usr/bin/env python3
"""
workflow-graph.py --- Generate an interactive Workflow DAG for the
agentic-workflows orchestration pipeline.

Shows ALL workflows:
  · Main Phase Pipeline (Intake → Research → Plan → Implement → Verify → Session → Close)
  · Propagation Workflow (command sync + template → topic folders)
  · Decision Pipeline (phase transition gates with decision chains)
  · Agent Dispatch (async fan-out to pi/codex/claude)
  · Pipeline Run (sequenced task dispatch)
  · Session Lifecycle (checkpoint, fork, handoff, resume)
  · Counsel / Parley (multi-perspective review)
  · Skill System (progressive loading)

Usage: python3 scripts/workflow-graph.py [output.html]
Default output: workflow-graph.html

Data sources:
  - scripts/tools.toml              (tool categories, phases, quality gates)
  - scripts/propagation-contract.sh (managed core + repo-owned entries)
  - scripts/decision-pipeline.sh    (phase transition chains)
  - propagate-to-all.sh / sync-commands.sh / check-sync-status.sh
"""

import json
import os
import re
import sys
from pathlib import Path


# ═══════════════════════════════════════════════════════════════════════
# LIVE DATA EXTRACTION
# ═══════════════════════════════════════════════════════════════════════

def parse_tools_toml():
    """Extract tool entries grouped by category from tools.toml."""
    repo_root = Path(__file__).resolve().parent.parent
    tools_file = repo_root / "scripts" / "tools.toml"
    if not tools_file.exists():
        return {"tools": [], "by_category": {}}

    with open(tools_file) as f:
        content = f.read()

    tools = []
    current = {}
    for line in content.split("\n"):
        if line.startswith("[[tool]]"):
            if current and "name" in current:
                tools.append(current)
            current = {}
        elif m := re.search(r'name\s*=\s*"(.+)"', line):
            current["name"] = m.group(1)
        elif m := re.search(r'description\s*=\s*"(.+)"', line):
            current["description"] = m.group(1)
        elif m := re.search(r'category\s*=\s*"(.+)"', line):
            current["category"] = m.group(1)
        elif "phases" in line:
            phases = re.findall(r'"(\w+)"', line)
            if phases:
                current["phases"] = phases
    if current and "name" in current:
        tools.append(current)

    by_cat = {}
    for t in tools:
        cat = t.get("category", "other")
        by_cat.setdefault(cat, []).append(t)
    return {"tools": tools, "by_category": by_cat}


def parse_propagation_contract():
    """Get managed core and repo-owned entry counts."""
    repo_root = Path(__file__).resolve().parent.parent
    pc_file = repo_root / "scripts" / "propagation-contract.sh"
    if not pc_file.exists():
        return {"managed": 0, "repo_owned": 0}

    with open(pc_file) as f:
        content = f.read()

    managed = re.findall(r'"(command/[^"]+|pi/[^"]+|claude[^"]+|[a-z][^"]+\.template\.(?:sh|md|json):[^"]+)"', content)
    repo_owned_match = re.findall(r'"(topic-insights|session-state|\.cleanup-protect|history-index|history-full-detailed)\.[^"]+:[^"]+"', content)

    return {
        "managed": len(managed),
        "repo_owned": len(repo_owned_match),
        "total_pairs": len(managed) + len(repo_owned_match),
    }


def get_template_counts():
    """Count template files on disk."""
    repo_root = Path(__file__).resolve().parent.parent
    prop_dir = repo_root / "propagation"
    if not prop_dir.exists():
        return {"templates": 0, "command_templates": 0, "script_templates": 0}

    templates = []
    for root, _dirs, files in os.walk(prop_dir):
        for f in files:
            if ".template." in f:
                rel = os.path.relpath(os.path.join(root, f), prop_dir)
                templates.append(rel)

    cmd_tmpl = [t for t in templates if t.startswith("command/")]
    script_tmpl = [t for t in templates if t.endswith(".template.sh") and not t.startswith("command/")]

    return {
        "templates": len(templates),
        "command_templates": len(cmd_tmpl),
        "script_templates": len(script_tmpl),
    }


TOOLS_DATA = parse_tools_toml()
PROP_DATA = parse_propagation_contract()
TMPL_DATA = get_template_counts()


# ═══════════════════════════════════════════════════════════════════════
# COLOR PALETTE & STYLING
# ═══════════════════════════════════════════════════════════════════════

COLORS = {
    "phase":         {"bg": "#2D7D9A", "border": "#1F5B73", "hl": "#3A9FC2"},
    "gate":          {"bg": "#D4943A", "border": "#A87528", "hl": "#E8A838"},
    "decision":      {"bg": "#7B5EA7", "border": "#5C4280", "hl": "#9B74C9"},
    "branch":        {"bg": "#C74B4B", "border": "#9E3535", "hl": "#E06060"},
    "agent":         {"bg": "#3D9E6A", "border": "#2D7A50", "hl": "#4DBB80"},
    "script":        {"bg": "#5A7A9A", "border": "#405E7A", "hl": "#6F95BA"},
    "start_end":     {"bg": "#6A6A7A", "border": "#4E4E5E", "hl": "#82829A"},
    "harness":       {"bg": "#8A7A5A", "border": "#6B5E40", "hl": "#A89672"},
    "orchestrator":  {"bg": "#E8A838", "border": "#C98A2A", "hl": "#F0C060"},
    "source":        {"bg": "#2D7D9A", "border": "#1F5B73", "hl": "#3A9FC2"},
    "target":        {"bg": "#3D9E6A", "border": "#2D7A50", "hl": "#4DBB80"},
    "ownership":     {"bg": "#C74B4B", "border": "#9E3535", "hl": "#E06060"},
    "folder":        {"bg": "#5A7A9A", "border": "#405E7A", "hl": "#6F95BA"},
    "check":         {"bg": "#E8A838", "border": "#C98A2A", "hl": "#F0C060"},
    "pipeline":      {"bg": "#C74B4B", "border": "#9E3535", "hl": "#E06060"},
}

SHAPES = {
    "phase": "box", "gate": "diamond", "decision": "dot",
    "branch": "hexagon", "agent": "triangle", "script": "square",
    "start_end": "ellipse", "harness": "star", "orchestrator": "hexagon",
    "source": "box", "target": "box", "ownership": "diamond",
    "folder": "square", "check": "diamond", "pipeline": "box",
}

EDGE_STYLES = {
    "main_flow":    {"color": "rgba(200,220,240,0.5)", "w": 2.5},
    "gate_check":   {"color": "rgba(212,148,58,0.35)", "w": 1.2},
    "branch_to":    {"color": "rgba(199,75,75,0.4)", "w": 1.5},
    "dispatches":   {"color": "rgba(61,158,106,0.4)", "w": 1.0, "dash": True},
    "returns":      {"color": "rgba(150,150,170,0.3)", "w": 0.8, "dash": True},
    "syncs":        {"color": "rgba(45,125,154,0.5)", "w": 2.0},
    "propagates":   {"color": "rgba(61,158,106,0.5)", "w": 2.0},
    "checks":       {"color": "rgba(232,168,56,0.3)", "w": 1.0, "dash": True},
    "belongs_to":   {"color": "rgba(123,94,167,0.3)", "w": 0.8},
}


# ═══════════════════════════════════════════════════════════════════════
# GRAPH BUILDER
# ═══════════════════════════════════════════════════════════════════════

def vis_color(c):
    return {"background": c["bg"], "border": c["border"],
            "highlight": {"background": c["hl"], "border": "#FFFFFF"}}


def make_node(uid, label, group, **kw):
    c = COLORS.get(group, COLORS["script"])
    entry = {
        "id": uid, "label": label, "group": group,
        "shape": SHAPES.get(group, "dot"),
        "color": vis_color(c),
        "borderWidth": 2, "borderWidthSelected": 3,
        "font": {"face": "Inter, system-ui, sans-serif", "strokeWidth": 2,
                 "strokeColor": "rgba(0,0,0,0.5)", "color": "#f0f2f5"},
    }
    sz = {"phase": 28, "gate": 22, "decision": 14, "branch": 22, "agent": 18,
          "orchestrator": 26, "source": 24, "target": 24, "pipeline": 22,
          "folder": 18, "check": 20, "harness": 20}.get(group, 16)
    fs = {"phase": 12, "gate": 11, "branch": 10, "orchestrator": 12, "pipeline": 11,
          "source": 11, "target": 11, "harness": 10}.get(group, 9)
    if group in ("phase", "gate", "orchestrator", "pipeline", "source", "target"):
        entry["margin"] = {"top": 8, "bottom": 8, "left": 12, "right": 12}
    entry["size"] = sz
    entry["font"] = {**entry["font"], "size": fs}
    entry.update(kw)
    return entry


def make_edge(fr, to, style="main_flow", **kw):
    s = EDGE_STYLES.get(style, EDGE_STYLES["main_flow"])
    entry = {
        "from": fr, "to": to,
        "color": {"color": s["color"], "highlight": "#FFFFFF"},
        "width": s["w"],
        "smooth": {"type": "curvedCW", "roundness": 0.1},
        "arrows": {"to": {"enabled": True, "scaleFactor": 0.7}},
    }
    if s.get("dash"):
        entry["dashes"] = True
    entry.update(kw)
    return entry


# ═══════════════════════════════════════════════════════════════════════
# WORKFLOW DEFINITIONS
# ═══════════════════════════════════════════════════════════════════════

TOOL_COUNTS = {cat: len(tools) for cat, tools in TOOLS_DATA["by_category"].items()}


def build_all_workflows():
    nodes = []
    edges = []
    ids = set(); ekeys = set()

    def N(uid, label, group, **kw):
        if uid in ids: return
        ids.add(uid)
        nodes.append(make_node(uid, label, group, **kw))

    def E(fr, to, style="main_flow", **kw):
        k = (fr, to)
        if k in ekeys: return
        ekeys.add(k)
        edges.append(make_edge(fr, to, style, **kw))

    # ================================================================
    # 1. MAIN PHASE PIPELINE
    # ================================================================
    N("start", "Start", "start_end",
      desc="User states a goal or task in natural language",
      detail="Entry point. User provides a task description.\nTriggers Question Gate for automatic classification.")

    N("question-gate", "Question Gate", "gate",
      desc="Automatic intake: Detect → Assess → Explore → Decide",
      detail="Runs on every interaction.\n- Detect ambiguity (referential, scope, missing input)\n- Assess confidence, reversibility, cost\n- Explore codebase/docs\n- Decide: Act, Ask, or Offer Options")

    N("route", "Route / Intake", "phase",
      desc="Classify request → route to correct lane",
      tools="workflow-router.sh, task-intake.sh",
      detail="Routes normal-language request through deterministic intake.\nDetermines: lane, git safety, next action.\nOutputs: lane (research|direct|slice-first), git lane.")

    N("research", "Research", "phase",
      desc="Understand system before changing. Read, retrieve, map",
      tools="repo-map.sh, search-index.sh, blast-radius.sh, model-select.sh",
      detail="System understanding phase.\n- Read startup files\n- Retrieve relevant context\n- Identify exact files, dependencies, flow\n- Map macro-to-micro: system -> domain -> module -> root cause")

    N("research-gate", "Research Gate", "gate",
      desc="Gate: Research → Plan transition",
      detail="Decision chain gating Research to Plan transition.")

    N("plan", "Plan", "phase",
      desc="Turn research into steps with verification per step",
      tools="plan-guard.sh, plan-challenge.sh, milestone-shape.sh, task-slice.sh",
      detail="Planning phase.\n- Define exact files and verification per step\n- Milestone ladder + first-slice detail\n- CATFISH adversarial challenge to test the plan")

    N("plan-gate", "Plan Gate", "gate",
      desc="Gate: Plan → Implement transition (7 checks)",
      detail="Full decision chain before implementation.\n7 checks: model select, CATFISH, scope, comprehension, decisions, autonomy, preflight")

    N("implement", "Implement", "phase",
      desc="Execute plan in small verified slices",
      tools="implement-preflight.sh, pipeline-run.sh, agent-dispatch.sh, autopilot.sh",
      detail="Implementation phase.\n- Execute plan in small verified slices\n- Can dispatch sub-agents for parallel work\n- Commit after each verified phase")

    N("implement-gate", "Implement Gate", "gate",
      desc="Gate: Implement → Verify transition",
      detail="Quality-speed assessment before verification.")

    N("verify", "Verify", "phase",
      desc="Tests, scenarios, diff review. Verification is not optional",
      tools="test-smoke.sh, test-workflows.sh, counsel-run.sh, quality-readme-svg.sh",
      detail="Verification phase.\n- Run tests and scripted scenarios\n- Diff review\n- Document residual risk\n- Quality gates enforce standards")

    N("verify-gate", "Verify Gate", "gate",
      desc="Gate: Verify → Session transition",
      detail="Quality-speed check: full suite or smoke test?")

    N("session", "Session / Checkpoint", "phase",
      desc="Update state, commit, decide next",
      tools="checkpoint-commit.sh, context-save.sh, handoff.sh, session-status.sh",
      detail="Session management.\n- Update session-state.json\n- Commit verified work\n- Assess context pressure\n- Decide: continue, checkpoint, restart")

    N("close", "Close Task", "phase",
      desc="Classify task as fixed/obsolete/parked",
      tools="close-task.sh, finish-task.sh, task-retrospect.sh",
      detail="Task closure.\n- Classify: fixed, obsolete, or parked\n- Run retrospective\n- Extract learnings\n- Restart fresh for next task")

    N("end", "End", "start_end",
      desc="Task complete, ready for next task",
      detail="Terminal state.")

    # --- Main flow edges ---
    main_seq = ["start", "question-gate", "route", "research", "research-gate",
                "plan", "plan-gate", "implement", "implement-gate", "verify",
                "verify-gate", "session", "close", "end"]
    for i in range(len(main_seq) - 1):
        E(main_seq[i], main_seq[i + 1], "main_flow")

    # ================================================================
    # 2. GATE DECISION CHAINS
    # ================================================================
    gate_decisions = {
        "research-gate": [
            ("d-model-select-rg", "Model Select", "Classify task complexity -> select model tier", "scripts/model-select.sh"),
            ("d-sufficiency", "Research\nSufficiency", "Is research complete enough? Evidence check", "scripts/gates/research/sufficiency.sh"),
            ("d-scope-check-rg", "Scope Check", "Task scope properly bounded before planning?", "scripts/gates/plan/scope-check.sh"),
        ],
        "plan-gate": [
            ("d-model-select-pg", "Model Select", "Classify task -> select model for implementation", "scripts/model-select.sh"),
            ("d-catfish", "CATFISH\nChallenge", "Adversarial plan review. Challenge assumptions", "scripts/gates/plan/catfish.sh"),
            ("d-scope-check-pg", "Scope Check", "Scope clearly bounded before implementation?", "scripts/gates/plan/scope-check.sh"),
            ("d-comprehension", "Comprehension\nGate", "Verify comprehension evidence before editing", "scripts/gates/implement/comprehension.sh"),
            ("d-decisions", "Decisions\nCheck", "All required decisions made?", "scripts/gates/implement/decisions.sh"),
            ("d-autonomy", "Autonomy\nGate", "Risk-adjusted agent autonomy levels", "scripts/gates/implement/autonomy.sh"),
            ("d-preflight", "Preflight", "Implementation preflight checks", "scripts/gates/implement/preflight.sh"),
        ],
        "implement-gate": [
            ("d-quality-speed", "Quality\nSpeed", "Full test suite or smoke tests?", "scripts/gates/verify/quality-speed.sh"),
        ],
    }

    for gate_id, decisions in gate_decisions.items():
        prev = None
        for uid, label, desc, script in decisions:
            N(uid, label, "decision", desc=desc, script=script, parentGate=gate_id)
            E(gate_id, uid, "gate_check",
              hidden=True,  # hidden by default, shown on expand
              smooth={"type": "curvedCW", "roundness": 0.15})
            if prev:
                E(prev, uid, "gate_check",
                  hidden=True,
                  smooth={"type": "curvedCW", "roundness": 0.12})
            prev = uid

    # ================================================================
    # 3. PROPAGATION WORKFLOW
    # ================================================================
    N("propagate-sh", "propagate.sh\n(Unified Entry)", "orchestrator",
      desc="Unified entry for all sync + propagation operations",
      script="scripts/propagate.sh",
      detail="Entry:   bash scripts/propagate.sh status  (check sync status)\n"
             "         bash scripts/propagate.sh sync    (sync commands)\n"
             "         bash scripts/propagate.sh propagate --apply\n"
             "         bash scripts/propagate.sh all --apply (full pipeline)")

    N("p-status", "Status\n(Check Sync)", "pipeline",
      desc="Check propagation status across all topic folders",
      script="scripts/check-sync-status.sh")
    N("p-sync", "Sync\n(Command Sync)", "pipeline",
      desc="Sync commands/ -> .opencode/commands/ + .pi/prompts/",
      script="scripts/sync-commands.sh")
    N("p-propagate", "Propagate\n(Template -> Topics)", "pipeline",
      desc=f"Propagate {TMPL_DATA['templates']} templates to {PROP_DATA['managed'] + PROP_DATA['repo_owned']} file targets per topic folder",
      script="scripts/propagate-to-all.sh")
    N("p-all", "All\n(Sync + Propagate)", "pipeline",
      desc="Full pipeline: sync then propagate")

    E("propagate-sh", "p-status", "orchestrates")
    E("propagate-sh", "p-sync", "orchestrates")
    E("propagate-sh", "p-propagate", "orchestrates")
    E("propagate-sh", "p-all", "orchestrates")

    # --- Command sync details ---
    N("commands-dir", "commands/\n(14 .md files)", "source",
      desc="Single source of truth for all commands")
    N("target-opencode", ".opencode/commands/\n(14 mirrored)", "target",
      desc="OpenCode native slash commands", harness="OpenCode")
    N("target-pi", ".pi/prompts/\n(14 mirrored)", "target",
      desc="Pi coding-agent prompts", harness="Pi")
    N("target-claude-cursor", "Claude / Cursor\n(bash scripts/<name>.sh)", "harness",
      desc="Invoke commands directly as bash scripts. No file mirror needed.")

    E("p-sync", "commands-dir", "syncs")
    E("commands-dir", "target-opencode", "syncs")
    E("commands-dir", "target-pi", "syncs")
    E("commands-dir", "target-claude-cursor", "syncs",
      smooth={"type": "curvedCW", "roundness": 0.2})

    # --- Template propagation details ---
    N("propagation-dir", f"propagation/\n({TMPL_DATA['templates']} template files)", "source",
      desc="Template source directory. All templates are the SSOT for propagated files.")

    tmpl_groups = [
        ("tmpl-config", "Config\ntemplates", f"AGENTS.md, CLAUDE.md, settings"),
        ("tmpl-commands", f"Command\ntemplates", f"{TMPL_DATA['command_templates']} command .md templates"),
        ("tmpl-scripts", f"Script\ntemplates", f"{TMPL_DATA['script_templates']} .sh templates"),
        ("tmpl-pi", f"Pi config\n(16 targets)", f"Pi prompts, settings, workflow guard"),
        ("tmpl-claude", f"Claude hooks\n(4 targets)", "session-context, dangerous-command-guard, testing rules"),
    ]
    for tid, tlabel, tdesc in tmpl_groups:
        N(tid, tlabel, "script", desc=tdesc)
        E("propagation-dir", tid, "belongs_to")

    N("own-managed", f"Managed Core\n(hub-owned, auto-refresh)", "ownership",
      desc=f"{PROP_DATA['managed']} file targets per topic folder. Hub can overwrite.",
      count=PROP_DATA["managed"])
    N("own-repo", f"Repo-Owned\n(created once, yours to edit)", "ownership",
      desc=f"{PROP_DATA['repo_owned']} bootstrap files per folder. Created from template, then owned locally.",
      count=PROP_DATA["repo_owned"])

    for tid, _, _ in tmpl_groups:
        E(tid, "own-managed", "ownership")
    N("tmpl-bootstrap", "Bootstrap\ntemplates", "script",
      desc=f"{PROP_DATA['repo_owned']} bootstrap file templates")
    E("propagation-dir", "tmpl-bootstrap", "belongs_to")
    E("tmpl-bootstrap", "own-repo", "ownership")

    N("topic-folders", f"Topic Folders\n(14 active siblings)", "folder",
      desc="Sibling directories that participate in propagation. Each gets managed core + bootstrap files.",
      count=14)
    N("folder-agents", "  Per folder:\nAGENTS.md + CLAUDE.md", "target",
      desc="Every topic folder gets the full agent operating contract.")
    N("folder-scripts", "  Per folder:\npropagated/*.sh", "target",
      desc=f"~{TMPL_DATA['script_templates']} propagated shell scripts per topic folder")
    N("folder-commands", "  Per folder:\ncommands/ + .opencode/", "target",
      desc="Command files mirrored to all harness targets")

    E("own-managed", "topic-folders", "propagates")
    E("own-repo", "topic-folders", "propagates")
    E("topic-folders", "folder-agents", "propagates",
      smooth={"type": "curvedCW", "roundness": 0.12})
    E("topic-folders", "folder-scripts", "propagates",
      smooth={"type": "curvedCW", "roundness": 0.12})
    E("topic-folders", "folder-commands", "propagates",
      smooth={"type": "curvedCW", "roundness": 0.12})

    # --- Status check details ---
    N("check-status", "Sync Status\n(Drift Detection)", "check",
      desc=f"Compares propagation/ templates against topic folder targets. Reports: OK | DRIFT | MISSING | ARTIFACT",
      script="scripts/check-sync-status.sh")
    N("st-ok", "✅ OK\n(matched)", "check", desc="Template and target match exactly. No action.")
    N("st-drift", "⚠️ DRIFT\n(template != target)", "check",
      desc="Template and target differ. Run propagate --apply to refresh.")
    N("st-missing", "❌ MISSING\n(target doesn't exist)", "check",
      desc="Template has no target. Run propagate --apply to create.")
    N("st-artifact", "🗑 ARTIFACT\n(legacy files)", "check",
      desc="Legacy files (.ps1, etc.) found. Manual cleanup needed.")

    E("check-status", "st-ok", "checks")
    E("check-status", "st-drift", "checks")
    E("check-status", "st-missing", "checks")
    E("check-status", "st-artifact", "checks")
    E("p-status", "check-status", "orchestrates")

    # ================================================================
    # 4. AGENT DISPATCH WORKFLOW
    # ================================================================
    N("agent-dispatch", "Agent Dispatch\n(Fan-out)", "branch",
      desc="Fire-and-forget tasks to external coding agents. run/status/list/cancel/log",
      script="scripts/agent-dispatch.sh",
      detail="Async agent task dispatcher.\n"
             "Agents: pi-coding-agent, Codex CLI, Claude Code\n"
             "Lifecycle: run -> status -> list -> cancel -> log\n"
             "Optional sandbox isolation via agent-sandbox.sh")

    N("agent-pi", "pi-coding-agent", "agent",
      desc="Pi coding agent backend. Default dispatch target.")
    N("agent-codex", "Codex CLI", "agent",
      desc="OpenAI Codex CLI backend (requires npm install -g @openai/codex)")
    N("agent-claude", "Claude Code", "agent",
      desc="Anthropic Claude Code backend (requires npm install -g @anthropic/claude-code)")
    N("agent-sandbox", "Sandbox\n(bwrap + Docker)", "script",
      desc="Run agent operations in isolated environment",
      script="scripts/agent-sandbox.sh")

    N("ship-fanout", "/ship Fan-out\n(Parallel)", "branch",
      desc="Parallel dispatch to code-reviewer + security-auditor + test-engineer",
      detail="Canonical fan-out pattern:\n"
             "  -> code-reviewer (review report)\n"
             "  -> security-auditor (audit report)\n"
             "  -> test-engineer (coverage report)\n"
             "  -> merge phase -> go/no-go decision")

    N("agent-reviewer", "code-reviewer\npersona", "agent",
      desc="Senior Staff Engineer. Five-axis PR review",
      persona="agents/code-reviewer.md")
    N("agent-security", "security-auditor\npersona", "agent",
      desc="Security Engineer. OWASP vulnerability audit",
      persona="agents/security-auditor.md")
    N("agent-testeng", "test-engineer\npersona", "agent",
      desc="QA Engineer. Test strategy + coverage analysis",
      persona="agents/test-engineer.md")

    N("agent-planner", "planner persona", "agent",
      desc="Staff Engineer. Feature decomposition + milestone planning",
      persona="agents/planner.md")

    E("implement", "agent-dispatch", "branch_to")
    E("agent-dispatch", "agent-pi", "dispatches")
    E("agent-dispatch", "agent-codex", "dispatches")
    E("agent-dispatch", "agent-claude", "dispatches")
    E("agent-dispatch", "agent-sandbox", "dispatches")
    E("agent-pi", "implement", "returns", smooth={"type": "curvedCW", "roundness": 0.2})
    E("agent-codex", "implement", "returns", smooth={"type": "curvedCW", "roundness": 0.22})
    E("agent-claude", "implement", "returns", smooth={"type": "curvedCW", "roundness": 0.24})

    E("implement", "ship-fanout", "branch_to",
      smooth={"type": "curvedCW", "roundness": 0.15})
    E("ship-fanout", "agent-reviewer", "dispatches")
    E("ship-fanout", "agent-security", "dispatches")
    E("ship-fanout", "agent-testeng", "dispatches")
    E("agent-reviewer", "implement", "returns", smooth={"type": "curvedCW", "roundness": 0.2})
    E("agent-security", "implement", "returns", smooth={"type": "curvedCW", "roundness": 0.22})
    E("agent-testeng", "implement", "returns", smooth={"type": "curvedCW", "roundness": 0.24})

    # ================================================================
    # 5. PIPELINE RUN (SEQUENCED DISPATCH)
    # ================================================================
    N("pipeline-run", "Pipeline Run\n(Sequenced)", "branch",
      desc="Subagent pipeline state manager. Dispatch -> implement -> review -> integrate",
      script="scripts/pipeline-run.sh",
      detail="Sequenced task dispatch.\n"
             "Commands: init, list, status, update, next\n"
             "Each task dispatched to isolated @worker subagent\n"
             "on_error: abort | continue | retry:N\n"
             "Tracks progress across task sequence")

    N("worker-subagent", "@worker\nsub-agent", "agent",
      desc="Fresh-context worker for implementation slices.\nFull tool access.")
    N("explore-subagent", "@explore\nsub-agent", "agent",
      desc="Read-only bulk discovery sub-agent.\nRead-only tools only.")
    N("review-subagent", "@review\nsub-agent", "agent",
      desc="Review sub-agent. Reads diffs, checks for bugs/regressions.")

    N("pipeline-plan", "Plan -> Tasks", "script",
      desc="Steps: 1. Parse plan 2. Create tasks 3. Assign workers")
    N("pipeline-dispatch", "Dispatch -> Workers", "script",
      desc="Steps: 1. Dispatch task 2. Wait/collect 3. Log result")
    N("pipeline-review", "Review -> Integrate", "script",
      desc="Steps: 1. Review result 2. Integrate changes 3. Next task")

    E("implement", "pipeline-run", "branch_to",
      smooth={"type": "curvedCW", "roundness": 0.12})
    E("pipeline-run", "pipeline-plan", "syncs")
    E("pipeline-plan", "pipeline-dispatch", "main_flow")
    E("pipeline-dispatch", "pipeline-review", "main_flow")
    E("pipeline-dispatch", "worker-subagent", "dispatches")
    E("pipeline-dispatch", "explore-subagent", "dispatches")
    E("pipeline-dispatch", "review-subagent", "dispatches")
    E("worker-subagent", "pipeline-review", "returns",
      smooth={"type": "curvedCW", "roundness": 0.2})
    E("pipeline-review", "implement", "returns",
      smooth={"type": "curvedCW", "roundness": 0.18})

    # ================================================================
    # 6. AUTOPILOT AUTONOMOUS LOOP
    # ================================================================
    N("autopilot", "Autopilot\n(Loop)", "branch",
      desc="Autonomous goal execution loop. plan -> implement -> verify -> checkpoint",
      script="scripts/autopilot.sh",
      detail="Cycles autonomously:\nplan -> implement -> verify -> checkpoint\n"
             "Repeats until goal is met or boundaries exceeded.")

    N("auto-plan", "Auto\nPlan", "pipeline", desc="Autonomous planning from goal")
    N("auto-implement", "Auto\nImplement", "pipeline", desc="Autonomous implementation")
    N("auto-verify", "Auto\nVerify", "pipeline", desc="Autonomous verification")
    N("auto-checkpoint", "Auto\nCheckpoint", "pipeline", desc="Auto commit + session save")

    E("implement", "autopilot", "branch_to",
      smooth={"type": "curvedCW", "roundness": 0.1})
    E("autopilot", "auto-plan", "orchestrates")
    E("auto-plan", "auto-implement", "main_flow")
    E("auto-implement", "auto-verify", "main_flow")
    E("auto-verify", "auto-checkpoint", "main_flow")
    E("auto-checkpoint", "auto-plan", "returns",
      smooth={"type": "curvedCW", "roundness": 0.3})

    # ================================================================
    # 7. COUNSEL & PARLEY
    # ================================================================
    N("counsel", "Counsel\n(Multi-Perspective)", "branch",
      desc=f"Multi-model perspective review. {TOOL_COUNTS.get('comms', 0)} comms tools",
      script="scripts/counsel-gate.sh",
      detail="Get independent challenge on:\n- Product shaping\n- Milestone selection\n- Architecture\n- Tradeoffs\n\nRuns multiple model perspectives.")

    N("parley", "Parley\n(Multi-Agent Chat)", "branch",
      desc="Sequential conversation between free AI agents via OpenRouter",
      script="scripts/parley.sh",
      detail="Multi-agent conversation for:\n- Broad exploration\n- Decision debates\n- Council-style advice\n\nAgents converse sequentially via OpenRouter.")

    N("counsel-gate", "Counsel Gate", "check",
      desc="Decide when multi-perspective review is worth the cost",
      script="scripts/counsel-gate.sh")
    N("counsel-run", "Counsel Run", "script",
      desc=f"Run multi-model counsel (OpenRouter-backed)",
      script="scripts/counsel-run.sh")
    N("counsel-model", "Model Select", "script",
      desc="Select appropriate model for counsel",
      script="scripts/counsel-model-select.sh")

    E("plan", "counsel", "branch_to",
      smooth={"type": "curvedCW", "roundness": 0.1})
    E("plan", "parley", "branch_to",
      smooth={"type": "curvedCW", "roundness": 0.12})
    E("counsel", "counsel-gate", "checks")
    E("counsel-gate", "counsel-run", "syncs")
    E("counsel-gate", "counsel-model", "syncs")
    E("counsel-run", "plan", "returns",
      smooth={"type": "curvedCW", "roundness": 0.18})
    E("parley", "plan", "returns",
      smooth={"type": "curvedCW", "roundness": 0.18})

    # ================================================================
    # 8. SESSION LIFECYCLE
    # ================================================================
    N("session-lifecycle", "Session Lifecycle", "branch",
      desc="Session state, checkpoint, fork, handoff, restore",
      detail=f"Session management tools ({TOOL_COUNTS.get('session', 0)} tools):\n"
             "checkpoint-commit, context-save, context-restore,\n"
             "session-status, session-fork, handoff, session-boundary")

    N("session-checkpoint", "Checkpoint\nCommit", "pipeline",
      desc="Create verified local checkpoint commit. Quality gate + atomic commit",
      script="scripts/checkpoint-commit.sh")
    N("session-fork", "Session Fork\n(Worktree)", "pipeline",
      desc="Fork into isolated worktree branch for parallel/risky work",
      script="scripts/session-fork.sh")
    N("session-handoff", "Handoff\n(Continuation)", "pipeline",
      desc="Build compact continuation packet for session switch",
      script="scripts/handoff.sh")
    N("session-restore", "Context\nRestore", "pipeline",
      desc="Restore working context from saved snapshot",
      script="scripts/context-restore.sh")
    N("session-pressure", "Context\nPressure", "check",
      desc="Session health monitor. Detects context rot (age, dirt, commits)",
      script="scripts/context-pressure.sh")

    E("session", "session-lifecycle", "branch_to")
    E("session-lifecycle", "session-checkpoint", "orchestrates")
    E("session-lifecycle", "session-fork", "orchestrates")
    E("session-lifecycle", "session-handoff", "orchestrates")
    E("session-lifecycle", "session-restore", "orchestrates")
    E("session-lifecycle", "session-pressure", "checks")
    E("session-checkpoint", "session", "returns",
      smooth={"type": "curvedCW", "roundness": 0.2})
    E("session-handoff", "route", "returns",
      smooth={"type": "curvedCW", "roundness": 0.25})

    N("session-fork-wt", "Worktree Branch\n(isolated copy)", "target",
      desc="Isolated worktree for parallel task work.\nSafe experimentation without affecting main session.")
    E("session-fork", "session-fork-wt", "syncs")
    E("session-fork-wt", "session", "returns",
      smooth={"type": "curvedCW", "roundness": 0.25})

    # ================================================================
    # 9. TOOL LANDSCAPE OVERVIEW
    # ================================================================
    N("tool-landscape", f"Tool Landscape\n({TOOL_COUNTS.get('workflow', 0) + TOOL_COUNTS.get('quality', 0) + TOOL_COUNTS.get('session', 0)} core tools)", "orchestrator",
      desc=f"Workflow tools: {TOOL_COUNTS.get('workflow', 0)} | Quality: {TOOL_COUNTS.get('quality', 0)} | Session: {TOOL_COUNTS.get('session', 0)} | Research: {TOOL_COUNTS.get('research', 0)} | Agent: {TOOL_COUNTS.get('agent', 0)}",
      detail=f"Total registered tools: {sum(TOOL_COUNTS.values())}\n"
             f"Categories:\n" +
             "\n".join(f"  {cat}: {cnt}" for cat, cnt in sorted(TOOL_COUNTS.items(), key=lambda x: -x[1])))

    cat_nodes = []
    for cat in ["workflow", "quality", "session", "research", "agent", "skill", "memory", "safety", "git"]:
        cnt = TOOL_COUNTS.get(cat, 0)
        if cnt:
            uid = f"cat-{cat}"
            N(uid, f"{cat}\n({cnt} tools)", "script", desc=f"{cnt} {cat} tools registered in tools.toml")
            E("tool-landscape", uid, "belongs_to")
            cat_nodes.append(uid)

    # Tool landscape -> feeds into main pipeline
    E("tool-landscape", "route", "syncs",
      smooth={"type": "curvedCW", "roundness": 0.15})

    return nodes, edges


# ═══════════════════════════════════════════════════════════════════════
# HTML GENERATION
# ═══════════════════════════════════════════════════════════════════════

HTML = r'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Agentic Workflows — Workflow DAG</title>
<script src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"></script>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    background: radial-gradient(ellipse at 50% 30%, #0f1622, #07090e);
    color: #e1e4e8; overflow: hidden; height: 100vh;
  }
  #graph { width: 100%; height: 100vh; position: absolute; top: 0; left: 0; }

  .top-bar {
    position: fixed; top: 0; left: 0; right: 0; z-index: 100;
    padding: 12px 20px;
    background: linear-gradient(180deg, rgba(7,9,14,0.95) 50%, transparent);
    display: flex; align-items: center; gap: 10px; pointer-events: none;
  }
  .top-bar h1 { font-size: 15px; font-weight: 600; color: #f0f2f5; letter-spacing: -0.2px; }
  .top-bar .subtitle { font-size: 11px; color: #8b949e; }
  .top-bar .badge {
    font-size: 9px; padding: 2px 7px; border-radius: 20px;
    background: rgba(45,125,154,0.12); color: #58a6ff;
    border: 1px solid rgba(45,125,154,0.2); font-weight: 500;
  }

  .controls {
    position: fixed; top: 10px; right: 14px; z-index: 100;
    display: flex; gap: 5px; pointer-events: all;
  }
  .ctrl-btn {
    width: 28px; height: 28px; border-radius: 5px;
    border: 1px solid rgba(255,255,255,0.06);
    background: rgba(22,27,34,0.85); backdrop-filter: blur(8px);
    color: #8b949e; font-size: 12px; cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: all 0.15s;
  }
  .ctrl-btn:hover { background: rgba(255,255,255,0.08); color: #f0f2f5; }
  .ctrl-btn.active { color: #58a6ff; border-color: rgba(88,166,255,0.3); }

  .search-box {
    position: fixed; top: 10px; left: 50%; transform: translateX(-50%);
    z-index: 100; width: 200px; pointer-events: all;
  }
  .search-box input {
    width: 100%; padding: 6px 12px;
    background: rgba(22,27,34,0.9); backdrop-filter: blur(12px);
    border: 1px solid rgba(255,255,255,0.06); border-radius: 7px;
    color: #f0f2f5; font-size: 11px; outline: none; text-align: center;
    transition: all 0.2s;
  }
  .search-box input:focus { border-color: rgba(255,255,255,0.15); }
  .search-box input::placeholder { color: #8b949e; }

  .legend {
    position: fixed; bottom: 14px; left: 14px; z-index: 100;
    background: rgba(22,27,34,0.92); backdrop-filter: blur(14px);
    border: 1px solid rgba(255,255,255,0.06); border-radius: 10px;
    padding: 10px 12px; font-size: 10px; min-width: 110px; user-select: none;
  }
  .legend h3 { font-size: 8px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.08em; color: #8b949e; margin-bottom: 5px; }
  .legend-item { display: flex; align-items: center; gap: 5px; padding: 1px 3px; cursor: pointer; border-radius: 3px; transition: background 0.15s; }
  .legend-item:hover { background: rgba(255,255,255,0.05); }
  .legend-dot { width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0; }
  .legend-label { color: #c9d1d9; font-size: 10px; flex: 1; }
  .legend-edge-section { margin-top: 5px; padding-top: 5px; border-top: 1px solid rgba(255,255,255,0.06); }
  .legend-edge-item { display: flex; align-items: center; gap: 5px; padding: 1px 3px; }
  .edge-swatch { display: inline-block; width: 14px; height: 0; flex-shrink: 0; }
  .edge-swatch.main { border-top: 2px solid rgba(200,220,240,0.5); }
  .edge-swatch.gate { border-top: 2px solid rgba(212,148,58,0.35); }
  .edge-swatch.branch { border-top: 2px dashed rgba(199,75,75,0.4); }
  .edge-swatch.dispatch { border-top: 1.5px dotted rgba(61,158,106,0.4); }
  .edge-swatch.sync { border-top: 2px solid rgba(45,125,154,0.5); }
  .edge-swatch.rtn { border-top: 1px dashed rgba(150,150,170,0.4); }

  .stats {
    position: fixed; bottom: 14px; right: 14px; z-index: 100;
    background: rgba(22,27,34,0.92); backdrop-filter: blur(14px);
    border: 1px solid rgba(255,255,255,0.06); border-radius: 10px;
    padding: 10px 14px; font-size: 10px; text-align: right;
    line-height: 1.6; pointer-events: none;
  }
  .stats span { color: #8b949e; }
  .stats strong { color: #f0f2f5; font-weight: 600; }

  .info-panel {
    position: fixed; top: 50px; right: 50px; z-index: 100;
    background: rgba(22,27,34,0.94); backdrop-filter: blur(16px);
    border: 1px solid rgba(255,255,255,0.08); border-radius: 10px;
    padding: 12px 14px; font-size: 11px; max-width: 240px;
    display: none; transition: all 0.25s; pointer-events: all;
  }
  .info-panel.visible { display: block; animation: fadeSlide 0.2s ease; }
  @keyframes fadeSlide { from { opacity: 0; transform: translateY(-3px); } to { opacity: 1; transform: translateY(0); } }
  .info-panel .node-type { font-size: 8px; text-transform: uppercase; letter-spacing: 0.08em; color: #8b949e; margin-bottom: 3px; }
  .info-panel .node-name { font-size: 14px; font-weight: 600; margin-bottom: 2px; }
  .info-panel .node-desc { color: #c9d1d9; font-size: 10px; margin-bottom: 4px; line-height: 1.5; }
  .info-panel .node-meta { color: #8b949e; font-size: 9px; line-height: 1.5; word-break: break-all; white-space: pre-wrap; }

  .expand-btn {
    margin-top: 6px; padding: 4px 10px;
    border: 1px solid rgba(255,255,255,0.1); border-radius: 4px;
    background: rgba(255,255,255,0.05); color: #c9d1d9;
    font-size: 10px; cursor: pointer; transition: all 0.15s;
    display: none;
  }
  .expand-btn:hover { background: rgba(255,255,255,0.1); }
  .expand-btn.visible { display: inline-block; }

  .physics-indicator {
    position: fixed; bottom: 62px; right: 16px; z-index: 100;
    font-size: 8px; color: #484f58; pointer-events: none; text-align: right;
  }
  .physics-indicator .dot { display: inline-block; width: 4px; height: 4px; border-radius: 50%; margin-right: 3px; vertical-align: middle; }
  .physics-indicator .dot.alive { background: #3fb950; box-shadow: 0 0 3px rgba(63,185,80,0.4); }
  .physics-indicator .dot.frozen { background: #484f58; }

  .loading {
    position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
    text-align: center; z-index: 1; color: #8b949e; font-size: 12px;
  }
  .loading .spinner {
    width: 20px; height: 20px;
    border: 2px solid rgba(255,255,255,0.06); border-top-color: #58a6ff;
    border-radius: 50%; animation: spin 0.8s linear infinite;
    margin: 0 auto 6px;
  }
  @keyframes spin { to { transform: rotate(360deg); } }

  .zoom-hint {
    position: fixed; bottom: 62px; left: 16px; z-index: 100;
    font-size: 8px; color: #484f58; pointer-events: none;
  }
</style>
</head>
<body>

<div class="loading" id="loading">
  <div class="spinner"></div>
  <p>Building Workflow DAG...</p>
</div>

<div class="top-bar">
  <h1>Workflow DAG</h1>
  <span class="subtitle">· agentic-workflows</span>
  <span class="badge">all workflows</span>
</div>

<div class="controls">
  <button class="ctrl-btn" id="btnFreeze" title="Toggle physics">⟳</button>
  <button class="ctrl-btn" id="btnFit" title="Fit to view">⊞</button>
</div>

<div class="search-box">
  <input type="text" id="search" placeholder="Search..." spellcheck="false" />
</div>

<div class="info-panel" id="infoPanel">
  <div class="node-type" id="infoType"></div>
  <div class="node-name" id="infoName"></div>
  <div class="node-desc" id="infoDesc"></div>
  <div class="node-meta" id="infoMeta"></div>
  <button class="expand-btn" id="expandBtn">Toggle gate detail</button>
</div>

<div id="graph"></div>

<div class="legend">
  <h3>Node Types</h3>
  __LEGEND__
  <div class="legend-edge-section">
    <div class="legend-edge-item"><span class="edge-swatch main"></span><span class="legend-label">Phase flow</span></div>
    <div class="legend-edge-item"><span class="edge-swatch gate"></span><span class="legend-label">Gate check</span></div>
    <div class="legend-edge-item"><span class="edge-swatch branch"></span><span class="legend-label">Branch flow</span></div>
    <div class="legend-edge-item"><span class="edge-swatch dispatch"></span><span class="legend-label">Agent dispatch</span></div>
    <div class="legend-edge-item"><span class="edge-swatch sync"></span><span class="legend-label">Sync / propagate</span></div>
    <div class="legend-edge-item"><span class="edge-swatch rtn"></span><span class="legend-label">Return</span></div>
  </div>
</div>

<div class="stats">
  <span><strong id="nodeCount">0</strong> nodes</span>
  <span><strong id="edgeCount">0</strong> edges</span>
</div>

<div class="physics-indicator" id="physicsIndicator">
  <span class="dot alive" id="physicsDot"></span><span id="physicsLabel">alive</span>
</div>
<div class="zoom-hint">Scroll to zoom · Drag to pan · Click for info</div>

<script>
(function() {
  const NODES = __NODES__;
  const EDGES = __EDGES__;

  const container = document.getElementById('graph');
  if (!NODES || NODES.length === 0) {
    document.getElementById('loading').innerHTML = '<p>No workflow data found.</p>';
    return;
  }

  document.getElementById('loading').style.display = 'none';
  document.getElementById('nodeCount').textContent = NODES.length;
  document.getElementById('edgeCount').textContent = EDGES.length;

  // Separate hidden edges (gate decision chains)
  const visibleEdges = EDGES.filter(function(e) { return !e.hidden; });
  const hiddenEdges = EDGES.filter(function(e) { return e.hidden; });
  let expandedGateId = null;

  const data = {
    nodes: new vis.DataSet(NODES),
    edges: new vis.DataSet(visibleEdges)
  };

  const options = {
    physics: {
      stabilization: { iterations: 250 },
      solver: 'forceAtlas2Based',
      forceAtlas2Based: {
        gravitationalConstant: -28, centralGravity: 0.003,
        springLength: 170, springConstant: 0.035, damping: 0.5,
      },
      adaptiveTimestep: true, maxVelocity: 18,
    },
    edges: { smooth: { type: 'curvedCW', roundness: 0.08 } },
    interaction: { hover: true, tooltipDelay: 150, keyboard: true },
  };

  const network = new vis.Network(container, data, options);
  let physicsFrozen = false;

  network.once('stabilizationIterationsDone', function() {
    network.setOptions({
      physics: {
        forceAtlas2Based: {
          gravitationalConstant: -6, centralGravity: 0.0008,
          springLength: 210, springConstant: 0.004, damping: 0.85,
        },
        minVelocity: 0.001, maxVelocity: 1,
      }
    });
    network.fit({ animation: true, duration: 300 });
  });

  // Hover highlight
  network.on('hoverNode', function(params) {
    const connected = network.getConnectedEdges(params.node);
    const connSet = new Set(connected);
    EDGES.forEach(function(e, i) {
      if (!e._origColor) { e._origColor = JSON.parse(JSON.stringify(e.color)); e._origWidth = e.width; }
      const isC = connSet.has(i);
      e.color = isC ? { color: (e._origColor.color || '').replace(/[\d.]+(?=\))/, '0.8') } : { color: 'rgba(255,255,255,0.02)' };
      e.width = isC ? (e._origWidth || 1) * 2.0 : 0.2;
    });
    data.edges.update(EDGES.filter(function(e) { return !e.hidden; }));
  });

  network.on('blurNode', function() {
    EDGES.forEach(function(e) {
      if (e._origColor) e.color = JSON.parse(JSON.stringify(e._origColor));
      if (e._origWidth) e.width = e._origWidth;
    });
    data.edges.update(EDGES.filter(function(e) { return !e.hidden; }));
  });

  // Freeze
  document.getElementById('btnFreeze').addEventListener('click', function() {
    physicsFrozen = !physicsFrozen;
    network.setOptions({ physics: !physicsFrozen });
    this.classList.toggle('active');
    document.getElementById('physicsDot').className = physicsFrozen ? 'dot frozen' : 'dot alive';
    document.getElementById('physicsLabel').textContent = physicsFrozen ? 'frozen' : 'alive';
  });

  document.getElementById('btnFit').addEventListener('click', function() {
    network.fit({ animation: true, duration: 300 });
  });

  // Search
  let searchTimeout;
  const searchInput = document.getElementById('search');
  searchInput.addEventListener('input', function() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
      const q = this.value.toLowerCase().trim();
      if (!q) { network.selectNodes([]); return; }
      const hits = NODES.filter(function(n) {
        return n.label.toLowerCase().includes(q) ||
               (n.desc && n.desc.toLowerCase().includes(q));
      });
      if (hits.length > 0) {
        network.selectNodes(hits.map(function(n) { return n.id; }), false);
        network.focus(hits[0].id, { scale: 1.4, animation: true });
      }
    }, 150);
  });

  // Click info + gate expand
  network.on('click', function(params) {
    const panel = document.getElementById('infoPanel');
    if (params.nodes.length > 0) {
      const node = NODES.find(function(n) { return n.id === params.nodes[0]; });
      if (node) {
        document.getElementById('infoType').textContent = node.group || '';
        document.getElementById('infoName').textContent = node.label;
        document.getElementById('infoDesc').textContent = node.desc || '';
        let meta = '';
        if (node.tools) meta += '🛠 ' + node.tools + '\\n';
        if (node.script) meta += '📜 ' + node.script + '\\n';
        if (node.detail) meta += '\\n' + node.detail;
        if (node.persona) meta += '👤 ' + node.persona + '\\n';
        if (node.harness) meta += '⚡ ' + node.harness + '\\n';
        if (node.count !== undefined) meta += '📊 ' + node.count + ' items\\n';
        document.getElementById('infoMeta').textContent = meta;

        // Expand button for gates with hidden decision children
        const expandBtn = document.getElementById('expandBtn');
        const hasHidden = hiddenEdges.some(function(e) { return e.from === node.id; });
        if (node.group === 'gate' && hasHidden) {
          expandBtn.classList.add('visible');
          expandBtn.dataset.gateId = node.id;
          expandBtn.textContent = expandedGateId === node.id ? 'Hide gate detail' : 'Show gate decision chain';
        } else {
          expandBtn.classList.remove('visible');
        }

        panel.classList.add('visible');
      }
    } else {
      panel.classList.remove('visible');
    }
  });

  // Gate expansion
  document.getElementById('expandBtn').addEventListener('click', function() {
    const gateId = this.dataset.gateId;
    if (!gateId) return;

    function isDescendant(id, parent) {
      return hiddenEdges.some(function(e) { return e.to === id && e.from === parent; });
    }

    if (expandedGateId === gateId) {
      // Collapse
      const toRemove = [];
      hiddenEdges.forEach(function(e) {
        if (e.from === gateId || isDescendant(e.from, gateId)) {
          toRemove.push(e.from, e.to);
        }
      });
      data.nodes.remove([...new Set(toRemove)]);
      expandedGateId = null;
      this.textContent = 'Show gate decision chain';
    } else {
      // Collapse previous
      if (expandedGateId) {
        const prevRemove = [];
        hiddenEdges.forEach(function(e) {
          if (e.from === expandedGateId || isDescendant(e.from, expandedGateId)) {
            prevRemove.push(e.from, e.to);
          }
        });
        data.nodes.remove([...new Set(prevRemove)]);
      }

      // Expand
      const addNodes = []; const addEdges = [];
      hiddenEdges.forEach(function(e) {
        if (e.from === gateId || isDescendant(e.from, gateId)) {
          const childNode = NODES.find(function(n) { return n.id === e.to || n.id === e.from; });
          if (childNode && !data.nodes.get(childNode.id)) addNodes.push(childNode);
          addEdges.push(e);
        }
      });
      data.nodes.add(addNodes);
      data.edges.add(addEdges);
      expandedGateId = gateId;
      this.textContent = 'Hide gate detail';
      network.focus(gateId, { scale: 1.6, animation: true });
    }
  });

  network.on('doubleClick', function(params) {
    if (params.nodes.length === 0) {
      document.getElementById('infoPanel').classList.remove('visible');
    }
  });

  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
      network.selectNodes([]); searchInput.value = '';
      document.getElementById('infoPanel').classList.remove('visible');
      network.fit({ animation: true, duration: 300 });
    }
    if ((e.ctrlKey || e.metaKey) && e.key === 'f') { e.preventDefault(); searchInput.focus(); }
  });
})();
</script>
</body>
</html>
'''


# ═══════════════════════════════════════════════════════════════════════
# LEGEND
# ═══════════════════════════════════════════════════════════════════════

def build_legend():
    groups = [
        ("phase", "Phase"), ("gate", "Gate"), ("decision", "Decision step"),
        ("branch", "Branch workflow"), ("agent", "Agent / Persona"),
        ("orchestrator", "Entry point"), ("pipeline", "Pipeline step"),
        ("source", "Source dir"), ("target", "Target dir"),
        ("ownership", "Ownership class"), ("folder", "Topic folder"),
        ("check", "Check / status"), ("harness", "Runtime harness"),
        ("start_end", "Start / End"), ("script", "Tool / Category"),
    ]
    items = []
    for key, label in groups:
        c = COLORS.get(key)
        if c:
            items.append(
                '<div class="legend-item">'
                f'<div class="legend-dot" style="background:{c["bg"]}"></div>'
                f'<span class="legend-label">{label}</span></div>')
    return "\n".join(items)


# ═══════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════
# SVG DIAGRAM GENERATOR
# ═══════════════════════════════════════════════════════════════════════

def build_svg_diagram():
    """Generate a clean static SVG diagram of all workflows for README embedding."""
    W = 1100
    H = 720
    CX = W // 2  # center x = 550
    FONT = "-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif"

    # Colors (dark theme, matching the repo's style)
    BG = "#0d1117"
    TEXT = "#e6edf3"
    TEXT_MUTED = "#8b949e"
    PHASE_BG = "#238636"
    PHASE_BD = "#2ea043"
    GATE_BG = "#d29922"
    GATE_BD = "#bb8009"
    BRANCH_BG = "#1f6feb"
    BRANCH_BD = "#388bfd"
    LINE_CLR = "#30363d"
    LINE_MAIN = "#58a6ff"
    ARROW_CLR = "#58a6ff"
    PROP_BG = "#9e6a03"
    TOOL_BG = "#3d444d"
    TOOL_BD = "#484f58"
    START_BG = "#1f6feb"
    NODE_TEXT = "#f0f6fc"
    SECTION_TITLE = "#58a6ff"

    svg = []
    push = svg.append

    # -- Header --
    push(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="100%" style="max-width:{W}px">')
    push(f'<rect width="{W}" height="{H}" fill="{BG}" rx="8"/>')
    push(f'<defs>'
          '<marker id="arrow" viewBox="0 0 10 10" refX="10" refY="5" markerWidth="6" markerHeight="6" orient="auto">'
          f'<path d="M 0 0 L 10 5 L 0 10 z" fill="{LINE_MAIN}"/></marker>'
          '<marker id="arrow-sub" viewBox="0 0 10 10" refX="10" refY="5" markerWidth="5" markerHeight="5" orient="auto">'
          f'<path d="M 0 0 L 10 5 L 0 10 z" fill="{LINE_CLR}"/></marker>'
          '</defs>')

    # -- Helper: rounded rect --
    def rect(x, y, w, h, fill, stroke, label, opts=""):
        push(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}" stroke="{stroke}" stroke-width="1.5" {opts}/>')
        push(f'<text x="{x + w//2}" y="{y + h//2 + 4}" text-anchor="middle" fill="{NODE_TEXT}" font-family="-apple-system,BlinkMacSystemFont,\'Segoe UI\',sans-serif" font-size="11" font-weight="600">{label}</text>')

    def diamond(cx, cy, size, fill, stroke, label, opts=""):
        s = size // 2
        push(f'<polygon points="{cx},{cy-s} {cx+s},{cy} {cx},{cy+s} {cx-s},{cy}" fill="{fill}" stroke="{stroke}" stroke-width="1.5" {opts}/>')
        push(f'<text x="{cx}" y="{cy + 3}" text-anchor="middle" fill="{NODE_TEXT}" font-family="{FONT}" font-size="9" font-weight="500">{label}</text>')

    def arrow(x1, y1, x2, y2, color=LINE_MAIN, label="", dash=""):
        style = f'stroke="{color}" stroke-width="1.5" marker-end="url(#arrow)"'
        if dash:
            style += f' stroke-dasharray="{dash}"'
        push(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" {style}/>')
        if label:
            mx, my = (x1 + x2) // 2, (y1 + y2) // 2 - 10
            push(f'<text x="{mx}" y="{my}" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="8">{label}</text>')

    def section_title(x, y, title):
        push(f'<text x="{x}" y="{y}" fill="{SECTION_TITLE}" font-family="{FONT}" font-size="10" font-weight="600" text-transform="uppercase" letter-spacing="1">{title}</text>')

    # ──────────────────────────────────────────────────────────────────
    # TIER 1: PROPAGATION + TOOL LANDSCAPE (y=30..120)
    # ──────────────────────────────────────────────────────────────────
    section_title(30, 25, "▸ Cross-Repo Propagation")

    # Propagate entry
    rect(30, 35, 100, 28, PROP_BG, "#bb8009", "propagate.sh")
    # Command sync
    rect(170, 35, 100, 28, BRANCH_BG, BRANCH_BD, "sync commands")
    # Template propagate
    rect(310, 35, 100, 28, BRANCH_BG, BRANCH_BD, "propagate templates")

    # Destinations
    rect(450, 25, 80, 22, TOOL_BG, TOOL_BD, ".opencode/")
    rect(450, 53, 80, 22, TOOL_BG, TOOL_BD, ".pi/prompts/")
    rect(540, 25, 80, 22, TOOL_BG, TOOL_BD, "commands/")
    rect(540, 53, 80, 22, TOOL_BG, TOOL_BD, "CLAUDE.md")

    # Topic folders (larger radius)
    push(f'<rect x="660" y="35" width="110" height="28" rx="14" fill="#6e7681" stroke="#848d97" stroke-width="1.5"/>')
    push(f'<text x="715" y="53" text-anchor="middle" fill="{NODE_TEXT}" font-family="-apple-system,BlinkMacSystemFont,\'Segoe UI\',sans-serif" font-size="11" font-weight="600">14 topic folders</text>')
    # Status check
    rect(810, 35, 90, 28, GATE_BG, GATE_BD, "✓ sync status")

    push(f'<text x="{W - 30}" y="25" text-anchor="end" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="9">{PROP_DATA["total_pairs"]} file targets per folder</text>')

    # Edges
    arrow(130, 49, 170, 49, LINE_MAIN)
    arrow(270, 49, 310, 49, LINE_MAIN)
    arrow(410, 49, 450, 36, LINE_CLR, "")
    arrow(410, 49, 540, 36, LINE_CLR, "")
    arrow(410, 49, 450, 64, LINE_CLR, "")
    arrow(410, 49, 540, 64, LINE_CLR, "")
    arrow(630, 49, 660, 49, "#848d97", f"{PROP_DATA['managed']} managed + {PROP_DATA['repo_owned']} repo-owned", "4")
    arrow(770, 49, 810, 49, LINE_MAIN)

    # ──────────────────────────────────────────────────────────────────
    # TIER 2: MAIN PHASE PIPELINE (y=160..330)
    # ──────────────────────────────────────────────────────────────────
    section_title(30, 155, "▸ Task Execution Pipeline")

    phases_x = [50, 210, 350, 490, 630, 770, 910]

    phase_data = [
        (50, "Start"),
        (210, "Route\nIntake"),
        (350, "Research\n(6 tools)"),
        (490, "Plan\n(4 tools)"),
        (630, "Implement\n(4 tools)"),
        (770, "Verify\n(7 tools)"),
        (910, "Session\nCheckpoint"),
    ]

    # Close / End off to the right
    rect(1030, 280, 60, 28, "none", "none", "", "")  # placeholder for end

    # Phase boxes
    for px, plabel in phase_data:
        rect(px, 235, 130, 40, PHASE_BG, PHASE_BD, plabel)

    # End ellipse
    push(f'<ellipse cx="1090" cy="255" rx="30" ry="16" fill="none" stroke="{LINE_CLR}" stroke-width="1.5"/>')
    push(f'<text x="1090" y="259" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="11">End</text>')

    # Main flow arrows
    arrow(180, 255, 210, 255, LINE_MAIN)
    arrow(340, 255, 350, 255, LINE_MAIN)
    arrow(480, 255, 490, 255, LINE_MAIN)
    arrow(620, 255, 630, 255, LINE_MAIN)
    arrow(760, 255, 770, 255, LINE_MAIN)
    arrow(900, 255, 910, 255, LINE_MAIN)
    arrow(1040, 255, 1060, 255, LINE_CLR)

    # Gate diamonds between phases
    gate_x_positions = [270, 420, 560, 700, 840]
    gate_labels = ["Research\nGate", "Plan\nGate", "Implement\nGate", "Verify\nGate", "Session\nGate"]

    for gx, glabel in zip(gate_x_positions, gate_labels):
        diamond(gx, 255, 36, GATE_BG, GATE_BD, glabel)
        # Connect phase -> gate -> phase
        # Already handled by main flow arrows

    # Decision sub-steps below gates (small labels)
    decision_labels = [
        ("270", ["Model", "Select"]),
        ("420", ["Model", "Select"]),
        ("560", ["Quality", "Speed"]),
    ]
    for dx, dlabels in decision_labels:
        pass  # skip for SVG (too detailed)

    # Gate details as floating label
    push(f'<text x="270" y="295" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="7">model-select · sufficiency · scope-check</text>')
    push(f'<text x="420" y="295" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="7">model-select · catfish · scope · comprehension · decisions · autonomy · preflight</text>')
    push(f'<text x="560" y="295" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="7">quality-speed check (full suite or smoke?)</text>')
    push(f'<text x="700" y="295" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="7">test-smoke · test-workflows · counsel-run</text>')
    push(f'<text x="840" y="295" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="7">checkpoint-commit · context-save · handoff</text>')

    # Question Gate before Route
    diamond(145, 255, 30, GATE_BG, GATE_BD, "Q")
    push(f'<text x="145" y="230" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="7">Question</text>')
    arrow(50, 274, 50, 255, LINE_MAIN)  # Start -> Q gate
    arrow(160, 255, 210, 255, LINE_MAIN)

    # ──────────────────────────────────────────────────────────────────
    # TIER 3: BRANCH WORKFLOWS (y=370..520)
    # ──────────────────────────────────────────────────────────────────
    section_title(30, 365, "▸ Branch Workflows")

    branch_y = 375
    branch_data = [
        (160, "Agent Dispatch\nFan-out (pi/codex/claude)", "scripts/agent-dispatch.sh", BRANCH_BG),
        (390, "Pipeline Run\nSequenced task dispatch", "scripts/pipeline-run.sh", BRANCH_BG),
        (620, "Counsel / Parley\nMulti-perspective review", "scripts/counsel-gate.sh", BRANCH_BG),
        (850, "Autopilot\nAutonomous execution loop", "scripts/autopilot.sh", BRANCH_BG),
    ]

    # Branch from Implement (x=630) down to branches
    # Horizontal line at y=375
    branch_start_x = 120
    branch_end_x = 1000
    push(f'<line x1="{branch_start_x}" y1="{branch_y}" x2="{branch_end_x}" y2="{branch_y}" stroke="{LINE_CLR}" stroke-width="1" stroke-dasharray="4,3"/>')
    arrow(630, 275, 630, 350, LINE_CLR, "branches", "4,3")
    # Vertical line from implement down to branch horizontal
    push(f'<line x1="630" y1="{branch_y - 25}" x2="630" y2="{branch_y}" stroke="{LINE_CLR}" stroke-width="1" stroke-dasharray="4,3"/>')

    for bx, blabel, bscript, bcolor in branch_data:
        rect(bx - 60, branch_y + 10, 120, 38, bcolor, BRANCH_BD, blabel)
        push(f'<text x="{bx}" y="{branch_y + 58}" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="7">{bscript}</text>')
        # Arrow from horizontal line down to branch
        push(f'<line x1="{bx}" y1="{branch_y}" x2="{bx}" y2="{branch_y + 10}" stroke="{LINE_CLR}" stroke-width="1" stroke-dasharray="2,2"/>')

    # Agent dispatch targets (small boxes below agent dispatch)
    ad_y = branch_y + 50
    push(f'<text x="160" y="{ad_y + 55}" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="8">→ pi · codex · claude</text>')
    push(f'<text x="160" y="{ad_y + 66}" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="8">/ship: reviewer + security + test</text>')

    # Pipeline run targets
    push(f'<text x="390" y="{ad_y + 55}" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="8">@worker · @explore · @review</text>')
    push(f'<text x="390" y="{ad_y + 66}" text-anchor="middle" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="8">on_error: abort/continue/retry:N</text>')

    # ──────────────────────────────────────────────────────────────────
    # TIER 4: SESSION LIFECYCLE (y=550..650)
    # ──────────────────────────────────────────────────────────────────
    section_title(30, 555, "▸ Session Lifecycle")

    sess_y = 565
    sess_items = [
        (140, "Checkpoint\nCommit"),
        (300, "Session\nFork (worktree)"),
        (460, "Handoff\n(continuation)"),
        (620, "Context\nRestore"),
        (780, "Context\nPressure"),
    ]

    push(f'<line x1="80" y1="{sess_y}" x2="860" y2="{sess_y}" stroke="{LINE_CLR}" stroke-width="1" stroke-dasharray="4,3"/>')

    for sx, slabel in sess_items:
        rect(sx - 50, sess_y + 10, 100, 32, TOOL_BG, TOOL_BD, slabel)
        push(f'<line x1="{sx}" y1="{sess_y}" x2="{sx}" y2="{sess_y + 10}" stroke="{LINE_CLR}" stroke-width="1" stroke-dasharray="2,2"/>')

    # Connection from Session phase to sessions
    push(f'<line x1="910" y1="275" x2="910" y2="{sess_y}" stroke="{LINE_CLR}" stroke-width="1" stroke-dasharray="4,3"/>')
    arrow(910, 345, 910, sess_y - 5, LINE_CLR, "session lifecycle", "4,3")

    # ──────────────────────────────────────────────────────────────────
    # TOOL LANDSCAPE (right side panel)
    # ──────────────────────────────────────────────────────────────────
    panel_x = 50
    panel_y = 610
    push(f'<text x="{panel_x}" y="630" fill="{SECTION_TITLE}" font-family="{FONT}" font-size="10" font-weight="600">▸ Tool Landscape: {sum(TOOL_COUNTS.values())} registered</text>')
    tool_str = " · ".join(f"{cat}: {cnt}" for cat, cnt in sorted(TOOL_COUNTS.items(), key=lambda x: -x[1]) if cnt > 0)
    push(f'<text x="{panel_x}" y="648" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="9">{tool_str}</text>')
    push(f'<text x="{panel_x}" y="664" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="9">14 commands · 46 skills · 8 agents · {TMPL_DATA["templates"]} propagation templates</text>')

    # ──────────────────────────────────────────────────────────────────
    # FOOTER / LEGEND
    # ──────────────────────────────────────────────────────────────────
    ly = 690
    push(f'<line x1="30" y1="{ly - 8}" x2="{W - 30}" y2="{ly - 8}" stroke="{LINE_CLR}" stroke-width="0.5"/>')

    legend_items = [
        (PHASE_BG, "Phase"),
        (GATE_BG, "Gate"),
        (BRANCH_BG, "Branch"),
        (PROP_BG, "Propagation"),
        (TOOL_BG, "Tool / Target"),
    ]

    lx = 30
    for lcolor, llabel in legend_items:
        push(f'<rect x="{lx}" y="{ly}" width="10" height="10" rx="2" fill="{lcolor}" stroke="{lcolor}" stroke-width="1"/>')
        push(f'<text x="{lx + 15}" y="{ly + 9}" fill="{TEXT}" font-family="{FONT}" font-size="9">{llabel}</text>')
        lx += 90

    push(f'<text x="{W - 260}" y="{ly + 9}" fill="{TEXT_MUTED}" font-family="{FONT}" font-size="8">Interactive: b67687.github.io/agentic-workflows/workflow-graph.html</text>')

    push('</svg>')
    return "\n".join(svg)


# ═══════════════════════════════════════════════════════════════════════

def main():
    output_html = "workflow-graph.html"
    output_svg = "workflow-graph.svg"

    # Support override for HTML path, and --svg-only
    svg_only = False
    for arg in sys.argv[1:]:
        if arg == "--svg-only":
            svg_only = True
        elif not arg.startswith("--"):
            output_html = arg

    repo_root = Path(__file__).resolve().parent.parent
    os.chdir(repo_root)

    print("🧩 Building comprehensive Workflow DAG...")
    print(f"   Source data: {sum(TOOL_COUNTS.values())} tools · "
          f"{PROP_DATA['total_pairs']} propagation pairs · "
          f"{TMPL_DATA['templates']} template files")

    if not svg_only:
        nodes, edges = build_all_workflows()
        legend = build_legend()

        html = (HTML.replace("__NODES__", json.dumps(nodes, indent=2))
                    .replace("__EDGES__", json.dumps(edges, indent=2))
                    .replace("__LEGEND__", legend))

        with open(output_html, "w", encoding="utf-8") as f:
            f.write(html)

        real_html = os.path.abspath(output_html)
        print(f"\n✅ HTML: {real_html}")
        print(f"   {len(nodes)} nodes · {len(edges)} edges")
        print(f"   Open: file://{real_html}")
        print(f"   💡 Gate decision chains are hidden by default.")
        print(f"      Click a Gate → 'Show gate decision chain' to expand.")
        print()

    # Always generate SVG
    svg_content = build_svg_diagram()
    with open(output_svg, "w", encoding="utf-8") as f:
        f.write(svg_content)

    real_svg = os.path.abspath(output_svg)
    svg_lines = svg_content.count("\n")
    print(f"✅ SVG: {real_svg} ({svg_lines} lines)")
    print(f"   Embed in README.md with: <img src=\"workflow-graph.svg\" width=\"100%\" alt=\"Workflow Diagram\">")


if __name__ == "__main__":
    main()
