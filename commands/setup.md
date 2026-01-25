---
description: Setup wizard for KnowledgeFactory Claude Code plugin
argument-hint: [--enable-short-commands] (optional: enable /capture instead of /kf-claude:capture)
allowed-tools:
  - Bash(*)
  - Read(*)
  - Write(*)
---

## Context

- **Current Directory:** `$PWD`
- **Plugin Location:** `~/.claude/plugins/marketplaces/kf-claude/`
- **Arguments:** `$ARGUMENTS`

## Task

Run the setup wizard to configure KnowledgeFactory for this vault.

## Step 1: Verify Environment

```bash
# Check we're in an Obsidian vault
if [[ ! -d ".obsidian" ]]; then
    echo "⚠️  Warning: No .obsidian folder found. Are you in an Obsidian vault?"
fi

# Check plugin is installed
PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/kf-claude"
if [[ ! -d "$PLUGIN_DIR" ]]; then
    echo "❌ kf-claude plugin not found at: $PLUGIN_DIR"
    echo "   Install with: /plugin install kf-claude"
    exit 1
fi

echo "✅ kf-claude plugin found"
echo "📂 Vault path: $PWD"
```

## Step 2: Check Dependencies

Verify required tools are available:

```bash
echo "Checking dependencies..."

# Required
command -v git >/dev/null && echo "✅ git" || echo "❌ git (required)"
command -v python3 >/dev/null && echo "✅ python3" || echo "❌ python3 (required)"

# Optional but recommended
command -v jq >/dev/null && echo "✅ jq" || echo "⚠️  jq (optional, install: brew install jq)"
command -v uvx >/dev/null && echo "✅ uvx" || echo "⚠️  uvx (optional, for YouTube transcripts: brew install uv)"
```

## Step 3: Create Vault Configuration

Create `.claude/config.local.json` with vault-specific settings:

```bash
mkdir -p .claude

# Create config if not exists
if [[ ! -f ".claude/config.local.json" ]]; then
    cat > .claude/config.local.json << 'EOF'
{
  "vault_path": "$PWD",
  "sharehub_url": "https://zorrocheng-mc.github.io/sharehub",
  "sharehub_repo": "~/Dev/sharehub",
  "enable_short_commands": false
}
EOF
    echo "✅ Created .claude/config.local.json"
else
    echo "ℹ️  .claude/config.local.json already exists"
fi
```

## Step 4: Enable Short Commands (Optional)

If `--enable-short-commands` is passed, copy commands to vault for direct access:

```bash
if [[ "$ARGUMENTS" == *"--enable-short-commands"* ]]; then
    echo "📝 Enabling short commands..."

    PLUGIN_COMMANDS="$HOME/.claude/plugins/marketplaces/kf-claude/commands"
    VAULT_COMMANDS=".claude/commands"

    mkdir -p "$VAULT_COMMANDS"

    # Copy each command (creates local copies for /capture instead of /kf-claude:capture)
    for cmd in capture.md youtube-note.md idea.md gitingest.md study-guide.md publish.md semantic-search.md share.md; do
        if [[ -f "$PLUGIN_COMMANDS/$cmd" ]]; then
            cp "$PLUGIN_COMMANDS/$cmd" "$VAULT_COMMANDS/$cmd"
            echo "  ✅ /$cmd enabled"
        fi
    done

    echo ""
    echo "✅ Short commands enabled!"
    echo "   You can now use /capture instead of /kf-claude:capture"
else
    echo ""
    echo "ℹ️  Short commands not enabled."
    echo "   Use /kf-claude:capture, /kf-claude:idea, etc."
    echo "   To enable short commands, run: /kf-claude:setup --enable-short-commands"
fi
```

## Step 5: Summary

Display setup summary:

```
🎉 KnowledgeFactory Setup Complete!

Plugin: kf-claude v1.0.0
Vault: $PWD

Available Commands:
  /kf-claude:capture      - Universal content capture
  /kf-claude:youtube-note - YouTube video with transcript
  /kf-claude:idea         - Quick idea capture
  /kf-claude:gitingest    - GitHub repository analysis
  /kf-claude:study-guide  - Generate study materials
  /kf-claude:publish      - Publish to GitHub Pages
  /kf-claude:share        - Generate shareable URL
  /kf-claude:semantic-search - Search vault by meaning

Configuration:
  ~/.claude/plugins/marketplaces/kf-claude/  (plugin)
  .claude/config.local.json                   (vault config)

Need help? https://github.com/ZorroCheng-MC/kf-claude
```

## Re-running Setup

Run `/kf-claude:setup` again to:
- Update configuration
- Enable/disable short commands
- Check dependencies
