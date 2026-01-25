---
description: Interactive setup wizard for Obsidian Vault Manager
allowed-tools:
  - Bash(*)
  - Read(*)
  - Write(*)
---

## Context

- **Current Directory:** `$PWD`
- **Plugin Location:** `~/.claude/plugins/marketplaces/obsidian-vault-manager-plugin/`

## Task

Run the interactive setup wizard to configure Obsidian Vault Manager for this vault.

**Important:** You must run Claude Code from your Obsidian vault directory for this setup to work correctly.

## Implementation

Execute the setup script from the plugin directory:

```bash
# Locate the plugin installation
PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/obsidian-vault-manager-plugin"

# Check if plugin is installed
if [[ ! -d "$PLUGIN_DIR" ]]; then
    echo "❌ Plugin not found. Please install it first:"
    echo "   claude plugin add obsidian-vault-manager"
    exit 1
fi

# Run setup script
SETUP_SCRIPT="$PLUGIN_DIR/scripts/setup.sh"

if [[ -f "$SETUP_SCRIPT" ]]; then
    chmod +x "$SETUP_SCRIPT"
    bash "$SETUP_SCRIPT"
else
    echo "❌ Setup script not found at: $SETUP_SCRIPT"
    echo "Plugin may be corrupted. Try reinstalling:"
    echo "   claude plugin remove obsidian-vault-manager"
    echo "   claude plugin add obsidian-vault-manager"
    exit 1
fi
```

## What This Does

The setup wizard will:

1. **Detect Your Vault**
   - Verifies you're in an Obsidian vault (checks for `.obsidian/` folder)
   - Confirms the vault path

2. **Check Dependencies**
   - uv/uvx (for YouTube transcripts)
   - jq (for JSON processing)
   - python3 (for image path conversion)
   - git (for publishing)

3. **Configure GitHub Pages** (optional)
   - GitHub Pages repository path
   - GitHub Pages URL
   - Repository name

4. **Create Configuration Files**
   - `.claude/settings.local.json` (vault-specific settings)
   - `.claude/config.sh` (for bash scripts)
   - `.claude/.gitignore` (prevents committing personal paths)

## After Setup

Your vault will have:

```
your-vault/
└── .claude/
    ├── settings.local.json    (vault-specific configuration)
    ├── config.sh              (script configuration)
    └── .gitignore             (prevents committing personal paths)
```

## Troubleshooting

**"Not in vault directory"**
- Make sure you `cd` to your vault first
- Check that `.obsidian/` folder exists

**"Plugin not found"**
- Install plugin: `claude plugin add obsidian-vault-manager`

**"Missing dependencies"**
- Install with: `brew install uv jq git`

## Re-running Setup

You can run `/setup` again to:
- Update paths
- Reconfigure GitHub Pages
- Fix broken configuration

Existing configuration will be overwritten.
