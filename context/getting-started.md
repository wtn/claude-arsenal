# Getting Started with Claude Arsenal

Claude Arsenal is a Ruby gem that provides reusable skills for Claude Code. Distribute via gems using agent-context.

Provides 4 skills via agent-context (`.context/`), symlinks them to `.claude/skills/gems/` for Claude Code discovery.

## The Architecture

**Distribution Strategy:**

**Skills** (passive documentation):
- Shipped in `context/skills/`
- Installed to `.context/claude-arsenal/skills/`
- Symlinked to `.claude/skills/gems/` (gitignored)
- Updated via `bundle update`

**Hooks/Agents/Commands** (executable or customizable):
- Shipped as reference implementations in `context/`
- Installed to `.context/claude-arsenal/`
- Copied to `.claude/` when needed
- You own and customize the copied version

**Why the distinction:**
- Skills = passive docs (symlink perfect, no customization needed)
- Hooks = code that executes (you need to own and customize)
- Agents/Commands = configs that vary by project

**Alignment with ecosystems:**
- `.context/` = agent-context standard (reference documentation)
- `.claude/` = Claude Code standard (runtime discovery)
- Symlinks for skills = bridge between passive and active
- Copy for hooks/agents = explicit ownership of executable code

## Quick Reference

### For First Time Setup
```bash
gem 'claude-arsenal'            # Add to Gemfile
bundle install                   # Installs gem
bake claude:arsenal:install     # Symlinks 4 skills, configures gitignore
```

**Result:** 4 ready-to-use skills (ruby-gem-development, generator-patterns, documentation-writing, test-coverage)

### After Pulling Changes
```bash
git pull
bundle install                   # Installs gem + context
bake claude:arsenal:link_skills  # Recreates gitignored symlinks
```

### Creating Project-Specific Skills
```bash
bake claude:arsenal:skill_create backend-api domain
```

**Result:** `.claude/skills/local/backend-api/` (real directory, committed to git)

### Copying Reference Implementations
```bash
# Copy hooks (TypeScript automation)
bake claude:arsenal:copy_hook skill-activator
bake claude:arsenal:copy_hook build-checker

# Copy agents (specialized subagents)
bake claude:arsenal:copy_agent code-architecture-reviewer

# Copy slash commands
bake claude:arsenal:copy_command dev-docs
```

**Result:** Files copied from `.context/claude-arsenal/` to `.claude/`, ready to customize and commit

**Why copy helpers?** They find the files in `.context/` for you and handle overwrite prompts.

**Direct copy also works:**
```bash
cp .context/claude-arsenal/hooks/skill-activator.ts .claude/hooks/
cp .context/claude-arsenal/agents/quality_control/code-architecture-reviewer.md .claude/agents/
```

**Browse available references:**
```bash
ls .context/claude-arsenal/hooks/
ls .context/claude-arsenal/agents/
ls .context/claude-arsenal/commands/
```

## For Claude Code: Automated Setup Assistant

When a user mentions claude-arsenal or you detect they need skill setup:

1. **Check if setup is complete:**
   - Does `.claude/` directory exist?
   - Does `.claude/config/skill-rules.json` exist?
   - Does `.claude/hooks/skill-activator.ts` exist?
   - Are gem skills linked? (check for `.claude/skills/gems/ruby-gem-development`)

2. **If missing, offer to run setup:**

   > I notice claude-arsenal isn't fully set up. I can run the installation command:
   > `bake claude:arsenal:install`
   >
   > This will:
   > 1. Install meta-knowledge from gems to `.context/claude-arsenal/`
   > 2. Create `.claude/` directory structure
   > 3. Symlink 4 ready-to-use skills from the gem
   > 4. Configure `.gitignore` (ignores regeneratable content)
   >
   > After setup, you'll have gem skills ready. I can also copy reference hooks/agents/commands as needed.
   > Shall we start?

3. **Run installation and explain:**
   - Execute `bake claude:arsenal:install`
   - Show what was created and linked
   - Explain the 4 gem skills are ready to use
   - Offer to copy skill-activator hook

4. **Copy reference implementations as needed:**
   - `bake claude:arsenal:copy_hook skill-activator` (enables auto-activation)
   - `bake claude:arsenal:copy_agent code-architecture-reviewer` (if they want code review)
   - `bake claude:arsenal:copy_command dev-docs` (if they want dev docs workflow)
   - Explain these are references they can customize

5. **Suggest project-specific skills based on codebase:**
   - Note: Gem skills cover general patterns (gems, generators, docs, testing)
   - Detect backend code    suggest creating backend-api skill
   - Detect frontend code    suggest creating frontend-components skill
   - Detect domain logic    suggest domain-specific skills
   - Offer to analyze and create skill files

## Complete Setup Workflow (For Claude Code)

When helping a user set up claude-arsenal, follow this checklist:

```markdown
# Claude Arsenal Setup Checklist

- [ ] Run `bake claude:arsenal:install`
- [ ] Verify 4 gem skills are symlinked in `.claude/skills/`:
  - [ ] ruby-gem-development (gem patterns)
  - [ ] generator-patterns (file generation)
  - [ ] documentation-writing (docs guidelines)
  - [ ] test-coverage (testing guardrail)
- [ ] Copy skill-activator hook:
  - [ ] Run `bake claude:arsenal:copy_hook skill-activator`
  - [ ] User can customize `.claude/hooks/skill-activator.ts` if needed
- [ ] (Optional) Copy other reference implementations as needed:
  - [ ] Build checker: `bake claude:arsenal:copy_hook build-checker`
  - [ ] Code reviewer: `bake claude:arsenal:copy_agent code-architecture-reviewer`
  - [ ] Dev docs command: `bake claude:arsenal:copy_command dev-docs`
- [ ] Analyze codebase and create project-specific skills:
  - [ ] Identify needed domains (backend API, frontend, database, etc.)
  - [ ] For each: `bake claude:arsenal:skill_create [name] domain`
  - [ ] Ask user to review generated skills
  - [ ] Update skill-rules.json with activation triggers (or let user do it)
- [ ] Test: Mention a keyword    verify skill auto-loads
```

**After setup, tell the user:**

> Setup complete! Claude Arsenal has linked 4 ready-to-use skills from the gem:
> - ruby-gem-development, generator-patterns, documentation-writing, test-coverage
>
> I've also copied the skill-activator hook so these will auto-load when you mention relevant keywords.
>
> The gem skills can be updated via `bundle update`. I can create project-specific skills for your domain logic if you'd like me to analyze your codebase.
>
> Browse more reference implementations: `.context/claude-arsenal/hooks/`, `agents/`, and `commands/`

## Installation

Add to your Gemfile:

```ruby
gem 'claude_arsenal'
```

Or install directly:

```bash
gem install claude_arsenal
```

## Quick Start

### 1. Install Claude Arsenal

```bash
bake claude:arsenal:install
```

This creates the following structure:

```
.claude/
├── skills/
│   ├── gems/        # From gems (symlinked, gitignored)
│   └── local/       # Project-specific (committed)
├── hooks/
├── agents/
├── commands/
└── config/
    └── skill-rules.json

.context/claude-arsenal/  # Installed from gem (gitignored)
├── getting-started.md
├── skills/
│   ├── ruby-gem-development/
│   ├── generator-patterns/
│   ├── documentation-writing/
│   └── test-coverage/
├── hooks/
├── agents/
└── commands/

dev/
├── active/          # Work-in-progress (gitignored)
└── completed/       # Completed docs (committed)
```

Gem skills are symlinked from `.context/` to `.claude/skills/gems/`. Project skills go in `.claude/skills/local/`. Both types activate based on `skill-rules.json`. Gem skills can be updated via `bundle update`; project skills are version-controlled.

### 2. Create Project-Specific Skills

The installation links 4 gem skills that cover general development patterns. For your project's domain logic, create custom skills:

```bash
bake claude:arsenal:skill_create backend-api domain
```

This creates a domain-specific skill with:
- Main `SKILL.md` file (optimized to be < 500 lines)
- Resources directory for progressive disclosure
- Stored in `.claude/skills/` (not symlinked)

### 3. Set Up Skill Auto-Activation

**Important:** Always run this after creating skills:

```bash
bake claude:arsenal:hook_generate user-prompt-submit skill-activator
```

This creates a hook that automatically suggests relevant skills based on:
- Keywords in your prompts
- Files in context
- Intent patterns

**For Claude Code:** If the user creates a skill, automatically remind them to run this command, or offer to add it to a setup checklist.

### 4. Add Quality Control

```bash
bake claude:arsenal:agent_create code-reviewer quality-control
```

Creates a subagent for architectural code review.

## Core Concepts

### Dev Docs Workflow

The "amnesia problem": Claude loses track during large features. Dev docs solve this:

**Create for new features:**
```bash
bake claude:arsenal:dev_docs_create feature-name
```

Creates three files in `dev/active/feature-name/`:
- **plan.md** - Implementation plan (phases, approach, risks)
- **context.md** - Current status, key files, decisions
- **tasks.md** - Checklist with progress tracking

**Update before context compaction:**
```bash
bake claude:arsenal:dev_docs_update
```

**Archive when complete:**
```bash
bake claude:arsenal:dev_docs_complete feature-name
```

This workflow ensures Claude never loses the plot, even across sessions.

### Skills

Skills are domain-specific guidelines kept under 500 lines for optimal loading. Use progressive disclosure with a resources/ directory for detailed information.

**Best Practice:** Keep the main `SKILL.md` file focused on:
- When to use the skill
- Core principles
- Quick reference
- Links to detailed resources

### Hooks

Hooks automate Claude Code workflows:

**Essential hooks:**
- **skill-activator** (UserPromptSubmit): Auto-loads skills based on context
- **file-edit-tracker** (PostToolUse): Tracks all file modifications
- **build-checker** (Stop): Catches errors before you see them

Generate with:
```bash
bake claude:arsenal:hook_generate user-prompt-submit skill-activator
bake claude:arsenal:hook_generate post-tool-use file-edit-tracker
bake claude:arsenal:hook_generate stop build-checker
```

These three hooks implement the "No Errors Left Behind" philosophy.

### Subagents

Specialized agents for specific tasks:
- **Quality Control**: Code review, refactoring, error resolution
- **Testing**: Test running, debugging
- **Planning**: Strategic planning, documentation

### Slash Commands

Quick commands for common tasks:
- `/dev-docs` - Create comprehensive plans
- `/code-review` - Architectural review
- `/build-and-fix` - Run builds and fix errors

## Command Safety & Idempotency

### Idempotent (Safe to Re-run)

These commands can be run multiple times safely:

```bash
bake claude:arsenal:install            # Idempotent installation
bake agent:context:install             # Updates meta-knowledge
bake claude:arsenal:link_skills        # Recreates symlinks
bake claude:arsenal:dev_docs_update    # Only updates timestamps
bake claude:arsenal:validate           # Validates skill-rules.json syntax
```

### Not Idempotent (Will Overwrite)

**Warning:** These generators will **overwrite existing files without confirmation**:

```bash
bake claude:arsenal:skill_create NAME TYPE
bake claude:arsenal:hook_generate TYPE NAME
bake claude:arsenal:agent_create NAME CATEGORY
bake claude:arsenal:command_create NAME
```

**Best practice:**
1. Generate once
2. Customize the generated file
3. **Don't regenerate** (you'll lose your changes)

If you need to regenerate, back up your customized file first.

**Exception:**
```bash
bake claude:arsenal:dev_docs_create FEATURE
# Errors if directory already exists (won't overwrite)
```

## Next Steps

1. Read `configuration.md` to understand skill-rules.json
2. Read `hooks.md` to learn about hook types and best practices
3. Read `skills.md` for skill creation guidelines
4. Check `examples.md` for real-world patterns

## The Problem This Solves

When using Claude Code, developers face several challenges:

- **Inconsistent code patterns** - Claude doesn't automatically follow your project's conventions
- **Repeated explanations** - You have to keep reminding Claude about your patterns
- **Lost context** - After auto-compaction, Claude forgets your coding standards
- **Manual skill creation** - Writing skills manually is time-consuming
- **No automation** - Skills don't auto-activate when relevant

## What Claude Arsenal Does

1. **Provides scaffolding** - Generators create well-structured skills, hooks, and agents
2. **Teaches best practices** - Meta-knowledge guides Claude in writing quality skills
3. **Enables auto-activation** - Hook system automatically loads relevant skills
4. **Maintains consistency** - Same patterns across all sessions
5. **Enables sharing** - Distribute patterns via git or gems

## What It Does Not Do

This gem is **not a replacement for good documentation**  it provides scaffolding and templates to help you create documentation more easily. It's also not a fully automated code generator; Claude still needs your guidance and review when creating skills.

The gem itself is written in Ruby, but it's **not language-specific**. You can use it with any programming language or framework  the skills you create will document whatever patterns exist in your codebase.

Finally, claude-arsenal is **not prescriptive** about what constitutes "right" or "wrong" patterns. It extracts and documents *your* patterns, whatever they may be, and helps Claude Code follow them consistently.

## Philosophy

Based on real-world Claude Code usage. Key principles:

1. **Self-documenting** - The gem teaches how to use itself via meta-knowledge
2. **Convention over configuration** - Smart defaults, minimal setup
3. **Progressive disclosure** - Keep main files small (<500 lines), details in resources/
4. **Composable knowledge** - Multiple context sources via agent-context
5. **Human-in-the-loop** - Claude extracts patterns, you review and approve

## Git and Version Control

The `bake claude:arsenal:install` command automatically configures `.gitignore`.

### What Gets Committed

```gitignore
# Committed (shared with team):
.claude/hooks/                  # Your team's automation
.claude/agents/                 # Specialized subagents
.claude/commands/               # Slash commands
.claude/config/                 # Activation rules
.claude/skills/local/your-project/    # Project-specific skills (real directories)
dev/completed/                  # Completed feature docs
```

### What Gets Ignored

```gitignore
# Added by claude-arsenal
/dev/active/
/.context/
/.claude/tmp/
/.claude/skills/gems/
```

`.context/` is regenerated by agent-context. Gem skill symlinks in `.claude/skills/gems/` are regenerated by `link_skills`. Work-in-progress docs in `dev/active/` are transient.

## Common Workflows

### Starting a New Feature

```bash
/dev-docs feature-name
# Creates plan, context, and tasks files
```

### Code Review

```bash
/code-review
# Runs architectural review subagent
```

### Fixing Build Errors

```bash
/build-and-fix
# Systematically fixes all build errors
```

## Getting Help

- GitHub Issues: https://github.com/wtn/claude_arsenal/issues
- Documentation: See other files in the context/ directory
- Examples: Check the examples/ directory

