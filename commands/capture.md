---
description: Smart capture router - spawns background agents for parallel processing
argument-hint: [content to capture]
allowed-tools:
  - Task(*)
---

## Task

Route content to the appropriate capture handler by spawning a **background agent**.

**Input**: `$ARGUMENTS`

## Implementation

**CRITICAL: Always spawn a BACKGROUND agent for parallel execution.**

Analyze the input and spawn a background agent based on content type:

| Priority | Content Type | Pattern | Agent Task |
|----------|--------------|---------|------------|
| 1 | **YouTube** | Domain is `youtube.com` or `youtu.be` | YouTube note capture |
| 2 | **GitHub** | Domain is `github.com` | Repository analysis |
| 3 | **Web Article** | Other `http://` or `https://` URL | Study guide generation |
| 4 | **Plain Text** | No URL pattern | Idea capture |

## Routing Logic

### 1. YouTube URLs
**Pattern**: URL contains `youtube.com` or `youtu.be`

```
Task tool call:
  subagent_type: "general-purpose"
  description: "Capture YouTube video"
  run_in_background: true
  prompt: |
    Capture YouTube video note for: $ARGUMENTS

    Use the MCP Docker tools to:
    1. Get video info with mcp__MCP_DOCKER__get_video_info
    2. Get transcript with mcp__MCP_DOCKER__get_transcript
    3. Create a comprehensive note in the vault at /Users/zorro/Documents/Obsidian/Claudecode/

    Filename format: YYYY-MM-DD-creator-name-video-title.md

    Include: title, channel, URL, key timestamps, curriculum, transcript summary.
    Use smart AI tagging from taxonomy: AI, Claude, Gemini, product, marketing, etc.
```

### 2. GitHub URLs
**Pattern**: URL contains `github.com`

```
Task tool call:
  subagent_type: "general-purpose"
  description: "Analyze GitHub repo"
  run_in_background: true
  prompt: |
    Analyze GitHub repository: $ARGUMENTS

    Use MCP Docker tools to:
    1. Get repository structure with mcp__MCP_DOCKER__get_file_contents
    2. Get recent commits with mcp__MCP_DOCKER__list_commits
    3. Create analysis note in /Users/zorro/Documents/Obsidian/Claudecode/

    Filename format: YYYY-MM-DD-repo-name-repository-analysis.md

    Include: overview, tech stack, key files, architecture insights.
```

### 3. Web Articles
**Pattern**: Starts with `http://` or `https://` (not YouTube or GitHub)

```
Task tool call:
  subagent_type: "general-purpose"
  description: "Create study guide"
  run_in_background: true
  prompt: |
    Create study guide from URL: $ARGUMENTS

    1. Fetch content using WebFetch
    2. Generate comprehensive study guide
    3. Write to /Users/zorro/Documents/Obsidian/Claudecode/

    Filename format: YYYY-MM-DD-source-topic-study-guide.md

    Include: summary, key concepts, actionable insights, questions.
```

### 4. Plain Text (Ideas)
**Pattern**: No URL detected

```
Task tool call:
  subagent_type: "general-purpose"
  description: "Capture idea"
  run_in_background: true
  prompt: |
    Capture idea: $ARGUMENTS

    Create idea note in /Users/zorro/Documents/Obsidian/Claudecode/

    Filename format: YYYY-MM-DD-brief-descriptive-title.md

    Include: the idea expanded, potential applications, next steps.
    Use smart AI tagging.
```

## Response Format

After spawning the background agent, immediately respond:

```
📥 **Capture started in background**

Content: [brief description]
Type: [YouTube/GitHub/Article/Idea]
Agent ID: [task_id]

You can continue working. Check `/tasks` for status.
```

## Examples

```
/kf-claude:capture https://youtube.com/watch?v=abc123
→ Spawns background agent for YouTube capture
→ Returns immediately, user can run another /capture

/kf-claude:capture https://github.com/anthropics/claude-code
→ Spawns background agent for repo analysis
→ Returns immediately

/kf-claude:capture Build a browser extension
→ Spawns background agent for idea capture
→ Returns immediately
```

## Key Benefits

- **Parallel execution**: Multiple captures run simultaneously
- **Non-blocking**: CLI returns immediately after spawning
- **Trackable**: Use `/tasks` to monitor all running captures
- **Independent**: Each capture agent has its own context
