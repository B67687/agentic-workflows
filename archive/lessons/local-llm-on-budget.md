# Local LLM on a Budget

A practical guide to running LLMs locally — starting with what you have today.

**Last updated:** 2026-04-25

## The Bottom Line

**You don't need expensive hardware to get started.**

| What you have | What you can run | Max tokens/sec |
|--------------|-----------------|---------------|
| Apple Silicon (any) | Qwen 3 7B, Llama 3.1 8B | 15-30 |
| RTX 3060 12GB | Qwen 3 14B, CodeLlama 13B | 15-25 |
| RTX 4060 Ti 16GB | Qwen 3 14B, DeepSeek V3 14B | 20-35 |
| RTX 4090 24GB | Qwen 3 32B, Llama 3.1 70B (Q4) | 40-60 |
| CPU only | Qwen 2.5 3B, Mistral 7B | 1-5 |

**The actual cost:** Electricity only. ~$0.02-0.05/hour on a modern GPU.

---

## When Local Makes Sense

### Do use local for:
- Repetitive boilerplate generation
- Simple refactoring (rename, extract function)
- Writing tests for well-defined code
- Learning/practice without per-token cost

### Don't use local for:
- Complex architecture decisions
- Multi-step refactoring with ambiguity
- Novel problem-solving
- Tasks where you're unsure what "done" looks like

---

## Quick Start (5 minutes)

### 1. Install Ollama

```bash
# macOS
brew install ollama

# Windows
winget install Ollama.Ollama

# Linux
curl -fsSL https://ollama.com/install.sh | sh
```

### 2. Pull a model

```bash
# Best for coding (recommended starter)
ollama pull qwen2.5-coder:7b

# Alternative - good general purpose
ollama pull llama3.1:8b

# Lightweight - runs on anything
ollama pull mistral:7b
```

### 3. Run it

```bash
ollama run qwen2.5-coder:7b
```

That's it. You have a running LLM locally.

---

## OpenCode Integration

OpenCode supports OpenAI-compatible APIs. Point it to your local Ollama:

```json
{
  "OPENAI_API_KEY": "ollama",
  "OPENAI_API_BASE": "http://localhost:11434/v1"
}
```

Or in OpenCode settings, set:
- API Base: `http://localhost:11434/v1`
- API Key: any non-empty string

---

## Model Recommendations by Use Case

| Use case | Model | Size | VRAM needed |
|---------|-------|------|------------|
| Daily coding | Qwen 2.5 Coder | 7B | ~4 GB |
| Larger context | Qwen 2.5 Coder | 14B | ~8 GB |
| Best quality | Qwen 3 32B | 32B (Q4) | ~16 GB |
| Lightest | Mistral 7B | 7B | ~4 GB |

**Qwen 2.5 Coder is the current best value for coding.** It beats similarly-sized models on code tasks and handles tool calling.

---

## The Real Costs (2026)

### Own hardware
| GPU | Price | Break-even vs $50/mo API |
|-----|-------|------------------------|
| RTX 4060 Ti 16GB | ~$400 | 8 months |
| RTX 4090 24GB | ~$1600 | 16 months |

### Cloud GPU (occasionally)
| Provider | Price/hr | Use case |
|----------|----------|---------|
| RunPod RTX 4090 | $0.29 | Testing, bursts |
| Ollama Cloud | $0.20+ | Don't — just run local |

### Monthly API comparison
| Model | Approx monthly (moderate use) |
|-------|--------------------------|
| Claude Sonnet 4.6 | $20-50 |
| GPT-4.1 | $15-40 |
| Local (electricity) | $2-4 |

---

## Upgrade Path

```
Today: Try Ollama on what you have
    ↓
Q3/Q4 2026: Re-evaluate local model quality
    ↓
2027: Consider RTX 5060 or cheaper GPUs
```

**Current recommendation:** Don't buy hardware yet. Model quality improves faster than hardware prices drop.

---

## Troubleshooting

### "It's too slow"
- Lower context window: `ollama run qwen2.5-coder:7b --context 4096`
- Use a smaller model: `qwen2.5-coder:3b`

### "It doesn't know my codebase"
- Paste the relevant code into the conversation
- Or use a context-aware tool like `aider` with local models

### "Output quality is worse than Claude"
- This is expected. Local models are 1-2 generations behind frontier.
- Use local for simple tasks, Claude for complex ones.

---

## Further Reading

- [Ollama docs](https://ollama.com)
- [OpenCode docs](https://opencode.com)
- [Qwen 2.5 Coder](https://qwenlm.github.io) — best local coding model (2026)