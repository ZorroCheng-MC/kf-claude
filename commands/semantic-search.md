---
description: Perform semantic search in Obsidian vault using Smart Connections via Local REST API
argument-hint: [search query] (e.g., "KnowledgeFactory migration")
allowed-tools:
  - Bash(*)
---

## Context

- **Search Query:** `$ARGUMENTS`
- **API Configuration:** Local REST API running on https://127.0.0.1:27124/
- **Smart Connections Endpoint:** `/search/smart`

## Task

Execute a semantic search in the Obsidian vault using the Smart Connections plugin.

## Implementation

### Step 1: Get API Key from Obsidian Plugin Config

```bash
# Read API key from Obsidian Local REST API plugin config
VAULT_PATH="${VAULT_PATH:-$(pwd)}"
API_CONFIG="$VAULT_PATH/.obsidian/plugins/obsidian-local-rest-api/data.json"

if [[ ! -f "$API_CONFIG" ]]; then
    echo "❌ Local REST API plugin not configured"
    echo "   Install and enable 'Local REST API' plugin in Obsidian"
    exit 1
fi

API_KEY=$(jq -r '.apiKey // empty' "$API_CONFIG")

if [[ -z "$API_KEY" ]]; then
    echo "❌ API key not found in plugin config"
    exit 1
fi
```

### Step 2: Execute Semantic Search

```bash
QUERY="$ARGUMENTS"

if [[ -z "$QUERY" ]]; then
    echo "❌ No search query provided"
    echo "   Usage: /kf-claude:semantic-search <query>"
    exit 1
fi

echo "🔍 Searching for: $QUERY"
echo ""

curl -k -s -X POST \
  https://127.0.0.1:27124/search/smart \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"$QUERY\", \"filter\": {\"limit\": 10}}" | jq -r '
    if type == "array" then
      .[] | "📄 \(.path)\n   Score: \(.score | tostring | .[0:5])\n"
    else
      "❌ Error: \(.message // "Unknown error")"
    end
  '
```

## Prerequisites

1. **Obsidian** must be running
2. **Local REST API** plugin installed and enabled
3. **Smart Connections** plugin installed with embeddings generated

## Example

```bash
/kf-claude:semantic-search KnowledgeFactory migration
```

Output:
```
🔍 Searching for: KnowledgeFactory migration

📄 KFE/KF-MIGRATION-CHECKLIST.md
   Score: 0.892

📄 KFE/KF-MASTER-PLAN.md
   Score: 0.856

📄 KFE/KF-GITHUB-STRUCTURE.md
   Score: 0.823
```

## Troubleshooting

- **"Connection refused"**: Obsidian is not running or plugin disabled
- **"Authorization required"**: API key mismatch (restart Obsidian)
- **Empty results**: Smart Connections embeddings not generated yet
