---
description: Share note via URL-encoded link (Plannotator-style, no server storage)
argument-hint: [filename] (note to share, e.g., my-note.md)
allowed-tools:
  - Task(*)
---

## Task

Generate a shareable URL for a note using Base64 + zlib compression.

**Input**: `$ARGUMENTS` (filename with or without .md extension)

## Implementation

**IMPORTANT: Always spawn an agent for this task.**

Use the Task tool with these exact parameters:

```
Task tool call:
  subagent_type: "general-purpose"
  description: "Generate shareable URL"
  prompt: |
    Generate a shareable URL for the note "$ARGUMENTS".

    Steps:
    1. Read the note file from /Users/zorro/Documents/Obsidian/Claudecode/$ARGUMENTS
       (add .md extension if missing)

    2. Run this Python script to generate the URL:
    ```bash
    python3 << 'PYTHON_SCRIPT'
    import json
    import zlib
    import base64
    import subprocess

    content = '''<NOTE_CONTENT_HERE>'''

    # Create Plannotator-compatible structure
    data = {"p": content, "a": []}

    # Compress and encode
    json_str = json.dumps(data, ensure_ascii=False)
    compressed = zlib.compress(json_str.encode('utf-8'))
    encoded = base64.urlsafe_b64encode(compressed).decode('utf-8')

    # Generate URL with custom domain
    url = f"https://sharehub.zorro.hk/share#{encoded}"
    print(url)

    # Copy to clipboard
    subprocess.run(['pbcopy'], input=url.encode(), check=True)
    PYTHON_SCRIPT
    ```

    3. Return the shareable URL and confirm it was copied to clipboard.

    If the note is very large (>10KB), warn that some platforms may truncate the URL.
```

## Features

- **No server storage**: Content lives entirely in the URL
- **Compression**: zlib reduces URL length
- **Annotations**: Recipients can add comments and re-share
- **Compatible**: Same format as Plannotator

## Examples

```
/kf-claude:share my-note.md
/kf-claude:share paydollar-test-plan
```

## Limitations

- Very large notes (>10KB) may create long URLs
- Some platforms truncate long URLs when sharing
- For large content, consider using `/publish` instead
