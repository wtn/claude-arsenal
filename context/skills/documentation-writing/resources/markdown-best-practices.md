# Markdown Formatting Best Practices

Advanced markdown patterns for clear, maintainable documentation.

## Document Structure

### Hierarchy

```markdown
# Document Title (H1 - only one per file)

## Major Section (H2)

### Subsection (H3)

#### Detail Level (H4)
```

**Rule:** Never skip heading levels (don't jump from H2 to H4)

### Table of Contents

For long documents (>300 lines):

```markdown
# Complete Guide

## Table of Contents

- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)

## Quick Start

...
```

## Code Blocks

### Language Specification

Always specify language for syntax highlighting:

```markdown
```ruby
def hello
  puts "Hello"
end
```\`

```bash
npm install
```\`

```typescript
interface User {
  name: string;
}
```\`
```

### Inline Code

Use backticks for:
- Commands: \`gem install my-gem\`
- File paths: \`.claude/skills/SKILL.md\`
- Variable names: \`@name\` parameter
- Function names: \`initialize()\` method

## Lists

### Unordered Lists

```markdown
- First item
- Second item
  - Nested item
  - Another nested item
- Third item
```

### Ordered Lists

```markdown
1. First step
2. Second step
   - Sub-point
   - Another sub-point
3. Third step
```

### Task Lists

```markdown
- [ ] Incomplete task
- [x] Completed task
- [ ] Another pending task
```

## Emphasis

### Basic Emphasis

```markdown
*Italic text* or _italic text_

**Bold text** or __bold text__

***Bold and italic***

`Code text`
```

### Semantic Emphasis

```markdown
**Important:** This is critical information

**Example:**
```

**Note:** Additional context

**Warning:** Potential issue ahead
```

## Links

### Internal Links

```markdown
See [Configuration Guide](docs/configuration.md) for details.

Jump to [Advanced Patterns](#advanced-patterns) section below.
```

### External Links

```markdown
See the [official documentation](https://example.com/docs) for more info.

Read more at: https://example.com
```

### Reference-Style Links

```markdown
This is explained in the [Ruby guide][ruby-docs] and [Rails guide][rails-docs].

[ruby-docs]: https://ruby-doc.org
[rails-docs]: https://guides.rubyonrails.org
```

## Tables

### Basic Table

```markdown
| Feature | Status | Priority |
|---------|--------|----------|
| Auth    | Done   | High     |
| API     | WIP    | Medium   |
| Tests   | Todo   | Low      |
```

### Alignment

```markdown
| Left aligned | Center aligned | Right aligned |
|:-------------|:--------------:|--------------:|
| Text         | Text           | Text          |
```

## Blockquotes

```markdown
> Important note: This is a blockquote

> Multi-line blockquote
> continues here
> and here
```

## Horizontal Rules

Use for major section breaks:

```markdown
---

Or:

***

Or:

___
```

## Callouts

### Using Blockquotes

```markdown
> **Tip:** Use progressive disclosure for large skills

> **Warning:** This operation cannot be undone

> **Best Practice:** Keep main SKILL.md under 500 lines
```

### Using Headers

```markdown
## Important Security Note

Never commit secrets to git...

## Pro Tip

You can use...
```

## Progressive Disclosure Patterns

### Pattern 1: Overview + Details Link

```markdown
## Error Handling

All services must handle errors properly. Use try-catch blocks with proper logging.

**Quick Example:**
```ruby
def process
  result
rescue => error
  log_error(error)
  raise
end
```\`

For complete patterns, see `resources/error-handling.md`
```

### Pattern 2: Expandable Sections

```markdown
<details>
<summary>Click to see advanced configuration options</summary>

## Advanced Options

- `option1` - Description
- `option2` - Description

```ruby
config.option1 = value
```\`

</details>
```

### Pattern 3: Tiered Information

```markdown
# Main Concept

## Quick Start (Essential)
[3-5 lines]

## Common Use Cases (Helpful)
[10-15 lines]

## Advanced Patterns (Optional)
For advanced usage, see `resources/advanced.md`
```

## File Naming

### Documentation Files

```
docs/
  getting-started.md      # Use kebab-case
  api-reference.md        # Not API_REFERENCE.md
  troubleshooting.md      # Not TROUBLESHOOTING.md
```

### Skill Files

```
.claude/skills/
  backend-api/
    SKILL.md              # All caps for main skill
    resources/
      controller-patterns.md  # kebab-case for resources
      service-layer.md
```

## YAML Frontmatter

```markdown
---
title: Getting Started
description: Quick start guide for installation and basic usage
author: Your Name
date: 2025-11-01
tags: [installation, setup, quickstart]
---

# Getting Started

[Content begins after frontmatter]
```

## Common Mistakes

### No Language in Code Blocks

```markdown
Bad:
```
gem install my-gem
```\`

Good:
```bash
gem install my-gem
```\`
```

### Broken Relative Links

```markdown
Bad:
See [guide](guide.md) # Relative to current file location

Good:
See [guide](docs/guide.md) # Relative to repo root
```

### Inconsistent List Formatting

```markdown
Bad:
- Item one
* Item two
- Item three

Good:
- Item one
- Item two
- Item three
```

### Missing Blank Lines

```markdown
Bad:
## Section
Content starts immediately

Good:
## Section

Content with proper spacing
```

## Best Practices Checklist

- [ ] One H1 heading per file
- [ ] Language specified for all code blocks
- [ ] Links verified to work
- [ ] Consistent list formatting
- [ ] Proper blank line spacing
- [ ] Progressive disclosure for long content
- [ ] Main file under 500 lines (for skills)
- [ ] Resources directory for detailed content
- [ ] Code examples are working/tested
- [ ] No broken links to non-existent files
