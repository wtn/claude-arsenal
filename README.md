# Claude Arsenal

Reusable skills, hooks, and agents for [Claude Code](https://www.claude.com/product/claude-code). Distribute via gems using [agent-context](https://github.com/ioquatix/agent-context).

## Install

```ruby
# Gemfile
gem 'claude-arsenal'
```

```bash
bundle install
bake claude:arsenal:install
```

Creates `.claude/` structure with 4 gem skills in `.claude/skills/gems/` and configures `.gitignore`.

## Usage

Copy reference implementations:

```bash
bake claude:arsenal:copy_hook skill-activator
bake claude:arsenal:copy_agent code-architecture-reviewer
bake claude:arsenal:copy_command dev-docs
```

Create project skills:

```bash
bake claude:arsenal:skill_create backend-api domain
```

## Structure

```
.claude/
├── skills/
│   ├── gems/        # From gems (symlinked, gitignored)
│   └── local/       # Project-specific (committed)
├── hooks/           # Copied references (committed)
├── agents/          # Copied references (committed)
└── commands/        # Copied references (committed)
```

Gem skills install to `.context/claude-arsenal/` and symlink to `.claude/skills/gems/`. Project skills go in `.claude/skills/local/`. Hooks, agents, and commands are copied from `.context/claude-arsenal/` for customization.

## Documentation

See [getting-started.md](context/getting-started.md) for complete documentation.

Run `bake -T claude:arsenal` to see all commands.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
