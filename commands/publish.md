---
description: Publish note to GitHub Pages (sharehub) with proper image handling
argument-hint: [filename] (note to publish, e.g., my-article.md)
allowed-tools:
  - Bash(*)
  - Read(*)
---

## Task

Publish note to GitHub Pages using the bundled publish script.

**Input**: `$ARGUMENTS` (filename with or without .md extension)
**Operation**: Publish to GitHub Pages with image handling

## Prerequisites

Run `/kf-claude:setup` first to configure:
- `sharehub_repo` - Path to your sharehub repository
- `sharehub_url` - Your GitHub Pages URL

## Implementation

Run the bundled publish script:

```bash
PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/kf-claude/kf-claude"
VAULT_PATH="$(pwd)"

# Check config exists
if [[ ! -f ".claude/config.local.json" ]]; then
    echo "❌ Config not found. Run /kf-claude:setup first"
    exit 1
fi

# Run publish script
"$PLUGIN_DIR/scripts/core/publish.sh" "$ARGUMENTS" "$VAULT_PATH"
```

The script will:
1. Read sharehub path from `.claude/config.local.json`
2. Validate note exists in vault
3. Find all image references in note
4. Copy images from vault to sharehub repository
5. Convert image paths for GitHub Pages
6. Copy note with converted paths to sharehub/documents/
7. Git commit and push to GitHub
8. Output the published URL

## Configuration

The script reads from `.claude/config.local.json`:

```json
{
  "vault_path": "/path/to/vault",
  "sharehub_url": "https://username.github.io/sharehub",
  "sharehub_repo": "~/Dev/sharehub"
}
```

## Image Path Conversion

The script automatically converts:
- `./images/file.jpg` → `/sharehub/images/file.jpg`
- `images/file.jpg` → `/sharehub/images/file.jpg`
- External URLs (https://...) remain unchanged

## Expected Output

After successful publish:
- ✅ Images copied to sharehub repository
- ✅ Note copied with converted paths
- ✅ Git commit created with proper message
- ✅ Pushed to GitHub
- ✅ GitHub Pages deployment triggered
- ✅ Published URL displayed

## Examples

**Publish with extension:**
```
/kf-claude:publish my-article.md
```

**Publish without extension (auto-adds .md):**
```
/kf-claude:publish my-article
```

**Publish from subdirectory:**
```
/kf-claude:publish KFE/KF-MIGRATION-CHECKLIST.md
```

## Password Protection (Sharehub Feature)

**Sharehub supports password-protected documents via frontmatter!**

### To Make a Document Private:

Add `access: private` to the frontmatter:

```yaml
---
title: "Confidential Document"
access: private
---
```

**How it works:**
- Documents **without** `access: private` → Publicly accessible
- Documents **with** `access: private` → Password-protected
- **Password**: "maco" (shared password for all private documents)
- **Session**: Password remembered until browser closed

## Troubleshooting

- **"Config not found"**: Run `/kf-claude:setup` first
- **"sharehub_repo not configured"**: Run `/kf-claude:setup` and provide sharehub path
- **"Sharehub repo not found"**: Clone sharehub or check path in config
- **"File not found"**: Check filename and ensure you're in vault directory
