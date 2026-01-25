#!/bin/bash
# Publish Obsidian note to GitHub Pages (sharehub)
# Handles image copying and path conversion
# Usage: ./publish.sh NOTE_FILE [VAULT_PATH]

set -e  # Exit on error

NOTE_FILE="$1"
VAULT_PATH="${2:-$(pwd)}"

# Read config from vault
CONFIG_FILE="$VAULT_PATH/.claude/config.local.json"

if [[ -f "$CONFIG_FILE" ]]; then
    # Read paths from config
    SHAREHUB_PATH=$(jq -r '.sharehub_repo // empty' "$CONFIG_FILE" | sed "s|^~|$HOME|")
    SHAREHUB_URL=$(jq -r '.sharehub_url // empty' "$CONFIG_FILE")

    if [[ -z "$SHAREHUB_PATH" || "$SHAREHUB_PATH" == "null" ]]; then
        echo "❌ sharehub_repo not configured in .claude/config.local.json"
        echo "   Run /kf-claude:setup to configure"
        exit 1
    fi
else
    echo "❌ Config not found: $CONFIG_FILE"
    echo "   Run /kf-claude:setup first"
    exit 1
fi

# Default URL if not in config
SHAREHUB_URL="${SHAREHUB_URL:-https://zorrocheng-mc.github.io/sharehub}"

# Extract repo name from URL for image path conversion
REPO_NAME=$(basename "$SHAREHUB_URL")

echo "📂 Vault: $VAULT_PATH"
echo "📤 Sharehub: $SHAREHUB_PATH"
echo "🌐 URL: $SHAREHUB_URL"
echo ""

# Add .md extension if not provided
if [[ ! "$NOTE_FILE" =~ \.md$ ]]; then
    NOTE_FILE="${NOTE_FILE}.md"
fi

# Check if file exists in vault
if [[ ! -f "$VAULT_PATH/$NOTE_FILE" ]]; then
    echo "❌ Error: File not found: $NOTE_FILE"
    echo "Looking in: $VAULT_PATH/"
    exit 1
fi

# Check if sharehub exists
if [[ ! -d "$SHAREHUB_PATH" ]]; then
    echo "❌ Sharehub repo not found at: $SHAREHUB_PATH"
    echo "   Clone it first or update .claude/config.local.json"
    exit 1
fi

echo "✅ Found note: $NOTE_FILE"
echo ""

# Extract and copy referenced images
cd "$VAULT_PATH"

# Find all image references (macOS compatible)
IMAGE_PATHS=$(grep -o '!\[[^]]*\]([^)]*\.\(jpg\|jpeg\|png\|gif\|svg\|webp\))' "$NOTE_FILE" | sed 's/.*(\(.*\))/\1/' || true)

if [[ -n "$IMAGE_PATHS" ]]; then
    echo "📸 Found images to copy:"
    echo "$IMAGE_PATHS"
    echo ""

    # Copy each image to sharehub
    while IFS= read -r IMG_PATH; do
        # Skip if empty or URL (http/https)
        if [[ -z "$IMG_PATH" ]] || [[ "$IMG_PATH" =~ ^https?:// ]]; then
            continue
        fi

        # Normalize path (remove leading ./)
        CLEAN_PATH="${IMG_PATH#./}"

        # Source path in vault
        SRC="$VAULT_PATH/$CLEAN_PATH"

        # Destination path in sharehub (preserve directory structure)
        DEST="$SHAREHUB_PATH/$CLEAN_PATH"
        DEST_DIR=$(dirname "$DEST")

        if [[ -f "$SRC" ]]; then
            # Create destination directory if needed
            mkdir -p "$DEST_DIR"

            # Copy image
            cp "$SRC" "$DEST"
            echo "  ✅ Copied: $CLEAN_PATH"
        else
            echo "  ⚠️  Not found: $SRC"
        fi
    done <<< "$IMAGE_PATHS"
    echo ""
else
    echo "ℹ️  No local images found in note"
    echo ""
fi

# Read note content
NOTE_CONTENT=$(cat "$NOTE_FILE")

# Convert image paths for GitHub Pages using Python for reliable regex
# ./images/file.jpg → /$REPO_NAME/images/file.jpg
# images/file.jpg → /$REPO_NAME/images/file.jpg
CONVERTED_CONTENT=$(echo "$NOTE_CONTENT" | python3 -c "
import sys, re

content = sys.stdin.read()
repo_name = '$REPO_NAME'

# Pattern 1: ./path/to/image.ext -> /repo/path/to/image.ext
content = re.sub(r'!\[([^\]]*)\]\(\./([^)]+\.(jpg|jpeg|png|gif|svg|webp))\)', rf'![\1](/{repo_name}/\2)', content, flags=re.IGNORECASE)

# Pattern 2: path/to/image.ext (no leading ./) -> /repo/path/to/image.ext
# But skip URLs (http:// or https://)
content = re.sub(r'!\[([^\]]*)\]\((?!https?://|/)([^)]+\.(jpg|jpeg|png|gif|svg|webp))\)', rf'![\1](/{repo_name}/\2)', content, flags=re.IGNORECASE)

print(content, end='')
")

echo "📝 Image path conversion complete"
echo ""

# Write converted content to sharehub
DEST_NOTE="$SHAREHUB_PATH/documents/$NOTE_FILE"
mkdir -p "$SHAREHUB_PATH/documents"
echo "$CONVERTED_CONTENT" > "$DEST_NOTE"

echo "✅ Copied note to: documents/$NOTE_FILE"
echo ""

# Git operations
cd "$SHAREHUB_PATH"

echo "📋 Git status:"
git status --short
echo ""

# Add all changes (document + images)
git add "documents/$NOTE_FILE"
git add images/ 2>/dev/null || true

# Get note title from frontmatter for commit message
NOTE_TITLE=$(grep -m1 '^title:' "documents/$NOTE_FILE" | sed 's/title: *["'"'"']*//;s/["'"'"']*$//' || echo "$NOTE_FILE")

# Commit
git commit -m "Publish: $NOTE_TITLE

- Published documents/$NOTE_FILE
- Copied associated images
- Converted image paths for GitHub Pages

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to GitHub
echo "🚀 Pushing to GitHub..."
git push origin main

echo ""
echo "✅ Published successfully!"
echo ""
echo "📄 Document: $SHAREHUB_URL/documents/${NOTE_FILE%.md}.html"
echo "⏱️  GitHub Pages will deploy in ~60 seconds"
echo ""

exit 0
