# Quickstart: Switch to Linux (WSL2)

Goal: Switch opencode from Windows to WSL2 (Ubuntu). Continue working seamlessly on Linux.

## Steps

### 1. Verify WSL2 Installation

If WSL2 is not installed:

```powershell
wsl --install -d Ubuntu
```

Then restart Windows and set up Ubuntu user.

### 2. Install Opencode on WSL2/Ubuntu

```bash
curl -fsSL https://opencode.ai/install | bash
```

Verify:

```bash
opencode --version
```

### 3. Transfer Config from Windows to WSL2

Create directories and copy:

```bash
mkdir -p ~/.config/opencode
mkdir -p ~/.local/share/opencode

# Config (~/.config/opencode/)
cp /mnt/c/Users/<YourUser>/AppData/Roaming/opencode/opencode.json ~/.config/opencode/opencode.json 2>/dev/null || true

# Auth/API keys (~/.local/share/opencode/)
cp /mnt/c/Users/<YourUser>/AppData/Roaming/opencode/auth.json ~/.local/share/opencode/auth.json 2>/dev/null || true

# Sessions (if they exist)
cp -r /mnt/c/Users/<YourUser>/AppData/Roaming/opencode/sessions ~/.local/share/opencode/sessions 2>/dev/null || true
```

### 4. Re-authenticate

API keys in auth.json may be stale. Re-run:

```bash
opencode auth login
```

### 5. Verify

```bash
opencode --version
opencode run "Hello world, respond in 3 words"
```

## Data Locations

| Data | Windows | WSL |
|------|---------|-----|
| Config | `%APPDATA%\opencode\` | `~/.config/opencode/` |
| Auth | `%APPDATA%\opencode\auth.json` | `~/.local/share/opencode/auth.json` |
| Sessions | `%APPDATA%\opencode\sessions\` | `~/.local/share/opencode/sessions/` |

## Known Issues

- Path differences: use `/mnt/c/` to access Windows files from WSL
- API keys: re-authenticate with `opencode auth login` after transfer
- Shell compatibility: opencode prefers bash on Linux
