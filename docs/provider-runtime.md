# Provider Runtime

Use this when model access, provider keys, or OpenCode account switching changes.

## Google Gemini Models

Do not hardcode preview model names as durable truth. Google exposes model discovery through:

- native Gemini models list: `GET https://generativelanguage.googleapis.com/v1beta/models`
- OpenAI-compatible models list: `GET https://generativelanguage.googleapis.com/v1beta/openai/models`

For OpenCode's OpenAI-compatible Google provider, prefer:

```bash
bash scripts/google-models.sh
bash scripts/google-models.sh --sync-opencode-config
```

This uses `GEMINI_API_KEY`, `GOOGLE_API_KEY`, or the existing `google-ai-studio` key in OpenCode auth storage. It does not print the key.

If `gemini-3.1-pro-preview` is not listed, do not assume it exists for the current key. Use the strongest listed Pro/Flash model that supports your task.

## Google `small_model` Error

If Google returns:

```text
Invalid JSON payload received. Unknown name "small_model"
```

then an OpenCode/provider control field leaked into a Google API request. `small_model` is an OpenCode config field, not a Gemini request field.

Practical fix:

- remove `small_model` from live OpenCode config if Google calls are failing
- use Google model discovery instead of hardcoded preview IDs
- restart OpenCode after config changes

## Two OpenCode Go Subscriptions

OpenCode stores provider credentials in:

```text
~/.local/share/opencode/auth.json
```

Use whole-auth profiles when switching between two OpenCode Go accounts:

```bash
bash scripts/opencode-auth-profile.sh status
bash scripts/opencode-auth-profile.sh save go-main
bash scripts/opencode-auth-profile.sh save go-backup
bash scripts/opencode-auth-profile.sh use go-main
bash scripts/opencode-auth-profile.sh use go-backup
```

Suggested setup:

1. Connect the first OpenCode Go account with `/connect`.
2. Run `bash scripts/opencode-auth-profile.sh save go-main`.
3. Connect the second OpenCode Go account with `/connect`.
4. Run `bash scripts/opencode-auth-profile.sh save go-backup`.
5. Switch with `use go-main` or `use go-backup`.

## Does Memory Disappear When Switching?

Local OpenCode session history is stored separately from provider credentials, so switching provider keys should not delete local sessions.

What can change:

- account quota and billing bucket
- provider-side cache/account state
- any server-side memory a provider may maintain
- active stream/session behavior until OpenCode restarts

Best practice: switch between tasks or after a checkpoint, not halfway through a delicate edit. If switching mid-task, create a handoff first.

## OpenCode Go Default Model

Current hard-task default:

```text
opencode-go/deepseek-v4-pro
```

Reason: OpenCode's live Go docs and model endpoint list `deepseek-v4-pro`, `deepseek-v4-flash`, and `mimo-v2.5-pro` as separate current model IDs. For one universal hard-task default, DeepSeek V4 Pro is the best choice because it has much more OpenCode Go request headroom than MiMo-V2.5-Pro, while current coding usage data still favors it as the stronger general coding default. Keep DeepSeek V4 Flash as the sustainable high-volume lane.

Use escalation models deliberately:

- `opencode-go/deepseek-v4-flash` for long sessions, broad exploration, and quota-efficient volume.
- `opencode-go/mimo-v2.5-pro` as a second-opinion specialist when DeepSeek stalls or you want a different reasoning style.
- `opencode-go/kimi-k2.6` when you want a different strong reasoning style and can afford lower volume.
- `opencode-go/glm-5.1` only for occasional deep review or benchmark-sensitive work because it has the lowest Go request allowance.

Verify the live Go model list before major changes:

```bash
curl -fsSL https://opencode.ai/zen/go/v1/models
```

Switch model profiles with the helper instead of hand-editing JSON:

```bash
bash scripts/opencode-model-profile.sh status
bash scripts/opencode-model-profile.sh sustainable-go
bash scripts/opencode-model-profile.sh quality-go
bash scripts/opencode-model-profile.sh hard-go
bash scripts/opencode-model-profile.sh free
```

The helper backs up the config, updates the top-level default and explicit agent model fields together, and validates JSON after writing.

## Pi Harness Evaluation

Pi is worth testing, not replacing OpenCode with immediately.

Current stance:

- Keep OpenCode as the stable daily harness while the Go subscription is active.
- Trial Pi in a separate folder/session for workflow experiments, especially custom compaction, commands, skills, git checkpoints, and UI/extension ideas.
- Do not migrate the whole workflow until the same task can be completed in both harnesses with equal or better speed, safety, and recovery.

Why Pi is interesting:

- It is intentionally minimal: built-in `read`, `write`, `edit`, and `bash` tools.
- It supports extensions, skills, prompt templates, themes, branching, compaction, and session trees.
- It is designed for building missing workflow features in the harness instead of waiting for the upstream app to add them.

OpenCode Go billing is not transferable as a subscription, but Pi's provider list includes OpenCode Go API-key support. Treat this as "reuse the Go API key from another harness if compatible", not as moving the subscription itself.

Migration gate:

```text
Only move the default workflow to Pi after a controlled bakeoff:
same task, same model, same repo, same verification, compare speed/safety/recovery.
```

## Prompting Best Practices To Keep In The Workflow

Frontier-model guidance from OpenAI and Anthropic converges on the same operating pattern:

- state the outcome and success criteria
- provide only relevant context
- let the model ask for missing high-impact information
- use examples when behavior is hard to describe
- keep stable instructions stable for caching
- use structured outputs or strict formats when downstream parsing matters
- evaluate on representative examples rather than vibes

In this workspace, that maps to:

- `/route` decides the lane
- `/prompt-contract` turns prompting best practices into a compact self-check
- `/shape-product` asks for final-experience details
- `/repo-map` and retrieval keep context deliberate
- `/plan` and `/implement` require verification paths
- `/handoff` preserves continuity when switching model/provider/session

The goal is not to imitate one lab's environment exactly. It is to learn the frontier habit: specify outcomes, expose uncertainty, verify with evidence, and compress lessons into the system.
