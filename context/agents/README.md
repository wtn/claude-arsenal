# Reference Agent Configurations

These are specialized sub-agent configurations you can copy to your project.

## Available Agents

### Quality Control
- **code-architecture-reviewer.md** - Reviews code for architectural quality and best practices

### Planning
- **strategic-plan-architect.md** - Creates comprehensive implementation plans

### Generic
- **generic.md** - Template for creating custom agents

## Usage

Copy the agent you need:

```bash
cp .context/claude-arsenal/agents/quality_control/code-architecture-reviewer.md .claude/agents/
```

Then customize the review criteria, output format, or guidelines for your project.

## Customization

Agents often need project-specific tuning:
- Checklist items specific to your stack
- Output format matching your team's preferences
- Guidelines aligned with your coding standards
- References to your project's skills

## Why Copy?

Agent configurations are Markdown files that define behavior. While they're passive (not executable), they typically need customization to match your project's needs and workflows.
