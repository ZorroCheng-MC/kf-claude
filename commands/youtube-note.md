---
description: Fetch YouTube video transcript and create comprehensive material entry with AI-powered smart tagging
argument-hint: [youtube-url-or-video-id] (YouTube URL or video ID to process)
allowed-tools:
  - Bash(*)
  - mcp__fetch__fetch
  - mcp__MCP_DOCKER__get_video_info
  - mcp__MCP_DOCKER__get_transcript
  - mcp__MCP_DOCKER__obsidian_*
---

## Task

Create a YouTube video note directly using MCP tools.

**⚠️ You MUST call `mcp__MCP_DOCKER__obsidian_create_vault_file` to save the file!**

**Input**: `$ARGUMENTS` (YouTube URL or video ID)
**Operation**: YouTube video note creation
**Today's Date**: Run `date "+%Y-%m-%d"` to get current date

## Process

The skill will:
1. Extract video ID from URL/argument
2. Use bundled script: `scripts/core/fetch-youtube-transcript.sh` to fetch transcript
3. Fetch video metadata from YouTube page
4. **Read and substitute template** (see CRITICAL section below)
5. Analyze content and apply AI-powered smart tagging (using tag taxonomy)
6. Create note in vault using MCP Obsidian tools

## ⚠️ CRITICAL: Template Compliance

**You MUST follow this exact workflow - DO NOT skip any steps:**

### Step 1: Read the Template File FIRST

Before generating ANY content, execute this command:
```bash
cat ~/.claude/plugins/marketplaces/kf-claude/kf-claude/templates/youtube-note-template.md
```

### Step 2: Use EXACT Field Names from Template

| ✅ CORRECT | ❌ WRONG |
|-----------|----------|
| `url:` | `source:` |
| `channel:` | `creator:` |
| `cover:` | (missing) |
| `video_date:` | `published:` |
| `priority:` | (missing) |

### Step 3: Include ALL Required Elements

**Frontmatter MUST include:**
- [ ] `type: video`
- [ ] `status: inbox`
- [ ] `read: false` ← **REQUIRED for tracking read status**
- [ ] `cover:` with `https://i.ytimg.com/vi/{VIDEO_ID}/maxresdefault.jpg`
- [ ] `url:` with full YouTube URL
- [ ] `channel:` with channel name
- [ ] `video_date:` with video publication date
- [ ] `duration:` with video length
- [ ] `priority:` (low/medium/high)
- [ ] `tags:` array with proper taxonomy

**Content MUST include:**
- [ ] Clickable thumbnail: `[![Watch on YouTube](thumbnail_url)](video_url)` after H1 title
- [ ] Emoji section headers: 📖 🎯 📋 📝 ⭐ 🏷️ 🔗
- [ ] Rating section with Quality/Relevance/Recommend fields
- [ ] Footer with "Captured:", "Source:", "Channel:"

### Step 4: Literal Substitution

**DO NOT:**
- ❌ Generate your own structure
- ❌ Reorganize or reorder sections
- ❌ Omit any fields or sections
- ❌ Change field names
- ❌ Remove emojis from headers

**DO:**
- ✅ Read the raw template content
- ✅ Replace `{{PLACEHOLDER}}` with actual values
- ✅ Keep ALL sections, even if some data is unavailable (mark as "N/A")

## Tag Taxonomy Reference

**Topics:** AI, productivity, knowledge-management, development, learning, research, writing, tools, business, design, automation, data-science, web-development, personal-growth, finance
**Status:** inbox (default for new videos)
**Metadata:** tutorial, deep-dive, quick-read, technical, conceptual, actionable, inspiration

## Expected Output

A comprehensive video note with:
- Proper frontmatter (title, tags, url, cover, date, type, status, priority, duration, channel)
- Clickable YouTube thumbnail
- Description and learning objectives
- Structured curriculum with timestamps
- Key takeaways and insights
- Rating section
- Tags analysis and filtering suggestions
- Related topics

**File naming format**: `[date]-[creator-name]-[descriptive-title].md`
**Tag count**: 6-8 tags total
