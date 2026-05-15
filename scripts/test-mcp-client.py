#!/usr/bin/env python3
"""
MCP client simulation — tests serve-mcp.py against a realistic MCP lifecycle.
Matches what DeepSeek-TUI's MCP client would do: init → list tools → call tool.

Usage: python3 scripts/test-mcp-client.py [-v]
Exit 0 = all pass, 1 = failures
"""
import json, subprocess, sys, os, pathlib

REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
VERBOSE = "-v" in sys.argv
passed = failed = 0

class MCPClient:
    def __init__(self):
        self.proc = subprocess.Popen(
            [sys.executable, str(REPO_ROOT / "scripts" / "serve-mcp.py")],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, text=True)
        self.req_id = 0

    def send(self, method, params=None):
        self.req_id += 1
        req = {"jsonrpc": "2.0", "id": self.req_id, "method": method}
        if params: req["params"] = params
        self.proc.stdin.write(json.dumps(req) + "\n")
        self.proc.stdin.flush()
        resp = json.loads(self.proc.stdout.readline())
        if VERBOSE: print(f"  {method}: {'✓' if 'result' in resp else '✗'}")
        return resp.get("result") if "result" in resp else {"error": resp.get("error")}

    def close(self):
        self.proc.stdin.close(); self.proc.wait(timeout=5)

def check(name, cond, detail=""):
    global passed, failed
    if cond: passed += 1; print(f"  ✓ {name}")
    else: failed += 1; print(f"  ✗ {name}" + (f"  ({detail})" if detail else ""))

def main():
    c = MCPClient()

    # 1. Initialize
    r = c.send("initialize", {"protocolVersion": "2025-11-25", "capabilities": {},
                               "clientInfo": {"name": "test", "version": "1.0"}})
    check("initialize returns result", "error" not in r)
    check("protocol matches", r.get("protocolVersion") == "2025-11-25", f"got {r.get('protocolVersion')}")
    check("has tools capability", "tools" in r.get("capabilities", {}))
    check("has resources capability", "resources" in r.get("capabilities", {}))
    check("server name correct", r.get("serverInfo", {}).get("name") == "agentic-workflows-mcp")

    # 2. tools/list
    r = c.send("tools/list")
    tools = r.get("tools", [])
    check("tools/list returns list", isinstance(tools, list))
    check(f"tools/list has {len(tools)} tools", len(tools) > 0)
    if tools:
        t = tools[0]
        check("tool has name", "name" in t and t["name"])
        check("tool has description", "description" in t)
        check("tool has inputSchema", "inputSchema" in t)

    # 3. resources/list
    r = c.send("resources/list")
    resources = r.get("resources", [])
    check("resources/list returns list", isinstance(resources, list))
    skills = [x for x in resources if x.get("uri","").startswith("skill://")]
    methods = [x for x in resources if x.get("uri","").startswith("methodology://")]
    states = [x for x in resources if x.get("uri","").startswith("state://")]
    check("44 skills", len(skills) == 44, f"got {len(skills)}")
    check("5 methodology docs", len(methods) == 5, f"got {len(methods)}")
    check("3 state resources", len(states) == 3, f"got {len(states)}")

    # 4. resources/read (skill)
    r = c.send("resources/read", {"uri": "skill://clarification-protocol"})
    contents = r.get("contents", [])
    check("skill read returns contents", len(contents) > 0)
    if contents:
        check("skill content has text", "text" in contents[0] and contents[0]["text"])

    # 5. resources/read (methodology)
    r = c.send("resources/read", {"uri": "methodology://agents-md"})
    check("methodology read succeeds", "error" not in r)

    # 6. resources/read (state)
    r = c.send("resources/read", {"uri": "state://session"})
    contents = r.get("contents", [])
    check("state read returns contents", len(contents) > 0)
    if contents:
        try:
            json.loads(contents[0]["text"])
            check("state is valid JSON", True)
        except: check("state is valid JSON", False)

    # 7. quality/check
    r = c.send("quality/check", {"gates": ["constitution"]})
    check("quality/check has content", "content" in r)
    sc = r.get("structuredContent", {})
    check("quality has structured results", "quality" in sc)
    if "quality" in sc:
        check("quality has passed field", "passed" in sc["quality"])
        check("quality has gates list", isinstance(sc["quality"].get("gates"), list))

    # 8. state/status
    r = c.send("state/status")
    sc = r.get("structuredContent", {})
    check("state/status has session", "session" in sc)
    check("state/status has status", "status" in sc)
    check("state/status has health", "health" in sc)

    # 9. Error handling
    r = c.send("tools/call", {"name": "nonexistent", "arguments": {}})
    check("unknown tool returns error", "error" in r)
    r = c.send("resources/read", {"uri": "skill://nonexistent"})
    check("unknown resource returns error", "error" in r)

    # 10. Ping
    r = c.send("ping")
    check("ping returns result", "error" not in r)

    # 11. tools/call (execution)
    r = c.send("tools/call", {"name": "tools", "arguments": {"json": True}})
    check("tools/call returns content", "content" in r)
    if "content" in r:
        check("content has text", any("type" in c and "text" in c for c in r["content"]))

    # 12. Sequential calls (session state sync)
    for tool_name in ["tools", "session-sync"]:
        r = c.send("tools/call", {"name": tool_name, "arguments": {}})
        check(f"sequential call: {tool_name}", "error" not in r)

    c.close()

    print(f"\n  Results: {passed} passed, {failed} failed, {passed + failed} total")
    return failed == 0

if __name__ == "__main__":
    sys.exit(0 if main() else 1)
