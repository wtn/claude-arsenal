# Hooks in Claude Arsenal

## What Are Hooks?

Hooks are TypeScript/JavaScript functions that run at specific points in Claude Code's workflow, enabling automation and workflow enhancements.

## Hook Types

### UserPromptSubmit

**When it runs:** Before Claude processes your message

**Use cases:**
- Auto-suggest relevant skills based on keywords
- Add context reminders
- Validate input before processing

**Example:** skill-activator hook

### PostToolUse

**When it runs:** After Claude uses any tool (Read, Write, Edit, etc.)

**Use cases:**
- Track file modifications
- Log actions for later analysis
- Trigger follow-up actions

**Example:** file-edit-tracker hook

### Stop

**When it runs:** When conversation ends

**Use cases:**
- Run builds on modified files
- Check for errors
- Remind about follow-up tasks
- Clean up temporary files

**Examples:** build-checker, error-reminder hooks

## Using Hooks from Claude Arsenal

### Reference Implementations Available

Claude Arsenal ships with 4 hooks in `.context/claude-arsenal/hooks/`:

- **skill-activator.ts** - Auto-loads skills based on keywords and file context
- **build-checker.ts** - Runs builds when conversation ends, reports errors
- **file-edit-tracker.ts** - Tracks all file modifications
- **error-reminder.ts** - Gentle reminders about error handling

### Copy When Needed

```bash
# Copy the skill activator (UserPromptSubmit)
bake claude:arsenal:copy_hook skill-activator

# Copy file tracker (PostToolUse)
bake claude:arsenal:copy_hook file-edit-tracker

# Copy build checker (Stop)
bake claude:arsenal:copy_hook build-checker
```

**Or copy manually:**
```bash
cp .context/claude-arsenal/hooks/skill-activator.ts .claude/hooks/
```

### Reference Implementations

Claude Arsenal provides hooks you can copy and customize:

**skill-activator.ts** (UserPromptSubmit)
- Reads skill-rules.json
- Matches keywords and patterns
- Injects skill reminders
- Location: `.context/claude-arsenal/hooks/skill-activator.ts`

**file-edit-tracker.ts** (PostToolUse)
- Logs file modifications
- Stores data for Stop hooks
- Tracks create/edit/delete operations
- Location: `.context/claude-arsenal/hooks/file-edit-tracker.ts`

**build-checker.ts** (Stop)
- Runs TypeScript/Ruby builds
- Reports errors
- Offers to fix issues
- Location: `.context/claude-arsenal/hooks/build-checker.ts`

**error-reminder.ts** (Stop)
- Scans for risky patterns
- Reminds about error handling
- Provides gentle suggestions
- Location: `.context/claude-arsenal/hooks/error-reminder.ts`

**Why copy instead of symlink?**
Hooks are executable TypeScript code that often needs project-specific customization (build commands, file patterns, error parsing). You copy the reference, customize it, and own the result.

## Hook Configuration

Hooks are configured in `.claude/hooks/config.json`:

```json
{
  "hooks": {
    "userPromptSubmit": ["skill-activator.ts"],
    "postToolUse": ["file-edit-tracker.ts"],
    "stop": ["build-checker.ts", "error-reminder.ts"]
  }
}
```

## Writing Custom Hooks

### Basic Structure

```typescript
export async function hook(params: HookParams): Promise<HookResult> {
  try {
    // Your logic here
    return { reminder: "Optional message" };
  } catch (error) {
    console.error('Error in hook:', error);
    return {};
  }
}
```

### UserPromptSubmit Hook

```typescript
interface UserPromptSubmitParams {
  userPrompt: string;
  contextFiles?: string[];
}

interface UserPromptSubmitResult {
  reminder?: string;
}

export async function hook(
  params: UserPromptSubmitParams
): Promise<UserPromptSubmitResult> {
  // Analyze prompt and context
  // Return reminder if needed
  return { reminder: "Consider reviewing skill X" };
}
```

### PostToolUse Hook

```typescript
interface PostToolUseParams {
  toolName: string;
  toolInput: any;
  toolOutput: any;
}

export async function hook(params: PostToolUseParams): Promise<void> {
  // Track tool usage
  // Log or process as needed
}
```

### Stop Hook

```typescript
export async function hook(): Promise<{ reminder?: string }> {
  // Run cleanup or checks
  // Return final reminders
  return { reminder: "Build passed " };
}
```

## Best Practices

### Performance

- **Keep hooks fast** - They run on every action
- **Use caching** - Don't re-read files unnecessarily
- **Fail gracefully** - Always catch errors
- **Minimize I/O** - Reduce file operations

### Error Handling

```typescript
export async function hook(params: any): Promise<any> {
  try {
    // Main logic
  } catch (error) {
    // Log but don't throw - hooks should never break Claude
    console.error('Hook error:', error);
    return {}; // Return empty result
  }
}
```

### File Operations

```typescript
import * as fs from 'fs';
import * as path from 'path';

// Always check existence
if (fs.existsSync(filePath)) {
  const content = fs.readFileSync(filePath, 'utf-8');
}

// Use absolute paths
const absolutePath = path.join(process.cwd(), relativePath);
```

### Integration with skill-rules.json

```typescript
const rulesPath = path.join(process.cwd(), '.claude/config/skill-rules.json');
const rules = JSON.parse(fs.readFileSync(rulesPath, 'utf-8'));

// Match keywords
const matched = Object.entries(rules).filter(([name, rule]) => {
  return rule.promptTriggers?.keywords?.some(keyword =>
    userPrompt.toLowerCase().includes(keyword.toLowerCase())
  );
});
```

## Troubleshooting

### Hook not running

1. Check `.claude/hooks/config.json` - is hook listed?
2. Verify file name matches config
3. Check for TypeScript errors: `npx tsc --noEmit`
4. Look in Claude Code logs

### Hook causing errors

1. Check console for error messages
2. Add more try-catch blocks
3. Test hook logic in isolation
4. Simplify and gradually add features

### Hook running too slowly

1. Profile with `console.time()`
2. Cache file reads
3. Reduce regex complexity
4. Limit file scanning

## Examples

See templates in `lib/claude/arsenal/templates/hooks/` for full working examples.

