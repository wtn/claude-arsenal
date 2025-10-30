# Getting Started with Claude Arsenal

Claude Arsenal provides workflow tools, configuration generators, and documentation skills for Claude Code projects. It uses `agent-context` to distribute reference implementations via Ruby gems.

## What Problem Does This Solve?

**Problem:** Claude Code doesn't automatically follow your project's patterns. After context compaction, it forgets your coding standards and conventions.

**Solution:** Claude Arsenal provides:
- Skill system: Document your patterns once, auto-activate when relevant
- Hook system: Automate common workflows (skill activation, build checking)
- Dev docs workflow: Persistent documentation that survives context compaction
- Reference implementations: Proven hooks, agents, and commands you can copy and customize

## Architecture: How It Works

### Two Types of Skills

**Gem Skills** (in `.claude/skills/gems/`):
- Symlinked from `.context/[gem-name]/skills/`
- Provided by installed gems (like this one)
- Gitignored and regenerated on install
- Updated via `bundle update`
- Example: `documentation-writing` skill from claude-arsenal gem

**Local Skills** (in `.claude/skills/local/`):
- Generated from templates via `bake claude:arsenal:skill_create`
- Customized with *your* project's specific patterns
- Committed to git (contains unique project knowledge)
- Example: Your backend API patterns, your testing conventions

### Three Types of Reference Files

All shipped in `.context/claude-arsenal/` (gitignored, regenerated):

**1. Hooks** (TypeScript code that executes):
- Copy to `.claude/hooks/` and customize
- Example: `skill-activator.ts` reads `skill-rules.json` to auto-activate skills

**2. Agents** (subagent configurations):
- Copy to `.claude/agents/` and customize
- Example: `code-architecture-reviewer.md` for quality control

**3. Commands** (slash command implementations):
- Copy to `.claude/commands/` and customize
- Example: `dev-docs.md` for creating feature documentation

**Why copy instead of symlink?** These files execute code or contain project-specific configuration. You need to own and version-control your customizations.

### File Structure After Install

```
.claude/
├── skills/
│   ├── gems/                      # Symlinks (gitignored)
│   │   └── documentation-writing/ # From claude-arsenal gem
│   └── local/                     # Real dirs (committed)
│       └── backend-api/           # Your custom skill
├── hooks/
│   └── skill-activator.ts         # Copied and customized
├── agents/
│   └── code-reviewer.md           # Copied and customized
├── commands/
│   └── dev-docs.md                # Copied and customized
└── config/
    └── skill-rules.json           # Skill activation rules

.context/                          # Gitignored (regenerated)
└── claude-arsenal/                # Installed from gem
    ├── getting-started.md         # This file
    ├── skills/
    │   └── documentation-writing/
    ├── hooks/
    ├── agents/
    └── commands/

dev/
├── active/                        # Gitignored (WIP)
└── completed/                     # Committed (archives)
```

## Quick Start

### Installation

```bash
# Add to Gemfile
gem 'claude-arsenal'

# Install
bundle install
bake claude:arsenal:install
```

This installs the documentation-writing skill and configures `.gitignore`.

### After Pulling Changes

```bash
git pull
bundle install
bake claude:arsenal:link_skills  # Recreates gitignored symlinks
```

### Creating Your First Local Skill

```bash
# Generate a skill template
bake claude:arsenal:skill_create backend-api domain

# Edit the generated file
vim .claude/skills/local/backend-api/SKILL.md

# Add activation rules to .claude/config/skill-rules.json
```

The generated skill is a *template*. Fill it with your project's actual patterns (API structure, naming conventions, etc.).

### Copying Reference Implementations

```bash
# Browse what's available
ls .context/claude-arsenal/hooks/
ls .context/claude-arsenal/agents/
ls .context/claude-arsenal/commands/

# Copy what you need
bake claude:arsenal:copy_hook skill-activator
bake claude:arsenal:copy_agent code-architecture-reviewer
bake claude:arsenal:copy_command dev-docs
```

## Common Questions

### What's the difference between gem skills and local skills?

**Gem skills:**
- General-purpose patterns (like documentation-writing)
- Provided by installed gems
- You never edit them
- Updated via `bundle update`

**Local skills:**
- Your project's specific patterns
- Generated from templates, then you fill them in
- Contains knowledge unique to your codebase
- Version controlled with your project

### What should I commit to git?

**Commit:**
- `agents.md` - AI agent entry point (follows agent-context spec)
- `.claude/skills/local/` - Your custom skills
- `.claude/hooks/` - Your hook customizations
- `.claude/agents/` - Your agent configs
- `.claude/commands/` - Your command customizations
- `.claude/config/skill-rules.json` - Activation rules
- `dev/completed/` - Archived feature docs

**Ignore (regenerated by install):**
- `.context/` - Gem-provided reference docs
- `.claude/skills/gems/` - Gem skill symlinks
- `dev/active/` - Work-in-progress feature docs
- `CLAUDE.md` - Auto-generated pointer file

### How do skills get activated?

1. Install the `skill-activator` hook: `bake claude:arsenal:copy_hook skill-activator`
2. Configure `.claude/config/skill-rules.json` with keywords/patterns
3. When you mention those keywords, the hook suggests loading the skill

The skill-activator reads your config and automatically suggests relevant skills based on:
- Keywords in your prompts
- File paths in context
- Content patterns in files

### When should I use the dev-docs workflow?

Use dev-docs for multi-session features where Claude might lose context:

```bash
# Starting a feature
bake claude:arsenal:dev_docs_create user-authentication

# Before Claude compacts context
bake claude:arsenal:dev_docs_update

# When feature is done
bake claude:arsenal:dev_docs_complete user-authentication
```

Creates `plan.md`, `context.md`, and `tasks.md` in `dev/active/` to maintain continuity across sessions.

### Can I regenerate files safely?

**Safe to regenerate:**
- `bake claude:arsenal:install` - Mostly safe (see note below)
- `bake agent:context:install` - Safe (updates meta-knowledge)
- `bake claude:arsenal:link_skills` - Safe (recreates symlinks)

**Note on `bake claude:arsenal:install`:**
- ✓ Won't overwrite: `.claude/config/skill-rules.json`, `context/` templates
- ✓ Updates safely: `.gitignore` entries, skill symlinks, `agents.md`
- ✗ **Will overwrite**: `.claude/hooks/skill-activator.ts`

The skill-activator hook is pure logic that reads config from `.claude/config/skill-rules.json`. Most users never edit the TypeScript - they only edit the JSON config (which is preserved). Only matters if you've customized the hook's matching logic.

**Not safe to regenerate (will overwrite):**
- `bake claude:arsenal:skill_create NAME TYPE` - Overwrites existing skill
- `bake claude:arsenal:copy_hook NAME` - Asks for confirmation
- `bake claude:arsenal:copy_agent NAME` - Asks for confirmation
- `bake claude:arsenal:copy_command NAME` - Asks for confirmation

Generate once, then customize. Don't regenerate or you'll lose your changes.

## Command Reference

### Installation & Setup

```bash
bake claude:arsenal:install              # Full setup
bake agent:context:install               # Update meta-knowledge
bake claude:arsenal:link_skills          # Recreate symlinks
```

### Creating Content

```bash
bake claude:arsenal:skill_create NAME TYPE
  # Types: domain, guidelines, guardrail
  # Creates: .claude/skills/local/NAME/

bake claude:arsenal:copy_hook NAME
  # Available: skill-activator, build-checker, file-edit-tracker, error-reminder

bake claude:arsenal:copy_agent NAME
  # Available: code-architecture-reviewer, strategic-plan-architect

bake claude:arsenal:copy_command NAME
  # Available: dev-docs, code-review, build-and-fix
```

### Dev Docs Workflow

```bash
bake claude:arsenal:dev_docs_create FEATURE
  # Creates: dev/active/FEATURE/{plan,context,tasks}.md

bake claude:arsenal:dev_docs_update
  # Updates timestamps before context compaction

bake claude:arsenal:dev_docs_complete FEATURE
  # Moves: dev/active/FEATURE/ -> dev/completed/FEATURE/
```

### Browsing Available Content

```bash
ls .context/claude-arsenal/hooks/
ls .context/claude-arsenal/agents/
ls .context/claude-arsenal/commands/
ls .context/claude-arsenal/skills/
```

## What Should Go in Context vs Skills?

**Skills** (in `.claude/skills/`):
- *How* to write code following this project's patterns
- Reusable patterns: "Controllers → Services → Repositories"
- Best practices: Error handling, testing approaches
- Code structure: Component organization, module patterns

**Context** (in `context/`):
- *Why* architectural decisions were made
- Non-obvious gotchas: "Unlimited actually means 99/sec"
- Integration points: How systems connect, auth flows
- Domain terminology: Project-specific terms
- Setup quirks: Things that break if you don't know them

**What NOT to document anywhere:**
- How to run tests (Claude knows: `bundle exec rake test`)
- Standard naming conventions (Claude knows: snake_case, PascalCase)
- How to use git (Claude knows: `git commit -m "message"`)
- Basic language syntax (Claude knows: Ruby, Python, JavaScript, etc.)

**Focus on high-value content that Claude can't infer from code.**

## For Claude Code: Helping Users Write Good Context

When helping users create or update `context/` files:

1. **Ask about gotchas**, not basics:
   - "What setup issues have surprised new developers?"
   - "Are there any non-obvious integration behaviors?"
   - "What design decisions would someone question?"
   - "What domain terms need explanation?"

2. **Discourage generic content**:
   - If they start documenting "bundle install" - stop them
   - If they're explaining standard Ruby conventions - redirect to skills
   - If it's obvious from the code - suggest removing it

3. **Guide toward value**:
   - "What would surprise someone familiar with [language]?"
   - "What broke in production that wasn't obvious?"
   - "Why did you choose X over the more common Y?"

4. **Keep it short**:
   - getting-started.md: Focus on project-specific setup gotchas
   - architecture.md: Focus on design decisions and WHY
   - conventions.md: Only document DIFFERENCES from standards

5. **Use markdown formatting**:
   - Use *italics* for emphasis, not ALL-CAPS
   - Use **bold** for strong emphasis
   - ALL-CAPS is harder to read and less professional in prose
   - Acceptable ALL-CAPS uses: acronyms (API, HTTP), code constants, safety warnings
   - Use emoji extremely sparingly (only for safety warnings or critical alerts)

**Remember:** Context tokens are precious. Every line should justify its cost.

## Philosophy & Principles

1. **Progressive Disclosure:** Main files stay under 500 lines, details in `resources/`
2. **Convention Over Configuration:** Smart defaults, minimal setup required
3. **Explicit Ownership:** Copy and customize rather than magical symlinks for executable code
4. **Composable Knowledge:** Multiple context sources via agent-context ecosystem
5. **Human-in-the-Loop:** Templates provide structure, you provide project knowledge

## What This Gem Does Not Do

- Not a replacement for good documentation (it's scaffolding to help you create it)
- Not language-specific (works with any programming language)
- Not prescriptive about what's "right" (documents *your* patterns, whatever they are)
- Not fully automated (you review and customize what's generated)

## Next Steps

- Read `configuration.md` to understand skill-rules.json schema
- Read `hooks.md` to learn about hook types and best practices
- Read `skills.md` for skill creation guidelines
- Read `dev-docs.md` for the dev docs workflow details
- Check `examples.md` for real-world usage patterns

## Getting Help

- GitHub Issues: https://github.com/wtn/claude_arsenal/issues
- Documentation: See other files in `.context/claude-arsenal/`
