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

    2. Read the file content into a variable, then run this Python script.
       IMPORTANT: Write the note content to a temp file first to avoid shell escaping issues.

    ```bash
    # Step A: Write note content to temp file
    cat > /tmp/share_note.md << 'NOTE_EOF'
    <PASTE_NOTE_CONTENT_HERE>
    NOTE_EOF

    # Step B: Run Python to generate URL with integrity check
    python3 << 'PYTHON_SCRIPT'
    import json
    import zlib
    import base64
    import subprocess
    import sys

    # Read content from temp file (avoids shell escaping issues)
    with open('/tmp/share_note.md', 'r') as f:
        content = f.read()

    # CRC32 for integrity verification
    def crc32_str(s):
        crc = 0xFFFFFFFF
        for ch in s.encode('utf-8'):
            crc = crc ^ ch
            for _ in range(8):
                crc = (0xEDB88320 ^ (crc >> 1)) if (crc & 1) else (crc >> 1)
        return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF

    # Create structure with checksum
    data = {"p": content, "a": []}
    payload = json.dumps({"p": content, "a": []}, ensure_ascii=False, separators=(',', ':'))
    data["_crc"] = crc32_str(payload)

    # Compress and encode
    json_str = json.dumps(data, ensure_ascii=False)
    compressed = zlib.compress(json_str.encode('utf-8'))
    encoded = base64.urlsafe_b64encode(compressed).decode('utf-8')

    # Generate URL
    url = f"https://sharehub.zorro.hk/share#{encoded}"
    url_len = len(url)

    print(url)
    print(f"\n--- URL length: {url_len} chars ---", file=sys.stderr)

    if url_len > 8000:
        print(f"⚠️  WARNING: URL is {url_len} chars. URLs over 8000 chars are often truncated by messaging apps.", file=sys.stderr)
        print("Consider using /publish instead for large notes.", file=sys.stderr)
    elif url_len > 4000:
        print(f"⚠️  CAUTION: URL is {url_len} chars. Some platforms may truncate this.", file=sys.stderr)
        print("Tip: Share via code block or plain text to avoid truncation.", file=sys.stderr)

    # Copy to clipboard
    subprocess.run(['pbcopy'], input=url.encode(), check=True)

    # Cleanup
    import os
    os.unlink('/tmp/share_note.md')
    PYTHON_SCRIPT
    ```

    3. Return the shareable URL and confirm it was copied to clipboard.
       Include the URL length and any warnings from stderr output.

    If the URL is over 4000 chars, warn the user about potential truncation.
    If over 8000 chars, strongly recommend using `/publish` instead.
```

## Features

- **No server storage**: Content lives entirely in the URL
- **Compression**: zlib reduces URL length
- **Integrity check**: CRC32 checksum detects URL corruption from truncation
- **Annotations**: Recipients can add comments and re-share
- **Compatible**: Same format as Plannotator

## Examples

```
/kf-claude:share my-note.md
/kf-claude:share paydollar-test-plan
```

## Limitations

- URLs over ~4000 chars may be truncated by messaging apps (Slack, WhatsApp, email)
- URLs over ~8000 chars will almost certainly be truncated - use `/publish` instead
- Always share URLs in code blocks or plain text to minimize truncation risk
