# Dev Docs Workflow

## The Problem

Claude Code is brilliant but has "extreme amnesia." During large features, Claude can:
- Lose track of the implementation plan
- Forget key decisions made earlier
- Repeat work already completed
- Diverge from the approved approach
- Start over after context compaction

## The Solution

A three-file system that persists across sessions, maintaining continuity even through auto-compaction.

## Commands

### Create Dev Docs for New Feature
```bash
bake claude:arsenal:dev_docs_create feature-name
```

Creates three files in `dev/active/feature-name/`:
- `feature-name-plan.md` - The implementation plan
- `feature-name-context.md` - Current status and key information
- `feature-name-tasks.md` - Task checklist with progress

### Update Timestamps
```bash
bake claude:arsenal:dev_docs_update
```

Updates "Last Updated" timestamps in all active dev docs. Run this before context compaction.

### Archive Completed Feature
```bash
bake claude:arsenal:dev_docs_complete feature-name
```

Moves feature from `dev/active/` to `dev/completed/` for future reference.

## File Structure

### Plan File (`feature-plan.md`)

The strategic blueprint for the feature:

```markdown
# Feature Name - Implementation Plan

## Executive Summary
Brief description of what this accomplishes

## Goals
1. Primary objective
2. Secondary objectives

## Approach
### Phase 1: Foundation
### Phase 2: Core Implementation
### Phase 3: Integration
### Phase 4: Testing & Polish

## Technical Design
- Architecture decisions
- Key components
- Data flow

## Risks & Mitigations
| Risk | Impact | Mitigation |

## Success Metrics
- [ ] All tests passing
- [ ] Performance targets met
```

### Context File (`feature-context.md`)

Living document of current state:

```markdown
# Feature Name - Context

## Current Status
**Working on**: [Current task]
**Blocked by**: [Nothing | Blocker description]

## Key Files
### Modified
- `path/to/file.rb` - [What changed]

### Created
- `path/to/new.rb` - [Purpose]

## Decisions Made
1. **Decision**: [What and why]

## Integration Points
- **System A**: How this connects

## Session Handoff Notes
**Continue with**: [Specific next action]
**Remember**: [Important context]
```

### Tasks File (`feature-tasks.md`)

Detailed checklist with progress tracking:

```markdown
# Feature Name - Tasks

Progress: ����� 0%

## Phase 1: Foundation
- [ ] Research existing patterns
- [ ] Design architecture

## Phase 2: Implementation
- [ ] � Create main logic [IN PROGRESS]
- [ ] Add error handling

## Completed
- [x] Initial setup  2024-10-30
```

## Best Practices

### 1. Start Every Feature with Dev Docs

Before writing code:
```bash
bake claude:arsenal:dev_docs_create feature-name
```

Then have Claude:
1. Research the codebase
2. Fill in the plan
3. Get your approval
4. Begin implementation

### 2. Update Regularly

**During work:**
- Mark tasks as � when starting
- Move completed tasks to the Completed section
- Update context with key decisions

**Before context compaction:**
```bash
bake claude:arsenal:dev_docs_update
```

Then tell Claude: "Continue with dev/active/feature-name/"

### 3. Use Standard Markers

In tasks.md:
- `�` = Currently working on
- `�` = Up next
- `` = Complete with date
- `��` = Bug fix needed
- `` = Blocked
- `` = Deferred

### 4. Archive When Done

```bash
bake claude:arsenal:dev_docs_complete feature-name
```

Keeps history for future reference without cluttering active work.

## Integration with Claude Code

### Starting a Feature

> Create dev docs for user authentication feature. Research existing auth patterns, design the approach, and fill in all three files.

### Continuing After Compaction

> Continue with the user authentication feature. Read all files in dev/active/user-authentication/ and proceed with the next uncompleted task.

### Updating Progress

> Update the dev docs: mark current task complete, update context with the integration decision we just made, and identify the next task to work on.

## Why This Works

1. **Persistent Memory** - Information survives context compaction
2. **Clear Handoffs** - Next session knows exactly where to continue
3. **Progress Visibility** - See what's done and what's left
4. **Decision History** - Remember why choices were made
5. **Reduced Repetition** - Stop explaining the same context

## Common Patterns

### Feature Development
```
1. Create dev docs
2. Plan in detail (Phase 1)
3. Get approval
4. Implement iteratively
5. Update docs after each phase
6. Archive when complete
```

### Bug Fix Investigation
```
1. Create dev docs for bug
2. Document symptoms in context
3. Track investigation in tasks
4. Document root cause when found
5. Track fix implementation
6. Archive with lessons learned
```

### Refactoring
```
1. Create dev docs for refactor
2. Document current state
3. Plan target state
4. Create migration tasks
5. Track progress incrementally
6. Archive with before/after
```

## Tips

- **Name features clearly**: `user-auth` not `feature-1`
- **One feature at a time**: Focus prevents confusion
- **Update immediately**: Don't batch updates
- **Review completed/**: Learn from past features
- **Share with team**: Dev docs are great documentation

## Directory Structure

```
dev/
 active/               # Current work
�    user-auth/
�   �    user-auth-plan.md
�   �    user-auth-context.md
�   �    user-auth-tasks.md
�    api-redesign/
�        ...
 completed/           # Archived features
     dark-mode/
     search-feature/
     ...
```

## Real-World Example

User experience:

> "Before using this system, I had many times when I suddenly realized that Claude had lost the plot and we were no longer implementing what we had planned out 30 minutes earlier..."

> "After dev docs: Claude usually likes to just jump in guns blazing, so I immediately slap the ESC key to interrupt and run my `/create-dev-docs` slash command."

> "I just make sure to remind Claude every once in a while to update the tasks as well as the context file with any relevant context."