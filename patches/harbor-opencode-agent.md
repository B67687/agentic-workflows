# Harbor OpenCode Agent Patch — opencode-go Provider Support

**Location:** `.runtime/bench-env/lib/python3.12/site-packages/harbor/agents/installed/opencode.py`

**Changes:**
1. Added `elif provider == "opencode-go":` handler to collect `OPENCODE_API_KEY` env var
2. In `_build_register_config_command()`: map `opencode-go` → `openai` in config generation (opencode-go wraps an OpenAI-compatible provider)
3. In `run()`: rewrite `opencode-go/` → `openai/` in CLI command model name
4. Map `OPENCODE_API_KEY` → `OPENAI_API_KEY` in container env for the rewritten provider

**How to reapply after venv rebuild:**

```bash
# Edit the file and add the opencode-go provider block after line 459:
elif provider == "opencode-go":
    keys.append("OPENCODE_API_KEY")

# In _build_register_config_command(), change line 379:
config_provider = "openai" if provider == "opencode-go" else provider

# In run(), after line 411, add cmd_model_name rewrite:
cmd_model_name = (
    self.model_name.replace("opencode-go/", "openai/", 1)
    if provider == "opencode-go"
    else self.model_name
)

# After line 469 (for loop collecting env vars), add key mapping:
if provider == "opencode-go" and "OPENCODE_API_KEY" in env and "OPENAI_API_KEY" not in env:
    env["OPENAI_API_KEY"] = env["OPENCODE_API_KEY"]

# In the CLI command, use cmd_model_name instead of self.model_name:
f"opencode --model={cmd_model_name} run ..."
```

**Test procedure:** See `adapters/terminal-bench/run_opencode-go-test.yaml`
