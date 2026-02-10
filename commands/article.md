---
description: Create comprehensive articles/blog posts with auto-generated hero images
argument-hint: [topic or content]
allowed-tools:
  - Bash(date)
  - WriteFile
  - ReadFile
  - SlashCommand(/generate-image)
  - sessions_spawn
---

## Task

Create a comprehensive article with auto-generated hero image.

**Input**: `$ARGUMENTS` (topic, outline, or existing content)

## Process

### 1. Generate Hero Image (MANDATORY)

**Always create hero image first:**

```bash
# Spawn sub-agent to generate hero image using nano-banana-pro
sessions_spawn(
    task="Generate an eye-catching hero image for an article titled: [TITLE]

Topic: [BRIEF TOPIC DESCRIPTION]

Create a visually compelling prompt that will attract readers. The image should:
- Be modern, professional, and polished
- Clearly relate to the article topic
- Use vibrant colors and engaging composition
- Avoid text/words in the image
- Be suitable for a blog/article header

Generate the image using nano-banana-pro and save it to:
~/Documents/Obsidian/Claudecode/images/{slug}-hero.jpg

Where {slug} is the kebab-case version of the title.

Use these nano-banana-pro settings:
- Size: 2048x2048 (we'll crop to 16:9 for hero)
- Aspect ratio: 16:9
- Style: Professional, modern, polished
- Quality: High

Return the saved image path.",
    cleanup="delete"
)
```

**Image prompt strategy:**
- Focus on visual metaphors and concepts
- Use descriptive, evocative language
- Specify professional/modern aesthetic
- Include relevant objects, scenes, or abstract concepts
- Example: "A futuristic drone with 360° camera hovering above a bustling city plaza at golden hour, cinematic lighting, professional photography"

**Wait for image generation to complete before proceeding.**

### 2. Structure Content

Analyze input and organize into natural sections:

**Common patterns (adapt as needed):**
- Introduction / Overview
- Core concepts / Main content
- Examples / Case studies
- Implementation / How-to (if applicable)
- Implications / Analysis
- Conclusion / Takeaways

**DO NOT force rigid structure** - let content dictate organization.

### 3. Apply Template

Use `article-template.md` with:
- `{{TITLE}}` - Article title
- `{{DATE}}` - Current date (YYYY-MM-DD format)
- `{{SLUG}}` - Kebab-case filename slug
- `{{HERO_PATH}}` - Path to generated hero image
- `{{CONTENT}}` - Flexible article body
- `{{TAGS}}` - Auto-generated tags based on content
- `{{SUMMARY}}` - 1-2 sentence summary

### 4. Save to Obsidian Vault

**Filename format:** `YYYY-MM-DD-{slug}.md`
**Location:** `~/Documents/Obsidian/Claudecode/`

## Output Format

Markdown article with:
- ✅ Hero image embedded at top
- ✅ Flexible content structure
- ✅ Proper metadata (frontmatter)
- ✅ Relevant tags
- ✅ Date-prefixed filename

## Examples

```bash
/kf-claude:article Building a scambaiting AI strategy
→ Generates hero: scambaiting-ai-strategy-hero.jpg
→ Creates: 2026-02-07-building-scambaiting-ai-strategy.md

/kf-claude:article How to use Developer Knowledge API
→ Generates hero: developer-knowledge-api-hero.jpg
→ Creates: 2026-02-07-how-to-use-developer-knowledge-api.md
```

## Important

- **Hero image is MANDATORY** - always generate before article
- **Flexible structure** - adapt to content, not forced sections
- **Auto-tag intelligently** - analyze content for relevant tags
- **Use sub-agent for image** - ensures proper isolation and tool access
