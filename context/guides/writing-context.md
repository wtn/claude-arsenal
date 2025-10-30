# Guide: Building a Reliable Claude Code System

This guide explains how to set up a Claude Code system that **actually works at scale** - where skills auto-activate, patterns stay consistent, and Claude doesn't lose the plot. Based on battle-tested patterns from teams running 300k+ LOC projects.

## The Core Problem

Claude Code has a fundamental issue: **Skills sit unused unless you make them activate.**

You can write perfect skills following all best practices, use exact keywords, work on relevant files, and Claude will still ignore them. This isn't your fault - it's how the system works. Skills are "LLM-instigated" features, and LLMs don't reliably make the right call on when to use them.

## The Solution: The Three-System Architecture

### System 1: Skills + Hooks (Auto-Activation)

**Skills** (`.claude/skills/`) = HOW to write code following patterns
**Hooks** (`.claude/hooks/`) = FORCE Claude to check relevant skills

**The pattern:**
1. Create `skill-rules.json` defining when each skill should activate (keywords, file patterns, intent patterns)
2. Create `UserPromptSubmit` hook that reads your prompt + context and injects skill reminders BEFORE Claude sees your message
3. Create `Stop` hook that provides gentle self-check reminders AFTER Claude finishes

**Result:** Skills that actually get used consistently, not just sit there.

**Example:** When you ask "how does auth work?" the hook injects "🎯 SKILL ACTIVATION CHECK - Use backend-authentication skill" before Claude even sees your question.

### System 2: Dev Docs Workflow (Prevent Context Loss)

**Problem:** Claude loses track of what it's doing, especially after auto-compaction.

**Solution:** Three-file system for every large task:

```
dev/active/[task-name]/
├── plan.md       - The accepted plan
├── context.md    - Key files, decisions made
└── tasks.md      - Checklist of work
```

**Workflow:**
1. Plan in planning mode with strategic-plan-architect agent
2. Create dev docs with `/create-dev-docs` command
3. Update context.md and tasks.md as you work
4. Before compaction, run `/update-dev-docs` to capture state
5. New session: read all three files, say "continue"

**Result:** Claude never loses the plot, even through multiple compactions.

### System 3: Context Files (Why Decisions Were Made)

**Context** (`context/`) = WHY architectural decisions, project-specific gotchas

This is the traditional documentation layer. But it works WITH skills, not instead of them:

- **Skills contain:** "Here's how to create a controller (code template + guidelines)"
- **Context contains:** "We use Repository pattern because we had data consistency issues with direct Prisma queries"

**The separation:** Skills = HOW (reusable patterns), Context = WHY (project-specific rationale)

## Key Principles for Scale

### The 500-Line Rule (Token Efficiency)

From Anthropic's best practices: **Keep main SKILL.md files under 500 lines.**

Why? "The context window is a public good." Every token Claude loads is a token it can't use for your actual code. Bloated documentation decreases answer quality.

**Pattern:**
- Main file: Under 500 lines with core concepts
- Resources: Detailed examples in `resources/*.md`
- Reference from main: "See `resources/api-patterns.md` for detailed examples"

**Real example:** A 1,500-line skill restructured to 398-line main + 10 resource files improved token efficiency 40-60%.

### Don't Document Too Early

**Early development:** Leave templates empty. Patterns haven't stabilized. You don't know the gotchas yet.

**When to fill in:**
- You've explained the same thing 3+ times
- Non-obvious gotchas are wasting time
- Design decisions have solidified
- Integration quirks keep biting you

**What to skip:** Standard practices Claude already knows (how to run tests, use git, install dependencies).

### Focus on Non-Obvious Information

**Document:**
- Project-specific gotchas that surprised you
- WHY you chose this approach over alternatives
- Trade-offs you considered
- Domain terminology specific to YOUR project
- Integration quirks with external systems

**Example:** "CUSIPs exclude letters 'I' and 'O' to avoid confusion with digits 1 and 0" - This is non-obvious and project-specific.

**Don't document:** "Run tests with `bundle exec rake test`" - Claude already knows this.

## The Desired Outcomes

After setting up this system, you should achieve:

1. **Skills that actually auto-activate** - No more "Claude ignored my guidelines again"
2. **Consistent patterns enforced** - Way less time fixing inconsistent code
3. **Claude never loses the plot** - Dev docs workflow prevents amnesia
4. **Zero errors left behind** - Build checker hooks catch TypeScript errors immediately
5. **Trustworthy execution** - Can focus on architecture instead of constant review/fix cycles

**Before this system:**
- Claude uses old patterns even though new ones are documented
- Have to manually tell Claude to check docs every time
- Spend too much time fixing "creative interpretations"
- Claude gets lost halfway through features

**After this system:**
- Consistent patterns automatically
- Claude self-corrects before you see code
- Can trust guidelines are followed
- Smooth execution through multi-session features

## Quick Reference: Context File Purposes

### getting-started.md
- **What:** Project overview, setup gotchas, key concepts
- **Focus on:** Non-obvious setup requirements, integration points, domain terminology
- **Skip:** Standard commands Claude already knows

### architecture.md
- **What:** WHY your system is designed this way
- **Focus on:** Design decisions with context/rationale/trade-offs, non-obvious gotchas
- **Skip:** WHAT the code does (Claude can read it)

### conventions.md
- **What:** Things that DIFFER from standards
- **Focus on:** Project-specific naming, restrictions, domain terminology mappings
- **Skip:** Standard conventions (this file should be mostly empty!)

## Implementation Steps

### 1. Start with Skills + Hooks

**Priority: HIGH** - This is where the biggest gains come from.

1. Create domain-specific skills in `.claude/skills/local/` (backend-dev, frontend-dev, etc.)
2. Keep each skill under 500 lines
3. Create `.claude/config/skill-rules.json` with keywords, file patterns, intent patterns
4. Copy skill-activator hook from `.context/claude-arsenal/hooks/`
5. Test that skills actually activate when working on relevant code

### 2. Add Dev Docs Workflow

**Priority: MEDIUM** - Essential for large features.

1. Copy `/dev-docs` and `/create-dev-docs` commands
2. Create `dev/active/` and `dev/completed/` directories
3. When starting large tasks: plan → create dev docs → implement → update before compaction
4. Get in habit of reading dev docs at start of each session

### 3. Fill In Context Files

**Priority: LOW** - Only after patterns stabilize.

1. Leave templates mostly empty in early development
2. Fill in as gotchas emerge and decisions solidify
3. Focus on non-obvious, project-specific information
4. Keep under 500 lines, split to resources/ if needed

### 4. Add Quality Hooks (Optional)

Build checker, error handling reminder, etc. See `.context/claude-arsenal/hooks/` for examples.

## Common Pitfalls

1. **Writing skills without hooks** - Skills will sit unused
2. **Premature documentation** - Patterns haven't stabilized yet
3. **Bloated files** - Keep under 500 lines for token efficiency
4. **Documenting standard practices** - Claude already knows how to run tests
5. **Not using dev docs** - Claude will lose the plot on large features

## For Claude Code: Using This Guide

When helping users set up their system:

1. **Prioritize skills + hooks** - This is where the wins come from
2. **Encourage dev docs workflow** - Prevents context loss
3. **Discourage premature documentation** - Wait for patterns to stabilize
4. **Check file sizes** - Suggest progressive disclosure if over 500 lines
5. **Reference specific sections** - Don't quote this entire guide
