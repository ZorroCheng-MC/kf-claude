---
description: Process files from mobile .inbox folder
allowed-tools:
  - Read(*)
  - Write(*)
  - Bash(*)
---

## Context

You are processing mobile captures from the `.inbox/` folder.

## Your Task

1. **Scan** the `.inbox/` folder for new files (skip README.md and _template.md)
2. **Process each file** using the appropriate command based on content:
   - If contains YouTube links → use youtube-note.md logic
   - If contains repository links → use gitingest.md logic
   - If has #study tag → use study-guide.md logic
   - Otherwise → use idea.md logic
3. **Enhance** the note with:
   - Better formatting
   - Auto-generated tags
   - Proper YAML frontmatter
   - Date stamps
4. **Save** processed notes to `/notes` folder
5. **Publish** to ShareHub if tagged with #publish
6. **Delete** original file from `.inbox/`
7. **Report** what was processed

## Processing Logic

```bash
# Example workflow
for file in .inbox/*.md; do
  if [[ "$file" != *"README"* && "$file" != *"template"* ]]; then
    # Read file
    # Detect content type
    # Process with appropriate logic
    # Save to notes/
    # If #publish tag, copy to ~/Dev/sharehub/
    # Delete from inbox
  fi
done
```

## Output Format

After processing, provide a summary:
```
📱 Mobile Inbox Processed

✅ Processed: 3 files
📝 Created notes:
  - 2025-11-03-youtube-ai-tutorial.md
  - 2025-11-03-github-repo-analysis.md
  - 2025-11-03-random-idea.md

📰 Published: 1 file
  - 2025-11-03-youtube-ai-tutorial.md → ShareHub

🗑️  Cleaned: .inbox/ folder is now empty
```
