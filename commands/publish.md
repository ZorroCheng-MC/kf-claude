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

    After the script completes, check the output:
    
    **Look for these key lines in the output:**
    - `VERIFIED_URL=<url>` → All checks passed (HTTP 200, HTML rendered, images OK)
    - `UNVERIFIED_URL=<url>` → Published but verification failed (broken images, etc.)
    
    **If VERIFIED_URL found:**
    - Report: "✅ Published and verified: <VERIFIED_URL>"
    - This URL is confirmed live, HTML-rendered, with all images working
    
    **If UNVERIFIED_URL found:**
    - Report the specific errors from the verification output
    - Include the URL but note it has issues
    
    **If neither found (script failed):**
    - Look for error messages starting with "❌" or "⚠️"
    - Report the specific issue
    - Common issues:
      • "Jekyll conversion failed" → HTML not generated, check Jekyll config
      • "Image not accessible" → image not uploaded or wrong path
      • "Page not yet reachable" → wait 60s and rerun the script
    
    **If script times out (>2 minutes):**
    - Report: "⚠️ Publish script timeout - GitHub Pages may be slow"
    - Tell user to verify manually in 2-3 minutes
    
    Return: Concise summary with the VERIFIED_URL (1-2 sentences max). The URL MUST be included in your response.
```

## Examples

```
/kf-claude:publish my-article.md
/kf-claude:publish KFE/KF-MIGRATION-CHECKLIST.md
```

## Password Protection

Add `access: private` to frontmatter for password-protected documents (password: "maco").
