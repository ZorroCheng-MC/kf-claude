---
description: Search Obsidian vault using Local REST API
argument-hint: [search query] (e.g., "KnowledgeFactory migration")
allowed-tools:
  - Bash(*)
---

## Context

- **Search Query:** `$ARGUMENTS`
- **API:** Obsidian Local REST API on https://127.0.0.1:27124/

## Task

Search the Obsidian vault for notes matching the query.

## Implementation

```bash
VAULT_PATH="${VAULT_PATH:-$(pwd)}"
QUERY="$ARGUMENTS"

if [[ -z "$QUERY" ]]; then
    echo "❌ No search query provided"
    echo "   Usage: /kf-claude:semantic-search <query>"
    exit 1
fi

# Read API key from Obsidian plugin config
API_CONFIG="$VAULT_PATH/.obsidian/plugins/obsidian-local-rest-api/data.json"

if [[ ! -f "$API_CONFIG" ]]; then
    echo "❌ Local REST API plugin not configured"
    echo "   Install 'Local REST API' plugin in Obsidian"
    exit 1
fi

API_KEY=$(jq -r '.apiKey // empty' "$API_CONFIG")

if [[ -z "$API_KEY" ]]; then
    echo "❌ API key not found in plugin config"
    exit 1
fi

echo "🔍 Searching for: $QUERY"
echo ""

# URL encode the query
ENCODED_QUERY=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$QUERY'))")

# Simple text search
RESULT=$(curl -k -s -X POST \
  "https://127.0.0.1:27124/search/simple/?query=$ENCODED_QUERY&contextLength=100" \
  -H "Authorization: Bearer $API_KEY" 2>/dev/null)

# Check for errors
if echo "$RESULT" | jq -e '.error or .message' >/dev/null 2>&1; then
    ERROR=$(echo "$RESULT" | jq -r '.error // .message')
    echo "❌ Error: $ERROR"
    exit 1
fi

# Format and display results
echo "$RESULT" | jq -r '
  if length == 0 then
    "No results found."
  else
    .[:10] | to_entries | .[] |
    "📄 \(.value.filename)\n   Matches: \(.value.matches | length)\n"
  end
'
```

## Prerequisites

1. **Obsidian** must be running
2. **Local REST API** plugin installed and enabled

## Example

```bash
/kf-claude:semantic-search KnowledgeFactory
```

Output:
```
🔍 Searching for: KnowledgeFactory

📄 KFE/KF-MIGRATION-CHECKLIST.md
   Matches: 15

📄 KFE/KF-MASTER-PLAN.md
   Matches: 12

📄 KnowledgeFactory/README.md
   Matches: 8
```

## Search Types

| Type | Endpoint | Description |
|------|----------|-------------|
| Simple | `/search/simple/` | Text search across vault |
| Advanced | `/search/` | Dataview DQL or JsonLogic |

## Troubleshooting

- **"Connection refused"**: Obsidian is not running
- **"Authorization required"**: Check API key in plugin settings
- **"No results"**: Try different keywords
