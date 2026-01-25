---
description: Generate comprehensive study guide with AI-powered smart tagging from any content source
argument-hint: [content-source] (file path, URL, or direct text to create study guide from)
allowed-tools:
  - Bash(*)
  - Read(*)
  - mcp__fetch__fetch
  - mcp__MCP_DOCKER__obsidian_*
---

## Task

Create a study guide note directly using MCP tools.

**⚠️ You MUST call `mcp__MCP_DOCKER__obsidian_create_vault_file` to save the file!**

**Input**: `$ARGUMENTS` (file path, URL, or direct text)
**Operation**: Study guide creation
**Today's Date**: Run `date "+%Y-%m-%d"` to get current date

## Process

The skill will:
1. Fetch content from URL, file, or direct text
2. Apply bundled template: `templates/study-guide-template.md`
3. Analyze content complexity, topics, and learning requirements
4. Apply AI-powered smart tagging (using tag taxonomy)
5. Generate structured learning plan with objectives and assessments
6. Substitute all template variables with analyzed data
7. Create note in vault using MCP Obsidian tools

## Tag Taxonomy Reference

**Topics:** AI, productivity, knowledge-management, development, learning, research, writing, tools, business, design, automation, data-science, web-development, personal-growth, finance
**Status:** processing (default for study guides - active learning)
**Metadata:** deep-dive, technical, conceptual, actionable, tutorial

## Expected Output

A comprehensive study guide with:
- Proper frontmatter (title, tags, source, date, type, status, difficulty, estimated-time, priority)
- Overview with subject and generated date
- Learning objectives (specific, measurable, checkboxed)
- Study plan with time estimates and difficulty level
- Structured content breakdown (weekly/modular)
- Study strategies (material-specific and active learning techniques)
- Self-assessment questions (intermediate and final)
- Progress tracking section
- Related notes and connections
- Tags analysis with filtering suggestions
- Semantic search suggestions

**File naming format**: `[date]-[topic-name]-study-guide.md`
**Tag count**: 6-8 tags total
**Status**: Always `processing` (active study material)

## Examples

**Input (URL)**: "https://example.com/machine-learning-course"
→ `2025-10-28-machine-learning-study-guide.md`

**Input (File)**: "react-advanced-patterns.md"
→ `2025-10-28-react-advanced-study-guide.md`

**Input (Text)**: "Deep dive into distributed systems architecture"
→ `2025-10-28-distributed-systems-study-guide.md`
