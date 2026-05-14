# Agent Skills Specification

Source: [agentskills.io/specification](https://agentskills.io/specification)

## Directory structure

A skill is a directory containing, at minimum, a `SKILL.md` file:

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...               # Any additional files or directories
```

## `SKILL.md` format

The `SKILL.md` file must contain YAML frontmatter followed by Markdown content.

### Frontmatter

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | Max 64 characters. Lowercase letters, numbers, and hyphens only. Must not start or end with a hyphen. Must match parent directory name. |
| `description` | Yes | Max 1024 characters. Non-empty. Describes what the skill does and when to use it. |
| `status` | No | One of: `active` (default), `deprecated` (no longer recommended), `archived` (inactive, historical). Affects toolset filtering. |
| `license` | No | License name or reference to a bundled license file. |
| `compatibility` | No | Max 500 characters. Indicates environment requirements. |
| `metadata` | No | Arbitrary key-value mapping for additional metadata. |
| `allowed-tools` | No | Space-separated string of pre-approved tools. (Experimental) |

#### name validation

Must match regex: `^[a-z0-9]+(-[a-z0-9]+)*$`
- 1-64 characters
- Lowercase letters, numbers, and hyphens only
- Must not start or end with a hyphen
- Must not contain consecutive hyphens
- Must match the parent directory name

#### description

- 1-1024 characters
- Should describe both what the skill does and when to use it
- Should include specific keywords that help agents identify relevant tasks

### Body content

The Markdown body after the frontmatter contains the skill instructions.
No format restrictions. Recommended sections:
- Step-by-step instructions
- Examples of inputs and outputs
- Common edge cases

## Optional directories

- **`scripts/`**: Executable code (Python, Bash, JavaScript)
- **`references/`**: Additional documentation loaded on demand
- **`assets/`**: Static resources (templates, images, data files)

## Progressive disclosure

1. **Metadata** (~100 tokens): name + description loaded at startup
2. **Instructions** (<5000 tokens recommended): full SKILL.md body on activation
3. **Resources** (as needed): files from references/, assets/, scripts/ on demand

## File references

Use relative paths from the skill root. Keep one level deep.
