---
description: Share note via URL-encoded link (Plannotator-style, no server storage)
argument-hint: [filename] (note to share, e.g., my-note.md)
allowed-tools:
  - Bash(*)
  - Read
---

## Task

Generate a shareable URL for a note using Base64 + zlib compression (Plannotator-compatible format).

**Input**: `$ARGUMENTS` (filename with or without .md extension)
**Output**: Shareable URL that can be opened by anyone

## Implementation

### Step 1: Read the Note

```bash
VAULT_PATH="/Users/zorro/Documents/Obsidian/Claudecode"
FILENAME="$ARGUMENTS"

# Add .md extension if missing
if [[ ! "$FILENAME" =~ \.md$ ]]; then
    FILENAME="${FILENAME}.md"
fi

NOTE_PATH="$VAULT_PATH/$FILENAME"
```

Read the note content using the Read tool.

### Step 2: Generate Shareable URL

Use Python to compress and encode:

```bash
python3 << 'PYTHON_SCRIPT'
import sys
import json
import zlib
import base64

# Read content from stdin or file
content = """$NOTE_CONTENT"""

# Create Plannotator-compatible structure
data = {
    "p": content,  # Plan/content
    "a": []        # Annotations (empty initially)
}

# Compress with zlib
json_str = json.dumps(data, ensure_ascii=False)
compressed = zlib.compress(json_str.encode('utf-8'))

# Base64 URL-safe encode
encoded = base64.urlsafe_b64encode(compressed).decode('utf-8')

# Generate URL
url = f"https://zorrocheng-mc.github.io/sharehub/share#{encoded}"

print(f"\n📤 **Shareable URL:**\n")
print(f"```\n{url}\n```")
print(f"\n📋 URL copied to clipboard (if pbcopy available)")

# Try to copy to clipboard
import subprocess
try:
    subprocess.run(['pbcopy'], input=url.encode(), check=True)
except:
    pass
PYTHON_SCRIPT
```

### Step 3: Output Result

Display:
- The shareable URL
- Instructions for the recipient
- Note about URL length (warn if very long)

## URL Structure

```
https://zorrocheng-mc.github.io/sharehub/share#<compressed-base64>
```

The data structure matches Plannotator:
```json
{
  "p": "# Note content...",
  "a": [["C", "section", "comment", "session-id", null]]
}
```

## Features

- **No server storage**: Content lives entirely in the URL
- **Compression**: zlib reduces URL length
- **Annotations**: Recipients can add comments and re-share
- **Compatible**: Same format as Plannotator

## Example

```
/share my-note.md
```

Output:
```
📤 Shareable URL:

https://zorrocheng-mc.github.io/sharehub/share#eJxLTEoGAAJYAUI=

📋 URL copied to clipboard
```

## Limitations

- Very large notes (>10KB) may create long URLs
- Some platforms truncate long URLs when sharing
- For large content, consider using `/publish` instead
