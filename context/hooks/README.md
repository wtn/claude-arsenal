# Reference Hook Implementations

These are hook implementations you can copy to your project.

## Available Hooks

- **skill-activator.ts** - Auto-activates skills based on keywords and file context
- **build-checker.ts** - Runs builds when conversation ends, reports errors
- **file-edit-tracker.ts** - Tracks file modifications across conversation
- **error-reminder.ts** - Gentle reminders about error handling best practices

## Usage

Copy the hook you need to your project:

```bash
cp .context/claude-arsenal/hooks/skill-activator.ts .claude/hooks/
```

Then customize as needed for your project (build commands, file patterns, etc.).

## Why Copy Instead of Symlink?

Hooks are executable TypeScript code that often needs project-specific customization:
- Build commands differ per project
- File path patterns vary
- Error parsing logic changes by framework

Once you copy and customize, the hook is yours. You own the code that executes in your project.

## Getting Updates

If we improve a hook after you've copied it, you can:
1. Check `.context/claude-arsenal/hooks/` for the updated version
2. Diff your customized version against the reference
3. Merge improvements you want to keep
