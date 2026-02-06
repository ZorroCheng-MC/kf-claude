---
description: Publish note to GitHub Pages (sharehub) with proper image handling
argument-hint: [filename] (note to publish, e.g., my-article.md)
allowed-tools:
  - Bash(*)
  - Read(*)
  - Task(*)
  - WebFetch(*)
---

## Task

Publish note to GitHub Pages using the publish agent.

**Input**: `$ARGUMENTS` (filename with or without .md extension)
**Operation**: Publish to GitHub Pages with image handling and deployment verification

## Implementation

Spawn a publish agent to handle the workflow:

```
Use the Task tool with subagent_type="general-purpose" to:

1. Read config from .claude/config.local.json to get sharehub_url and sharehub_repo
2. Run the publish script:
   PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/kf-claude/kf-claude"
   "$PLUGIN_DIR/scripts/core/publish.sh" "$ARGUMENTS" "$(pwd)"
3. The script will:
   - Copy images to sharehub repository
   - Convert image paths for the custom domain
   - Git commit and push
   - Wait and verify the page is reachable (up to 60 seconds)
   - Report the final URL
4. If the script's verification passes, report success with the URL
5. If verification times out, still provide the URL with a note about pending deployment
```

## Agent Prompt

```
You are a publish agent. Publish the note "$ARGUMENTS" to GitHub Pages.

Steps:
1. Run the publish script:
   PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/kf-claude/kf-claude"
   "$PLUGIN_DIR/scripts/core/publish.sh" "$ARGUMENTS" "/Users/zorro/Documents/Obsidian/Claudecode"

2. Parse the script output:
   - If "✅ Published successfully!" appears with a URL, report success
   - If "⚠️ Published but page not yet reachable" appears, report partial success
   - If errors occur, report the issue

3. Return a concise summary with the published URL.
```

## Configuration

The script reads from `.claude/config.local.json`:

```json
{
  "sharehub_url": "https://sharehub.zorro.hk",
  "sharehub_repo": "~/Dev/sharehub"
}
```

## Image Path Conversion

The script automatically converts for custom domains:
- `./images/file.jpg` → `/images/file.jpg`
- `images/file.jpg` → `/images/file.jpg`
- External URLs (https://...) remain unchanged

For GitHub Pages subdirectory URLs, it uses the repo name prefix.

## Password Protection

Add `access: private` to frontmatter for password-protected documents:

```yaml
---
title: "Confidential Document"
access: private
---
```

**Password**: "maco" (shared password for all private documents)

## Examples

```
/kf-claude:publish my-article.md
/kf-claude:publish KFE/KF-MIGRATION-CHECKLIST.md
```

## Troubleshooting

- **"Config not found"**: Run `/kf-claude:setup` first
- **"sharehub_repo not configured"**: Run `/kf-claude:setup` and provide sharehub path
- **"Sharehub repo not found"**: Clone sharehub or check path in config
- **"File not found"**: Check filename and ensure you're in vault directory
- **Verification timeout**: Page may still be deploying; check URL in a minute
