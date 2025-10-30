# Complete Skill File Examples

Real-world examples of well-structured SKILL.md files following progressive disclosure.

## Example 1: Domain Skill

```markdown
---
type: domain
enforcement: suggest
priority: high
keywords: [backend, API, controller, service, repository]
intentPatterns:
  - "(create|build|implement).*?(API|endpoint|route|controller)"
  - "(how to|best practice).*?(backend|service|repository)"
pathPatterns:
  - "backend/src/**/*.ts"
  - "lib/**/*_controller.rb"
contentPatterns:
  - "class.*Controller"
  - "export.*Service"
---

# Backend API Development Skill

## Purpose

This skill provides architecture patterns and best practices for building backend APIs following the Routes → Controllers → Services → Repositories pattern.

## When to Use This Skill

Use this skill when:
- Creating new API endpoints
- Implementing business logic in services
- Working with database operations
- Reviewing backend code

## Core Principles

### 1. Separation of Concerns

Each layer has a specific responsibility:
- **Routes**: HTTP handling, request parsing
- **Controllers**: Request validation, response formatting
- **Services**: Business logic, orchestration
- **Repositories**: Database operations, data access

**See** `resources/architecture-layers.md` for detailed examples

### 2. Error Handling

All service methods must handle errors gracefully.

**See** `resources/error-handling-patterns.md` for complete guide

### 3. Testing Strategy

Test each layer independently with appropriate fixtures.

**See** `resources/testing-strategies.md` for examples

## Quick Patterns

### Creating a New Endpoint

```ruby
# 1. Route
router.post('/api/users', UsersController.create)

# 2. Controller
class UsersController
  def create(request)
    service.create_user(request.params)
  end
end

# 3. Service
class UsersService
  def create_user(params)
    repository.insert(params)
  end
end
```

For complete implementation, see `resources/endpoint-creation.md`

## Resources

- `resources/architecture-layers.md` - Detailed layer responsibilities
- `resources/error-handling-patterns.md` - Complete error handling guide
- `resources/testing-strategies.md` - Test patterns for each layer
- `resources/endpoint-creation.md` - Step-by-step endpoint creation
- `resources/common-patterns.md` - Repository patterns, service patterns

## Common Issues

For troubleshooting, see `resources/troubleshooting.md`

---

*Skill Type: Domain*
*Priority: High*
*Last updated: 2025-11-01*
```

## Example 2: Guidelines Skill

```markdown
---
type: guidelines
enforcement: suggest
priority: medium
keywords: [documentation, README, markdown, guide]
intentPatterns:
  - "(write|create|update).*?(documentation|README|guide)"
pathPatterns:
  - "**/*.md"
  - "docs/**/*"
contentPatterns:
  - "^# .*"
---

# Documentation Writing Skill

## Purpose

Guidelines for writing clear, maintainable documentation with progressive disclosure.

## When to Use This Skill

Use this skill when:
- Writing README files
- Creating skill documentation
- Updating project docs
- Writing technical guides

## Core Principles

### 1. Progressive Disclosure

Start simple, link to details. Main file should be scannable in 2 minutes.

**Example:**
```markdown
# Quick Start

1. Install: `gem install my-gem`
2. Run: `bake my_gem:install`
3. Use: See `docs/usage-guide.md` for comprehensive examples

For advanced features, see:
- `docs/advanced-patterns.md`
- `docs/troubleshooting.md`
```

See `resources/progressive-disclosure-examples.md` for more patterns

### 2. Scannable Structure

Use headings, bullet points, and code blocks effectively.

See `resources/structure-patterns.md` for examples

### 3. Code Examples

Every pattern should have working code examples.

See `resources/code-example-patterns.md` for guidelines

## Quick Reference

### README Template

```markdown
# Project Name

One-line description

## Quick Start
[3-5 step install/usage]

## Features
[Bulleted list]

## Documentation
- [Getting Started](docs/getting-started.md)
- [API Reference](docs/api.md)

## License
MIT
```

## Resources

- `resources/progressive-disclosure-examples.md` - Complete examples
- `resources/structure-patterns.md` - Document structure patterns
- `resources/code-example-patterns.md` - How to write good examples
- `resources/markdown-formatting.md` - Formatting best practices
- `resources/readme-templates.md` - README templates

---

*Skill Type: Guidelines*
*Priority: Medium*
```

## Example 3: Guardrail Skill

```markdown
---
type: guardrail
enforcement: require
priority: critical
keywords: [database, migration, schema, column]
intentPatterns:
  - "(create|add|modify|drop).*?(table|column|migration)"
  - "ALTER TABLE"
pathPatterns:
  - "db/migrate/**/*"
  - "prisma/schema.prisma"
contentPatterns:
  - "createTable"
  - "addColumn"
  - "ALTER TABLE"
---

# Database Schema Guardrail

## Purpose

[!!] Prevents database schema errors by enforcing validation checks before migrations.

## When This Activates

This guardrail triggers when:
- Creating or modifying database migrations
- Updating Prisma schema
- Adding/dropping tables or columns

## Required Checks

Before proceeding with ANY database changes, verify:

### [!] Safety Check #1: Column Name Validation

- [ ] All column names checked against existing schema
- [ ] No duplicate columns being added
- [ ] Naming follows conventions (snake_case)

**Why:** Prevents "column already exists" errors in production

See `resources/column-validation.md` for complete checklist

### [!] Safety Check #2: Migration Testing

- [ ] Migration tested with `rake db:migrate`
- [ ] Rollback tested with `rake db:rollback`
- [ ] Verified on development database

**Why:** Catches migration errors before production

See `resources/migration-testing.md` for testing procedure

### [!] Safety Check #3: Data Safety

- [ ] Existing data migration plan documented
- [ ] No data loss from schema changes
- [ ] Backup plan in place

**Why:** Protects production data

## Dangerous Operations

[!!] **NEVER** do the following without explicit approval:

1. **Drop columns with data**
   - Why: Irreversible data loss
   - Safe alternative: Deprecate, then drop in later release

2. **Change column types without migration**
   - Why: Can cause data corruption
   - Safe alternative: Create new column, migrate data, drop old

See `resources/dangerous-operations.md` for complete list

## Resources

- `resources/column-validation.md` - Complete validation checklist
- `resources/migration-testing.md` - Testing procedures
- `resources/dangerous-operations.md` - Operations that require approval
- `resources/safe-migration-patterns.md` - Proven safe patterns
- `resources/rollback-procedures.md` - What to do when things go wrong

## Enforcement

**Enforcement Level:** REQUIRE

[!!] This guardrail will **block** operations until all checks are verified.

---

*Skill Type: Guardrail*
*Priority: Critical*
```

## Key Differences by Skill Type

### Domain Skills
- Focus on HOW to implement specific domain patterns
- Provide architecture examples
- Link to detailed implementation guides in resources/

### Guidelines Skills
- Focus on WHAT makes good code/docs
- Provide before/after examples
- Link to style guides and formatting rules in resources/

### Guardrail Skills
- Focus on PREVENTING mistakes
- Provide safety checklists
- Link to dangerous operation lists and safe alternatives in resources/

## Progressive Disclosure Pattern

```markdown
# Main Skill (< 500 lines)

## Core Principle

[2-3 sentences explaining the principle]

**Quick Example:**
```ruby
# 10-line example
```

**For complete implementation:** See `resources/detailed-example.md`

## Resources (in resources/ directory)

- `detailed-example.md` - 200+ line complete example
- `edge-cases.md` - Edge cases and solutions
- `testing.md` - How to test this pattern
```

This keeps the main file lightweight while providing deep resources when needed.
