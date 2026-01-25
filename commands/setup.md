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
echo "🔧 KnowledgeFactory Setup Wizard"
echo "================================"
echo ""

VAULT_PATH="$(pwd)"

# Check we're in an Obsidian vault
if [[ ! -d ".obsidian" ]]; then
    echo "⚠️  Warning: No .obsidian folder found. Are you in an Obsidian vault?"
    echo "   Current directory: $VAULT_PATH"
    echo ""
fi

# Check plugin is installed
PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/kf-claude"
if [[ ! -d "$PLUGIN_DIR" ]]; then
    echo "❌ kf-claude plugin not found at: $PLUGIN_DIR"
    echo "   Install with: /plugin install kf-claude"
    exit 1
fi

echo "✅ kf-claude plugin found"
echo "📂 Vault path: $VAULT_PATH"
echo ""
```

## Step 2: Check Dependencies

```bash
echo "📦 Checking dependencies..."
echo ""

# Required
command -v git >/dev/null && echo "✅ git" || echo "❌ git (required - brew install git)"
command -v python3 >/dev/null && echo "✅ python3" || echo "❌ python3 (required)"
command -v jq >/dev/null && echo "✅ jq" || echo "❌ jq (required - brew install jq)"

# Optional but recommended
command -v uvx >/dev/null && echo "✅ uvx (YouTube transcripts)" || echo "⚠️  uvx (optional - brew install uv)"

echo ""
```

## Step 3: Check Obsidian Plugins

```bash
echo "🔌 Checking Obsidian plugins..."
echo ""

# Local REST API
REST_API_CONFIG=".obsidian/plugins/obsidian-local-rest-api/data.json"
if [[ -f "$REST_API_CONFIG" ]]; then
    API_KEY=$(jq -r '.apiKey // empty' "$REST_API_CONFIG")
    if [[ -n "$API_KEY" ]]; then
        echo "✅ Local REST API configured (key: ${API_KEY:0:8}...)"
    else
        echo "⚠️  Local REST API plugin found but no API key"
    fi
else
    echo "⚠️  Local REST API not configured"
    echo "   Required for: /kf-claude:semantic-search"
    echo "   Install from Obsidian Community Plugins"
fi

# Smart Connections
if [[ -d ".obsidian/plugins/smart-connections" ]]; then
    echo "✅ Smart Connections installed"
else
    echo "⚠️  Smart Connections not found"
    echo "   Required for: /kf-claude:semantic-search"
fi

echo ""
```

## Step 4: Configure Sharehub (Publishing)

```bash
echo "📤 Configuring publishing setup..."
echo ""

# Check existing config
EXISTING_SHAREHUB=""
if [[ -f ".claude/config.local.json" ]]; then
    EXISTING_SHAREHUB=$(jq -r '.sharehub_repo // empty' .claude/config.local.json | sed "s|^~|$HOME|")
fi

# Default paths to check
DEFAULT_PATHS=(
    "$EXISTING_SHAREHUB"
    "$HOME/Dev/sharehub"
    "$HOME/sharehub"
    "$HOME/Documents/sharehub"
)

SHAREHUB_PATH=""
for path in "${DEFAULT_PATHS[@]}"; do
    if [[ -n "$path" && -d "$path" && -d "$path/.git" ]]; then
        SHAREHUB_PATH="$path"
        break
    fi
done

if [[ -n "$SHAREHUB_PATH" ]]; then
    echo "✅ Sharehub repo found at: $SHAREHUB_PATH"
    REMOTE=$(cd "$SHAREHUB_PATH" && git remote get-url origin 2>/dev/null || echo "none")
    echo "   Remote: $REMOTE"

    # Extract GitHub Pages URL from remote
    if [[ "$REMOTE" =~ github.com[:/]([^/]+)/([^/.]+) ]]; then
        OWNER="${BASH_REMATCH[1]}"
        REPO="${BASH_REMATCH[2]}"
        SHAREHUB_URL="https://${OWNER}.github.io/${REPO}"
        echo "   Pages URL: $SHAREHUB_URL"
    fi
else
    echo "⚠️  Sharehub repo not found in common locations"
    echo ""
    echo "   Please provide your sharehub repo path:"
    echo "   (or press Enter to skip publishing setup)"
    echo ""
    read -p "   Sharehub path: " USER_SHAREHUB_PATH

    if [[ -n "$USER_SHAREHUB_PATH" ]]; then
        # Expand ~ to $HOME
        USER_SHAREHUB_PATH="${USER_SHAREHUB_PATH/#\~/$HOME}"

        if [[ -d "$USER_SHAREHUB_PATH" ]]; then
            SHAREHUB_PATH="$USER_SHAREHUB_PATH"
            echo "   ✅ Using: $SHAREHUB_PATH"
        else
            echo "   ⚠️  Path not found: $USER_SHAREHUB_PATH"
            echo "   Skipping sharehub configuration"
        fi
    else
        echo "   ℹ️  Skipping sharehub configuration"
        echo "   You can set it later in .claude/config.local.json"
    fi
fi

echo ""
```

## Step 5: Create Vault Configuration

```bash
echo "⚙️  Creating configuration..."
echo ""

mkdir -p .claude

# Set defaults if not discovered
SHAREHUB_URL="${SHAREHUB_URL:-https://zorrocheng-mc.github.io/sharehub}"
SHAREHUB_PATH="${SHAREHUB_PATH:-}"

# Convert to ~ notation for config
SHAREHUB_PATH_CONFIG="${SHAREHUB_PATH/#$HOME/~}"

# Create or update config
cat > .claude/config.local.json << EOF
{
  "vault_path": "$VAULT_PATH",
  "sharehub_url": "$SHAREHUB_URL",
  "sharehub_repo": "$SHAREHUB_PATH_CONFIG",
  "enable_short_commands": false
}
EOF

echo "✅ Created .claude/config.local.json"
echo "   vault_path: $VAULT_PATH"
echo "   sharehub_url: $SHAREHUB_URL"
echo "   sharehub_repo: $SHAREHUB_PATH_CONFIG"
```

## Step 6: Enable Short Commands (Optional)

```bash
if [[ "$ARGUMENTS" == *"--enable-short-commands"* ]]; then
    echo ""
    echo "📝 Enabling short commands..."

    PLUGIN_COMMANDS="$HOME/.claude/plugins/marketplaces/kf-claude/commands"
    VAULT_COMMANDS=".claude/commands"

    mkdir -p "$VAULT_COMMANDS"

    # Copy each command
    for cmd in capture.md youtube-note.md idea.md gitingest.md study-guide.md publish.md semantic-search.md share.md; do
        if [[ -f "$PLUGIN_COMMANDS/$cmd" ]]; then
            cp "$PLUGIN_COMMANDS/$cmd" "$VAULT_COMMANDS/$cmd"
            echo "  ✅ /${cmd%.md}"
        fi
    done

    # Update config
    jq '.enable_short_commands = true' .claude/config.local.json > .claude/config.local.json.tmp
    mv .claude/config.local.json.tmp .claude/config.local.json

    echo ""
    echo "✅ Short commands enabled!"
    echo "   You can now use /capture instead of /kf-claude:capture"
else
    echo ""
    echo "ℹ️  Using plugin-prefixed commands (default)"
    echo "   Example: /kf-claude:capture, /kf-claude:idea"
    echo ""
    echo "   To enable short commands, run:"
    echo "   /kf-claude:setup --enable-short-commands"
fi
```

## Step 7: Summary

```bash
echo ""
echo "========================================"
echo "🎉 KnowledgeFactory Setup Complete!"
echo "========================================"
echo ""
echo "Available Commands:"
echo "  /kf-claude:capture        - Universal content capture"
echo "  /kf-claude:youtube-note   - YouTube video with transcript"
echo "  /kf-claude:idea           - Quick idea capture"
echo "  /kf-claude:gitingest      - GitHub repository analysis"
echo "  /kf-claude:study-guide    - Generate study materials"
echo "  /kf-claude:publish        - Publish to GitHub Pages"
echo "  /kf-claude:share          - Generate shareable URL"
echo "  /kf-claude:semantic-search - Search vault by meaning"
echo ""
echo "Configuration Files:"
echo "  ~/.claude/plugins/marketplaces/kf-claude/  (plugin)"
echo "  .claude/config.local.json                   (vault config)"
echo ""
echo "Need help? https://github.com/ZorroCheng-MC/kf-claude"
echo ""
```

## Re-running Setup

Run `/kf-claude:setup` again to:
- Update configuration
- Enable/disable short commands
- Check dependencies and plugins
