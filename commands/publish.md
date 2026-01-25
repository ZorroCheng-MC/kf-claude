---
description: Publish note to GitHub Pages (sharehub) with proper image handling
argument-hint: [filename] (note to publish, e.g., my-article.md)
allowed-tools:
  - Bash(*)
  - mcp__fetch__fetch
  - mcp__github__*
---

## Task

Publish note to GitHub Pages using the bundled publish script.

**Input**: `$ARGUMENTS` (filename with or without .md extension)
**Operation**: Publish to GitHub Pages with image handling

## Implementation

Run the bundled publish script directly:

```bash
SKILL_DIR="$HOME/.claude/skills/obsidian-vault-manager"
"$SKILL_DIR/scripts/core/publish.sh" "$ARGUMENTS"
```

The script will:
1. Validate note exists in vault
2. Find all image references in note
3. Copy images from vault to sharehub repository
4. Convert image paths (./images/ → /sharehub/images/)
5. Copy note with converted paths to sharehub/documents/
6. Git commit and push to GitHub
7. Output the published URL

## After Script Completes

1. Wait for GitHub Pages deployment (~60 seconds):
   ```bash
   sleep 60
   ```

2. Verify published page using `mcp__fetch__fetch`

## Publishing Configuration

- **Vault Path**: `/Users/zorro/Documents/Obsidian/Claudecode`
- **Sharehub Path**: `/Users/zorro/Dev/sharehub`
- **Repository**: `ZorroCheng-MC/sharehub`
- **GitHub Pages URL**: `https://zorrocheng-mc.github.io/sharehub`

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
- ✅ Published URL: `https://zorrocheng-mc.github.io/sharehub/documents/{filename}.html`

## Examples

**Publish with extension:**
```
/publish my-article.md
```

**Publish without extension (auto-adds .md):**
```
/publish my-article
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

### Example: Publishing Private Document

**Frontmatter:**
```yaml
---
title: "Claude Dev Users: Multi-User Docker Environment"
tags:
  - repository
  - docker
  - infrastructure
access: private
---
```

**Result:**
- Document published to sharehub
- Requires password "maco" to view
- Listed in index with 🔒 lock icon (after login)

### Index Page Behavior

- **Before login**: Shows only public documents
- **After login**: Shows all documents (public + private) with 🔒 icons

### Publishing Workflow

1. **Add `access: private` to frontmatter** (if needed)
2. **Run `/publish filename.md`**
3. **Script publishes** to sharehub/documents/
4. **GitHub Pages builds** (~60 seconds)
5. **Document accessible** with password protection

### Important Notes

- **Default**: Documents are public unless `access: private` is specified
- **Password**: All private documents use "maco"
- **No folder restrictions**: Protection is tag-based, not folder-based
- **Session storage**: Login persists until browser closed

## Quality Checklist

Before publishing, verify:
- [ ] Note has proper frontmatter (title, tags, date)
- [ ] Add `access: private` if document contains sensitive information
- [ ] Images exist in vault at specified paths
- [ ] Image paths are relative (./images/ or images/)
- [ ] Note is ready for viewing (public or password-protected)
