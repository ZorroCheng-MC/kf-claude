---
description: Smart capture router - delegates to specialized handlers based on content type
argument-hint: [content to capture]
allowed-tools:
  - Bash(date)
  - SlashCommand(/youtube-note)
  - SlashCommand(/gitingest)
  - SlashCommand(/study-guide)
  - SlashCommand(/idea)
---

## Task

Route content to the appropriate capture handler based on content type.

**Input**: `$ARGUMENTS`

## Content Routing

Analyze the input and delegate to the appropriate command. **Check patterns in this exact order**:

| Priority | Content Type | Pattern | Delegate To |
|----------|--------------|---------|-------------|
| 1 | **YouTube** | Domain is `youtube.com` or `youtu.be` | `/youtube-note` |
| 2 | **GitHub** | Domain is `github.com` | `/gitingest` |
| 3 | **Web Article** | Other `http://` or `https://` URL | `/study-guide` |
| 4 | **Plain Text** | No URL pattern | `/idea` |

## Routing Logic

### 1. YouTube URLs
**Pattern**: URL contains `youtube.com` or `youtu.be`

```
SlashCommand("/youtube-note $ARGUMENTS")
```

### 2. GitHub URLs
**Pattern**: URL contains `github.com`

```
SlashCommand("/gitingest $ARGUMENTS")
```

### 3. Web Articles
**Pattern**: Starts with `http://` or `https://` (not YouTube or GitHub)

```
SlashCommand("/study-guide $ARGUMENTS")
```

### 4. Plain Text (Ideas)
**Pattern**: No URL detected

```
SlashCommand("/idea $ARGUMENTS")
```

## Examples

```
/kf-claude:capture https://youtube.com/watch?v=abc123
→ Delegates to: /youtube-note https://youtube.com/watch?v=abc123

/kf-claude:capture https://github.com/anthropics/claude-code
→ Delegates to: /gitingest https://github.com/anthropics/claude-code

/kf-claude:capture https://medium.com/article-about-ai
→ Delegates to: /study-guide https://medium.com/article-about-ai

/kf-claude:capture Build a browser extension for note capture
→ Delegates to: /idea Build a browser extension for note capture
```

## Important

- This command is a **router only** - it does NOT process content directly
- Each handler (`/youtube-note`, `/gitingest`, `/study-guide`, `/idea`) has its own template and logic
- After detecting content type, immediately delegate using `SlashCommand`
