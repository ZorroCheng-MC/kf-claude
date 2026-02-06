---
description: Smart capture router - delegates to specialized handlers based on content type
argument-hint: [content to capture]
allowed-tools:
  - Bash(date)
  - SlashCommand(/kf-claude:youtube-note)
  - SlashCommand(/kf-claude:gitingest)
  - SlashCommand(/kf-claude:study-guide)
  - SlashCommand(/kf-claude:idea)
---

## Task

Route content to the appropriate capture handler based on content type.

**Input**: `$ARGUMENTS`

## Content Routing

Analyze the input and delegate to the appropriate command. **Check patterns in this exact order**:

| Priority | Content Type | Pattern | Delegate To |
|----------|--------------|---------|-------------|
| 1 | **YouTube** | Domain is `youtube.com` or `youtu.be` | `/kf-claude:youtube-note` |
| 2 | **GitHub** | Domain is `github.com` | `/kf-claude:gitingest` |
| 3 | **Web Article** | Other `http://` or `https://` URL | `/kf-claude:study-guide` |
| 4 | **Plain Text** | No URL pattern | `/kf-claude:idea` |

## Routing Logic

### 1. YouTube URLs
**Pattern**: URL contains `youtube.com` or `youtu.be`

```
SlashCommand("/kf-claude:youtube-note $ARGUMENTS")
```

### 2. GitHub URLs
**Pattern**: URL contains `github.com`

```
SlashCommand("/kf-claude:gitingest $ARGUMENTS")
```

### 3. Web Articles
**Pattern**: Starts with `http://` or `https://` (not YouTube or GitHub)

```
SlashCommand("/kf-claude:study-guide $ARGUMENTS")
```

### 4. Plain Text (Ideas)
**Pattern**: No URL detected

```
SlashCommand("/kf-claude:idea $ARGUMENTS")
```

## Examples

```
/kf-claude:capture https://youtube.com/watch?v=abc123
→ Delegates to: /kf-claude:youtube-note https://youtube.com/watch?v=abc123

/kf-claude:capture https://github.com/anthropics/claude-code
→ Delegates to: /kf-claude:gitingest https://github.com/anthropics/claude-code

/kf-claude:capture https://medium.com/article-about-ai
→ Delegates to: /kf-claude:study-guide https://medium.com/article-about-ai

/kf-claude:capture Build a browser extension for note capture
→ Delegates to: /kf-claude:idea Build a browser extension for note capture
```

## Important

- This command is a **router only** - it does NOT process content directly
- Each handler (`/kf-claude:youtube-note`, `/kf-claude:gitingest`, `/kf-claude:study-guide`, `/kf-claude:idea`) has its own template and logic
- After detecting content type, immediately delegate using `SlashCommand`
- Always use `/kf-claude:` prefixed commands to ensure plugin templates are used
