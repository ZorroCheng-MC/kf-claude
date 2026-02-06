---
description: Publish note to GitHub Pages (sharehub) with proper image handling
argument-hint: [filename] (note to publish, e.g., my-article.md)
allowed-tools:
  - Task(*)
---

## Task

Publish note to GitHub Pages using a dedicated publish agent.

**Input**: `$ARGUMENTS` (filename with or without .md extension)

## Implementation

**IMPORTANT: Always spawn an agent for this task.**

Use the Task tool with these exact parameters:

```
Task tool call:
  subagent_type: "general-purpose"
  description: "Publish note to sharehub"
  prompt: |
    Publish the note "$ARGUMENTS" to GitHub Pages.

    Run this command:
    ```bash
    PLUGIN_DIR="$HOME/.claude/plugins/marketplaces/kf-claude/kf-claude"
    "$PLUGIN_DIR/scripts/core/publish.sh" "$ARGUMENTS" "/Users/zorro/Documents/Obsidian/Claudecode"
    ```

    After the script completes:
    - If you see "✅ Published successfully!" with a URL, report SUCCESS with the URL
    - If you see "⚠️ Published but page not yet reachable", report the URL with a note about pending deployment
    - If errors occur, report the specific error

    Return a concise summary with the published URL.
```

## Examples

```
/kf-claude:publish my-article.md
/kf-claude:publish KFE/KF-MIGRATION-CHECKLIST.md
```

## Password Protection

Add `access: private` to frontmatter for password-protected documents (password: "maco").
