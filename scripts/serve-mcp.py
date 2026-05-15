#!/usr/bin/env python3
"""
MCP stdio server for agentic-workflows tool registry.

Implements the Model Context Protocol (JSON-RPC 2.0 over stdio).
Exposes tools.toml + skills.toml as MCP tools and resources.

Protocol: https://spec.modelcontextprotocol.io/
Schema version: 2025-11-25

Usage:
  python3 scripts/serve-mcp.py          # stdio mode (for MCP clients)
  python3 scripts/serve-mcp.py --check  # validate config, print summary, exit
"""
import json
import os
import pathlib
import subprocess
import sys
import traceback

# ── Paths ────────────────────────────────────────────────────────────────────
REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
TOOLS_TOML = REPO_ROOT / "scripts" / "tools.toml"
SKILLS_TOML = REPO_ROOT / "scripts" / "skills.toml"
SCRIPTS_DIR = REPO_ROOT / "scripts"

# ── TOML loader (stdlib-only, Python 3.11+ has tomllib) ─────────────────────
def _load_toml(path):
    """Load a TOML file using tomllib (3.11+) or fallback."""
    if sys.version_info >= (3, 11):
        import tomllib
        with open(path, "rb") as f:
            return tomllib.load(f)
    # Fallback: minimal TOML parser for our restricted format
    return _minimal_toml_parse(path)


def _minimal_toml_parse(path):
    """
    Minimal TOML parser for our known schema.

    Handles: [[tool]] arrays of tables, [section] tables, string and array
    values, comments. Does NOT handle inline tables, multi-line strings,
    floats, dates, or dotted keys.
    """
    def _parse_value(raw):
        v = raw.strip()
        if not v:
            return ""
        if v.startswith('"') and v.endswith('"'):
            return v[1:-1]
        if v.startswith("'") and v.endswith("'"):
            return v[1:-1]
        if v == "true":
            return True
        if v == "false":
            return False
        # Inline array
        if v.startswith("[") and v.endswith("]"):
            inner = v[1:-1].strip()
            if not inner:
                return []
            return [x.strip().strip('"').strip("'") for x in inner.split(",")]
        # Number
        try:
            return int(v)
        except ValueError:
            try:
                return float(v)
            except ValueError:
                return v

    result = {}
    current_section = result
    current_array = None
    current_array_key = None

    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue

            # [[tool]] array of tables
            if line.startswith("[["):
                key = line[2:-2].strip()
                if key not in result:
                    result[key] = []
                current_section = {}
                result[key].append(current_section)
                continue

            # [section] table
            if line.startswith("[") and not line.startswith("[["):
                key = line[1:-1].strip()
                if key not in result:
                    result[key] = {}
                current_section = result[key]
                continue

            # key = value
            if "=" in line:
                k, _, v = line.partition("=")
                current_section[k.strip()] = _parse_value(v)

    return result


# ── Data loading ─────────────────────────────────────────────────────────────
def _load_tools():
    """Load and cache tools.toml. Returns list of tool dicts."""
    try:
        data = _load_toml(TOOLS_TOML)
    except Exception as e:
        return {"error": f"Failed to load tools.toml: {e}", "tools": []}

    entries = data.get("tool", [])
    if not isinstance(entries, list):
        entries = [entries]

    tools = []
    for t in entries:
        tool = {
            "name": t.get("name", "unknown"),
            "description": t.get("description", ""),
            "path": t.get("path", ""),
            "category": t.get("category", "uncategorized"),
            "type": t.get("type", "script"),
        }
        # Build JSON Schema input schema
        raw_inputs = t.get("inputs", {})
        properties = {}
        required = []
        for pname, pschema in raw_inputs.items():
            if isinstance(pschema, dict):
                prop = {}
                if "type" in pschema:
                    prop["type"] = pschema["type"]
                if "description" in pschema:
                    prop["description"] = pschema["description"]
                if "enum" in pschema:
                    prop["enum"] = pschema["enum"]
                    if "type" not in prop:
                        prop["type"] = "string"
                if "default" in pschema:
                    prop["default"] = pschema["default"]
                properties[pname] = prop
                if "default" not in pschema:
                    required.append(pname)

        input_schema = {"type": "object"}
        if properties:
            input_schema["properties"] = properties
        if required:
            input_schema["required"] = required

        # Format for MCP Tool schema
        tool["inputSchema"] = input_schema
        tools.append(tool)

    return tools


def _load_skills():
    """Load skills.toml. Returns list of skill dicts."""
    try:
        data = _load_toml(SKILLS_TOML)
    except Exception as e:
        return {"error": f"Failed to load skills.toml: {e}", "skills": []}

    entries = data.get("skill", [])
    if not isinstance(entries, list):
        entries = [entries]
    return entries


# ── Tool execution ───────────────────────────────────────────────────────────
def _sync_session(method_name, status="completed"):
    """Update session-state.json after a tool execution."""
    try:
        session_sync = REPO_ROOT / "scripts" / "session-sync.sh"
        if session_sync.exists():
            subprocess.run(
                [str(session_sync), "update", "status", "verified-phase"],
                capture_output=True, text=True, timeout=10,
            )
    except Exception:
        pass  # Non-blocking


def _execute_script(path, args_dict):
    """Execute a script from the registry and return structured output."""
    full_path = REPO_ROOT / path
    if not full_path.exists():
        # Try without REPO_ROOT prefix
        full_path = pathlib.Path(path)
        if not full_path.exists():
            return {
                "content": [{"type": "text", "text": f"Script not found: {path}"}],
                "isError": True,
            }

    # Run post-edit hook on modified files before execution
    # (the execution may create/modify files, so we check after too)

    # Build args from the input dict
    cmd = [str(full_path)]
    for key, value in args_dict.items():
        if isinstance(value, bool):
            if value:
                cmd.append(f"--{key}")
        elif isinstance(value, list):
            for v in value:
                cmd.extend([f"--{key}", str(v)])
        else:
            cmd.extend([f"--{key}", str(value)])

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=120,
        )
        output = result.stdout
        if result.stderr:
            output += f"\n[stderr]\n{result.stderr}"

        # Run post-edit hook after execution (catches file modifications)
        post_edit_script = REPO_ROOT / "scripts" / "hooks" / "post-edit.sh"
        if post_edit_script.exists():
            try:
                pe_result = subprocess.run(
                    [str(post_edit_script), "--all"],
                    capture_output=True, text=True, timeout=30,
                )
                if pe_result.stdout.strip():
                    output += f"\n\n[post-edit]\n{pe_result.stdout.strip()}"
            except (subprocess.TimeoutExpired, OSError):
                pass  # Post-edit hook is non-blocking

        return {
            "content": [
                {
                    "type": "text",
                    "text": output.strip() or "(no output)",
                }
            ],
            "isError": result.returncode != 0,
        }
    except subprocess.TimeoutExpired:
        return {
            "content": [{"type": "text", "text": f"Execution timed out (120s): {path}"}],
            "isError": True,
        }
    except Exception as e:
        return {
            "content": [{"type": "text", "text": f"Execution error: {e}"}],
            "isError": True,
        }


def _run_quality_gate(gate_name):
    """Run a named quality gate and return structured results."""
    gate_scripts = {
        "quality": "scripts/test-smoke.sh",
        "constitution": "scripts/constitution.sh check",
        "comprehension": "scripts/comprehension-gate.sh verify",
        "preflight": "scripts/implement-preflight.sh",
    }
    gate = gate_scripts.get(gate_name)
    if not gate:
        return {"passed": False, "output": f"Unknown quality gate: {gate_name}"}

    parts = gate.split()
    script_path = REPO_ROOT / parts[0]
    extra_args = parts[1:]

    cmd = [str(script_path)] + extra_args
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
        return {
            "gate": gate_name,
            "passed": result.returncode == 0,
            "output": (result.stdout or "").strip(),
            "errors": (result.stderr or "").strip(),
        }
    except Exception as e:
        return {"gate": gate_name, "passed": False, "output": str(e)}


# ── MCP protocol handler ─────────────────────────────────────────────────────
class MCPServer:
    def __init__(self):
        self.tools_cache = None
        self.skills_cache = None

    def _get_tools(self):
        if self.tools_cache is None:
            self.tools_cache = _load_tools()
        return self.tools_cache

    def _get_skills(self):
        if self.skills_cache is None:
            self.skills_cache = _load_skills()
        return self.skills_cache

    def handle_request(self, request):
        """Handle a single JSON-RPC request. Returns response dict or None for notifications."""
        method = request.get("method", "")
        req_id = request.get("id")
        params = request.get("params", {})

        # Notifications (no response expected)
        if req_id is None:
            if method == "notifications/initialized":
                pass  # Client confirms init complete
            elif method == "notifications/cancelled":
                pass  # Client cancelled a request
            return None

        try:
            if method == "initialize":
                return self._handle_initialize(params, req_id)
            elif method == "ping":
                return self._make_result(req_id, {})
            elif method == "tools/list":
                return self._handle_tools_list(params, req_id)
            elif method == "tools/call":
                return self._handle_tools_call(params, req_id)
            elif method == "resources/list":
                return self._handle_resources_list(params, req_id)
            elif method == "resources/read":
                return self._handle_resources_read(params, req_id)
            elif method == "quality/check":
                return self._handle_quality_check(params, req_id)
            elif method == "state/status":
                return self._handle_state_status(params, req_id)
            else:
                return self._make_error(req_id, -32601, f"Method not found: {method}")
        except Exception as e:
            traceback.print_exc(file=sys.stderr)
            return self._make_error(req_id, -32603, f"Internal error: {e}")

    def _handle_initialize(self, params, req_id):
        return {
            "jsonrpc": "2.0",
            "id": req_id,
            "result": {
                "protocolVersion": "2025-11-25",
                "capabilities": {
                    "tools": {
                        "listChanged": False,
                    },
                    "resources": {
                        "listChanged": False,
                        "read": True,
                    },
                },
                "serverInfo": {
                    "name": "agentic-workflows-mcp",
                    "version": "1.1.0",
                    "description": "MCP server for agentic-workflows — quality verification, tool registry, skill index",
                },
                "instructions": (
                    "This server exposes the agentic-workflows orchestration methodology "
                    "as MCP tools and resources. Tools represent executable scripts for "
                    "quality gates, session management, research, and workflow phases. "
                    "Resources represent skill definitions and methodology documentation. "
                    "Use quality/check to run explicit quality validation. All tools/call "
                    "responses include quality gate results when the tool has quality_gates "
                    "defined in its metadata."
                ),
            },
        }

    def _handle_tools_list(self, params, req_id):
        tools = self._get_tools()
        mcp_tools = []
        for t in tools:
            mcp_tools.append({
                "name": t["name"],
                "description": t["description"],
                "inputSchema": t.get("inputSchema", {"type": "object"}),
                "annotations": {
                    "title": t["name"],
                    "audience": ["assistant"],
                },
            })

        return self._make_result(req_id, {"tools": mcp_tools})

    # ── Quality check method (explicit, not tool-call side-effect) ─────────
    def _handle_quality_check(self, params, req_id):
        """Run one or more quality gates explicitly. Returns structured results.

        Params:
            gates: list of gate names to run (default: all known)
        """
        gate_names = params.get("gates", _run_quality_gate.__defaults__)
        if not gate_names:
            gate_names = ["quality", "constitution", "comprehension"]

        results = []
        for gate in gate_names:
            results.append(_run_quality_gate(gate))

        all_passed = all(r.get("passed", False) for r in results)

        return self._make_result(req_id, {
            "content": [{
                "type": "text",
                "text": json.dumps(results, indent=2),
            }],
            "structuredContent": {
                "quality": {
                    "passed": all_passed,
                    "gate_count": len(results),
                    "gates": results,
                }
            },
        })

    # ── State status endpoint ─────────────────────────────────────────────
    def _handle_state_status(self, params, req_id):
        """Return current session state summary."""
        state_path = REPO_ROOT / "session-state.json"
        try:
            if state_path.exists():
                state = json.loads(state_path.read_text())
            else:
                state = {"status": "no-session"}
        except Exception:
            state = {"status": "error-reading-state"}

        # Add derived health info
        health = {"healthy": True, "warnings": []}
        task = state.get("currentTask", {})
        if task.get("status") == "done" and not state.get("immediateNextSteps"):
            health["warnings"].append("Task complete with no next steps defined")
        if state.get("interruptedCount", 0) > 3:
            health["warnings"].append(f"High interruption count: {state['interruptedCount']}")
            health["healthy"] = False

        result = {
            "session": state.get("session", 0),
            "status": state.get("status", "unknown"),
            "task": task.get("name", ""),
            "task_status": task.get("status", ""),
            "interruptedCount": state.get("interruptedCount", 0),
            "contextPressure": state.get("contextPressure", "unknown"),
            "health": health,
        }

        return self._make_result(req_id, {
            "content": [{"type": "text", "text": json.dumps(result, indent=2)}],
            "structuredContent": result,
        })

    def _handle_tools_call(self, params, req_id):
        name = params.get("name", "")
        arguments = params.get("arguments", {})

        tools = self._get_tools()
        tool = next((t for t in tools if t["name"] == name), None)

        if not tool:
            return self._make_error(req_id, -32602, f"Unknown tool: {name}")

        # Execute the script (or return doc reference for commands)
        script_path = tool.get("path", "")
        if not script_path or tool.get("type") == "command":
            exec_result = {
                "content": [{
                    "type": "text",
                    "text": f"Tool '{name}' is a command definition, not directly executable. "
                            f"See the command doc for usage: {script_path}"
                }],
            }
        else:
            exec_result = _execute_script(script_path, arguments)

        # Run quality gates AFTER execution for ANY tool with quality_gates
        quality_results = None
        gate_names = tool.get("quality_gates", [])
        if gate_names:
            quality_results = []
            for gate in gate_names:
                quality_results.append(_run_quality_gate(gate))

        # Auto-sync session state
        _sync_session(name)

        # If quality gates ran, append them to the response
        if quality_results:
            all_passed = all(q.get("passed", False) for q in quality_results)
            summary = f"\n\n--- Quality Gates ---\n"
            summary += f"Status: {'PASSED' if all_passed else 'FAILED'}\n"
            for qr in quality_results:
                status = "✓" if qr.get("passed") else "✗"
                summary += f"  {status} {qr.get('gate', 'unknown')}: {qr.get('output', '')[:120]}\n"

            exec_result["content"].append({
                "type": "text",
                "text": summary,
            })

            # Surface quality failure in structuredContent for programmatic consumers
            if not all_passed:
                exec_result["structuredContent"] = {
                    "quality": {
                        "passed": False,
                        "gates": quality_results,
                    }
                }

        return self._make_result(req_id, exec_result)

    def _handle_resources_list(self, params, req_id):
        skills = self._get_skills()
        resources = []

        # Skill resources
        for s in skills:
            rid = f"skill://{s.get('name', 'unknown')}"
            resources.append({
                "uri": rid,
                "name": s.get("name", ""),
                "description": s.get("description", ""),
                "mimeType": "text/markdown",
                "annotations": {
                    "audience": ["assistant"],
                },
            })

        # Methodology resources
        METHODOLOGY = [
            ("methodology://workflow", "Workflow Methodology",
             "Full workflow methodology: question gate, research, plan, implement, verify, retrospect"),
            ("methodology://full-stream-interface", "Full-Stream Interface Architecture",
             "Architecture document for the Layer 4↔3 interface contract"),
            ("methodology://agents-md", "Agent Operating Contract",
             "AGENTS.md — full agent harness operating contract and governance rules"),
            ("methodology://research-prompt", "Research Methodology",
             "6-phase research methodology: frame, discover, gather, triangulate, apply, preserve"),
        ]
        for uri, name, desc in METHODOLOGY:
            resources.append({
                "uri": uri, "name": name, "description": desc,
                "mimeType": "text/markdown",
                "annotations": {"audience": ["assistant"]},
            })

        # State resource (dynamic)
        resources.append({
            "uri": "state://session",
            "name": "Session State",
            "description": "Current session state.json (read-only)",
            "mimeType": "application/json",
            "annotations": {"audience": ["assistant"]},
        })

        return self._make_result(req_id, {"resources": resources})

    def _handle_resources_read(self, params, req_id):
        uri = params.get("uri", "")

        # Skill resource
        if uri.startswith("skill://"):
            skill_name = uri[8:]
            skills = self._get_skills()
            skill = next((s for s in skills if s.get("name") == skill_name), None)
            if not skill:
                return self._make_error(req_id, -32602, f"Unknown skill: {skill_name}")

            # Read the actual SKILL.md
            skill_path = REPO_ROOT / "skills" / skill_name / "SKILL.md"
            if skill_path.exists():
                text = skill_path.read_text()
            else:
                text = json.dumps(skill, indent=2)

            return self._make_result(req_id, {
                "contents": [{
                    "uri": uri,
                    "mimeType": "text/markdown",
                    "text": text,
                }]
            })

        # Methodology resources
        METHODOLOGY_MAP = {
            "methodology://workflow": ("docs/workflow.md", "text/markdown"),
            "methodology://full-stream-interface": ("docs/full-stream-interface.md", "text/markdown"),
            "methodology://agents-md": ("AGENTS.md", "text/markdown"),
            "methodology://research-prompt": ("research/research-prompt.md", "text/markdown"),
        }
        if uri in METHODOLOGY_MAP:
            rel_path, mime = METHODOLOGY_MAP[uri]
            path = REPO_ROOT / rel_path
            text = path.read_text() if path.exists() else f"(not found: {path})"
            return self._make_result(req_id, {
                "contents": [{"uri": uri, "mimeType": mime, "text": text}]
            })

        # State resources
        if uri == "state://session":
            path = REPO_ROOT / "session-state.json"
            text = path.read_text() if path.exists() else "{}"
            return self._make_result(req_id, {
                "contents": [{"uri": uri, "mimeType": "application/json", "text": text}]
            })

        return self._make_error(req_id, -32602, f"Unknown resource: {uri}")

    # ── JSON-RPC helpers ────────────────────────────────────────────────────
    def _make_result(self, req_id, result):
        return {"jsonrpc": "2.0", "id": req_id, "result": result}

    def _make_error(self, req_id, code, message):
        return {"jsonrpc": "2.0", "id": req_id, "error": {"code": code, "message": message}}


# ── Main ─────────────────────────────────────────────────────────────────────
def main():
    if "--check" in sys.argv:
        tools = _load_tools()
        skills = _load_skills()
        error_count = 0

        print(f"Repo root: {REPO_ROOT}")
        print(f"Tools manifest: {TOOLS_TOML}")
        if isinstance(tools, dict) and "error" in tools:
            print(f"  ERROR: {tools['error']}")
            error_count += 1
        else:
            print(f"  Loaded: {len(tools)} tools")

        print(f"Skills index: {SKILLS_TOML}")
        if isinstance(skills, dict) and "error" in skills:
            print(f"  ERROR: {skills['error']}")
            error_count += 1
        else:
            print(f"  Loaded: {len(skills)} skills")

        if error_count:
            print(f"\n{error_count} error(s) found — check paths")
            sys.exit(1)
        print("\nConfiguration OK")
        sys.exit(0)

    # Stdio MCP server mode
    server = MCPServer()

    # Read JSON-RPC messages line by line from stdin
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            request = json.loads(line)
        except json.JSONDecodeError as e:
            # Respond with error for malformed JSON
            err_resp = {
                "jsonrpc": "2.0",
                "id": None,
                "error": {"code": -32700, "message": f"Parse error: {e}"},
            }
            sys.stdout.write(json.dumps(err_resp) + "\n")
            sys.stdout.flush()
            continue

        # Validate JSON-RPC structure
        if not isinstance(request, dict) or request.get("jsonrpc") != "2.0":
            err_resp = {
                "jsonrpc": "2.0",
                "id": request.get("id") if isinstance(request, dict) else None,
                "error": {"code": -32600, "message": "Invalid Request"},
            }
            sys.stdout.write(json.dumps(err_resp) + "\n")
            sys.stdout.flush()
            continue

        response = server.handle_request(request)
        if response is not None:
            sys.stdout.write(json.dumps(response) + "\n")
            sys.stdout.flush()


if __name__ == "__main__":
    main()
