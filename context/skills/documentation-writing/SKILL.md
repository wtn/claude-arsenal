---
type: guidelines
enforcement: suggest
priority: medium
keywords: [documentation, README, markdown, docs, write guide, skill documentation]
intentPatterns:
  - "(write|create|update).*?(documentation|README|guide|docs)"
  - "(document|explain).*?(feature|skill|hook)"
  - "progressive disclosure"
pathPatterns:
  - "README.md"
  - "context/**/*.md"
  - ".claude/skills/**/SKILL.md"
  - ".claude/skills/**/resources/*.md"
  - "**/*.md"
contentPatterns:
  - "^# .*Skill$"
  - "## Purpose"
  - "## Core Principles"
  - "## Resources"
---

# Documentation Writing Guidelines

## Purpose

This skill provides guidelines for writing clear, maintainable documentation in Claude Arsenal, following the 500-line rule and progressive disclosure pattern.

## When to Use This Skill

Use this skill when:
- Writing or updating README files
- Creating skill documentation
- Documenting context files
- Writing dev docs (plan, context, tasks)
- Updating getting-started guides
- Creating resource files

## Core Principles

### 1. The 500-Line Rule

Keep main documentation files under 500 lines for optimal loading and maintainability.

**Why 500 lines?**
- Faster loading and processing by Claude
- Easier to scan and maintain
- Forces concise, focused writing
- Better fits in context windows

**Example:**
```markdown
# Good - Concise overview with links
## Core Concepts
Brief overview of key concepts.

See `resources/detailed-guide.md` for comprehensive examples.

# Bad - Everything in one file
## Core Concepts
[300 lines of detailed examples and edge cases...]
```

### 2. Progressive Disclosure

Start with overview, link to details:

```markdown
# Main Skill File (< 500 lines)

## Purpose
Quick introduction and when to use.

## Core Principles
3-5 key principles with brief examples.

## Resources
- `resources/advanced-patterns.md` - Detailed patterns
- `resources/examples.md` - Real-world examples
- `resources/troubleshooting.md` - Common issues
```

### 3. Show, Don't Just Tell

Always include concrete examples:

**Good:**
```markdown
## Error Handling

Use descriptive error messages:

```ruby
# Good
raise ArgumentError, "name cannot be empty"

# Bad
raise "error"
```
```

**Bad:**
```markdown
## Error Handling
Always use descriptive error messages.
```

### 4. Scannable Structure

Use clear headings, lists, and formatting:

```markdown
# Good - Easy to scan
## Feature Name

**When to use:** Brief description

**Key benefits:**
- Benefit 1
- Benefit 2
- Benefit 3

**Example:**
[Code example]

# Bad - Wall of text
## Feature Name
This feature is used when you need to do something and it provides
several benefits including benefit 1 and benefit 2 and also benefit 3.
Here's an example: [code]
```

## Patterns and Conventions

### Pattern 1: README Structure

**When to use:** Creating or updating README files

**Structure:**
```markdown
# Project Name

Brief one-line description.

## Features
- Key feature 1
- Key feature 2

## Quick Start
```bash
# Minimal getting started
```

## Documentation
- [Getting Started](context/getting-started.md)
- [Skills Guide](context/skills.md)

## License
```

**Key Points:**
- Keep README under 200 lines
- Link to detailed guides
- Include quick start code
- Show actual commands, not placeholders

### Pattern 2: Skill Documentation

**When to use:** Writing SKILL.md files

**Structure:**
```markdown
# Skill Name

## Purpose
One paragraph explaining what this skill covers.

## When to Use This Skill
Bulleted list of specific scenarios.

## Core Principles
### 1. Principle Name
Brief explanation with code example.

## Resources
Links to detailed resources.

## Checklist
Actionable items to verify.
```

**Key Points:**
- Stay under 500 lines
- Use real code examples
- Link to resources for details
- Include actionable checklist

**Resources:** See `resources/skill-template.md`

### Pattern 3: Code Examples

**When to use:** Demonstrating patterns

**Format:**
```markdown
## Pattern Name

**Good example:**
```ruby
# Clear, working code
def process(data)
  validate!(data)
  transform(data)
end
```

**Bad example:**
```ruby
# What not to do
def process(d)
  d.map(&:x)
end
```

**Why:** Clear variable names and explicit steps improve readability.
```

**Key Points:**
- Show both good and bad examples
- Use real, working code (not pseudocode)
- Explain why, not just what
- Keep examples focused (< 10 lines)

### Pattern 4: Progressive Disclosure Layout

**When to use:** Organizing documentation that exceeds 500 lines

**Structure:**
```
skill-name/
 SKILL.md                    # < 500 lines: overview and core concepts
 resources/
     advanced-patterns.md    # Detailed implementation
     examples.md             # Real-world examples
     troubleshooting.md      # Common issues
     migration-guide.md      # Upgrade paths
```

**Main file contains:**
- Purpose and when to use
- 3-5 core principles with brief examples
- Quick reference patterns
- Links to resources
- Checklist

**Resource files contain:**
- Detailed implementation examples
- Edge cases and gotchas
- Performance considerations
- Comprehensive troubleshooting

## Writing Style Guidelines

### Clarity
- Use active voice: "Use this pattern" not "This pattern should be used"
- Be specific: "Keep files under 500 lines" not "Keep files short"
- Avoid jargon unless necessary

### Consistency
- Use consistent terminology throughout
- Follow existing formatting patterns
- Maintain uniform heading hierarchy
- Use kebab-case for file names

### Brevity
- One concept per section
- Remove redundant words
- Link instead of duplicating content
- Use bullet points for scanability

### Examples
- Real code, not pseudocode
- Working examples that can be copy-pasted
- Show both good and bad patterns
- Explain the "why" behind each pattern

## Common Pitfalls

1. **Walls of Text**
   - Problem: Dense paragraphs are hard to scan
   - Solution: Use bullet points, headings, and whitespace
   ```markdown
   # Good
   ## Key Points
   - Point 1
   - Point 2

   # Bad
   ## Key Points
   This section covers point 1 which is about X and also point 2 about Y...
   ```

2. **Missing Examples**
   - Problem: Concepts described without demonstration
   - Solution: Always include code examples
   ```markdown
   # Good
   Use descriptive names:
   ```ruby
   user_count = users.size
   ```

   # Bad
   Use descriptive variable names.
   ```

3. **Outdated Information**
   - Problem: Documentation doesn't match current code
   - Solution: Update docs when code changes, add timestamps
   ```markdown
   # Good
   *Last updated: 2025-10-30*

   # Review quarterly
   ```

4. **Over-Explaining**
   - Problem: Explaining obvious things in detail
   - Solution: Trust the reader, focus on non-obvious aspects
   ```markdown
   # Good
   ```ruby
   # Memoize expensive calculation
   @result ||= calculate_complex_value
   ```

   # Bad
   This code uses the ||= operator which checks if @result is nil
   and if it is nil it will call the calculate_complex_value method...
   ```

5. **Broken Links**
   - Problem: References to non-existent files
   - Solution: Verify links exist before committing
   ```markdown
   # Good - Verify file exists
   See `resources/patterns.md`

   # Bad - Dead link
   See `resources/old-guide.md`
   ```

## Markdown Formatting

### Headings
```markdown
# H1 - Document title only
## H2 - Major sections
### H3 - Subsections
```

### Code Blocks
````markdown
```ruby
# Specify language for syntax highlighting
def example
  "code here"
end
```
````

### Lists
```markdown
# Unordered
- Item 1
- Item 2
  - Nested item

# Ordered
1. First step
2. Second step
3. Third step

# Checklists
- [ ] Incomplete task
- [x] Complete task
```

### Emphasis
```markdown
**Bold** for emphasis
`code` for inline code
> Blockquotes for important notes
```

### Links
```markdown
[Relative link](./context/guide.md)
[Absolute link](/path/to/file.md)
```

## Documentation Checklist

Before finalizing documentation:

- [ ] Main file is under 500 lines (or 200 for READMEs)
- [ ] All code examples are tested and working
- [ ] Headings follow consistent hierarchy
- [ ] Progressive disclosure structure is used appropriately
- [ ] Both good and bad examples are shown
- [ ] "Why" is explained, not just "what"
- [ ] All links are verified and working
- [ ] Formatting is consistent with project standards
- [ ] Timestamp/last-updated date is included
- [ ] File uses clear, scannable structure
- [ ] No walls of text (use bullets/lists)
- [ ] Jargon is explained or avoided

## Progressive Disclosure

For detailed information on specific topics:

- `resources/markdown-reference.md` - Complete markdown syntax guide
- `resources/skill-writing.md` - Deep dive on writing skills
- `resources/context-files.md` - Context documentation patterns
- `resources/dev-docs.md` - Development documentation workflow

## Related Skills

- `ruby-gem-development` - For code documentation
- `generator-patterns` - For template documentation

## Quick Reference

### File Size Targets
- README: < 200 lines
- SKILL.md: < 500 lines
- Resource files: < 800 lines each
- Context guides: < 600 lines

### Documentation Hierarchy
```
1. README (overview + links)
2. Getting Started (setup + first steps)
3. Main Guide (concepts + patterns)
4. Resources (deep dives)
```

### Example Structure Template
```markdown
## Pattern Name

**When to use:** [Brief description]

**Example:**
```code
[Working example]
```

**Key points:**
- Point 1
- Point 2

**Resources:** See `resources/details.md`
```

## Resources

For detailed examples and patterns:
- `resources/skill-examples.md` - Complete skill file examples (domain, guidelines, guardrail)
- `resources/markdown-best-practices.md` - Advanced markdown formatting and structure

---

*This skill is part of Claude Arsenal. Keep under 500 lines for optimal loading.*
*Last updated: 2025-11-01*
