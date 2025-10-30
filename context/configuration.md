# Configuration

## skill-rules.json

The `skill-rules.json` file controls when and how skills are activated automatically.

### Location

`.claude/config/skill-rules.json`

### Schema

```json
{
  "_meta": {
    "version": "1.0",
    "description": "Skill activation rules"
  },
  "skill-name": {
    "type": "domain" | "guidelines" | "guardrail",
    "enforcement": "suggest" | "require" | "block",
    "priority": "low" | "medium" | "high" | "critical",
    "promptTriggers": {
      "keywords": ["array", "of", "keywords"],
      "intentPatterns": ["regex", "patterns"]
    },
    "fileTriggers": {
      "pathPatterns": ["glob", "patterns"],
      "contentPatterns": ["regex", "patterns"]
    },
    "_linked": true,              // Optional: true if skill is symlinked from gem
    "_source": "gem-name"         // Optional: which gem provides this skill
  }
}
```

**Note:** Skills linked from gems (via `bake claude:arsenal:link_skills`) automatically include `_linked` and `_source` metadata. These fields are managed by the skill linker and should not be manually edited.

### Field Descriptions

#### type

Categorizes the skill:
- **`domain`**: Domain-specific knowledge (backend, frontend, etc.)
- **`guidelines`**: General best practices (testing, documentation)
- **`guardrail`**: Safety checks and validation

#### enforcement

Controls how strongly the skill is recommended:
- **`suggest`** (default): Gentle reminder with 
- **`require`**: Strong warning with 
- **`block`**: Prevents action with ›‘ (requires custom implementation)

#### priority

Determines activation order when multiple skills match:
- **`low`**: Optional enhancements
- **`medium`**: General guidelines (default)
- **`high`**: Core domain knowledge
- **`critical`**: Safety and security

#### promptTriggers

Triggers based on what the user types:

**keywords**: Simple string matching (case-insensitive)
```json
"keywords": ["backend", "API", "controller", "service"]
```

**intentPatterns**: Regex patterns for complex matching
```json
"intentPatterns": [
  "(create|add|implement).*?(route|endpoint)",
  "(how to|best practice).*?backend"
]
```

#### fileTriggers

Triggers based on files in context:

**pathPatterns**: Glob patterns for file paths
```json
"pathPatterns": [
  "app/**/*_controller.rb",
  "lib/services/**/*.rb",
  "src/**/*.ts"
]
```

**contentPatterns**: Regex patterns for file content
```json
"contentPatterns": [
  "class.*Controller",
  "include.*Service"
]
```

## Gem-Provided Skills

When you run `bake claude:arsenal:install`, four skills from claude-arsenal are automatically linked and configured:

### ruby-gem-development

```json
{
  "ruby-gem-development": {
    "type": "domain",
    "enforcement": "suggest",
    "priority": "high",
    "promptTriggers": {
      "keywords": ["gem", "gemspec", "bundler", "rake", "bake"],
      "intentPatterns": [
        "(create|update|modify).*?(gem|gemspec)",
        "(build|release|publish).*?gem"
      ]
    },
    "fileTriggers": {
      "pathPatterns": ["*.gemspec", "Gemfile", "Rakefile", "lib/**/*.rb"],
      "contentPatterns": ["Gem::Specification", "module Claude"]
    },
    "_linked": true,
    "_source": "claude-arsenal"
  }
}
```

**Other included skills:** `generator-patterns`, `documentation-writing`, `test-coverage`

These entries are auto-generatedyou don't need to manually add them. The skill linker reads YAML frontmatter from each skill file and creates the configuration automatically.

## Example Configurations (Project-Specific)

### Backend Development Skill

```json
{
  "backend-dev": {
    "type": "domain",
    "enforcement": "suggest",
    "priority": "high",
    "promptTriggers": {
      "keywords": ["backend", "API", "controller", "service", "endpoint"],
      "intentPatterns": [
        "(create|add|implement).*?(route|endpoint|controller|service)",
        "(how to|best practice|pattern).*?(backend|API)"
      ]
    },
    "fileTriggers": {
      "pathPatterns": [
        "app/**/*_controller.rb",
        "lib/services/**/*.rb",
        "app/controllers/**/*.rb"
      ],
      "contentPatterns": [
        "class.*Controller",
        "class.*Service"
      ]
    }
  }
}
```

### Database Migration Guardrail

```json
{
  "database-migrations": {
    "type": "guardrail",
    "enforcement": "require",
    "priority": "critical",
    "promptTriggers": {
      "keywords": ["migration", "migrate", "database", "schema", "alter table"],
      "intentPatterns": [
        "(create|generate).*?migration",
        "(add|remove|change).*?(column|index|table)"
      ]
    },
    "fileTriggers": {
      "pathPatterns": [
        "db/migrate/**/*.rb",
        "migrations/**/*.sql"
      ]
    }
  }
}
```

### Testing Guidelines

```json
{
  "testing-standards": {
    "type": "guidelines",
    "enforcement": "suggest",
    "priority": "medium",
    "promptTriggers": {
      "keywords": ["test", "spec", "testing", "rspec", "minitest"],
      "intentPatterns": [
        "(write|add|create).*?test",
        "how to test"
      ]
    },
    "fileTriggers": {
      "pathPatterns": [
        "test/**/*.rb",
        "spec/**/*.rb",
        "**/*_test.rb",
        "**/*_spec.rb"
      ]
    }
  }
}
```

## Best Practices

### Keywords

- Use lowercase (matching is case-insensitive)
- Include variations: "backend", "back-end", "back end"
- Be specific but not too narrow
- 5-10 keywords is usually enough

### Intent Patterns

- Use regex groups: `(create|add|implement)`
- Match partial strings with `.*?`
- Test patterns before deploying
- Don't make them too complex

### File Patterns

- Use glob syntax: `**` for any directory depth
- Match both singular and plural: `service` and `services`
- Include framework conventions: `*_controller.rb`
- Test patterns with actual file paths

### Priority Guidelines

Set priority based on importance:

**Critical:**
- Security checks
- Data safety (migrations, deletions)
- Production safeguards

**High:**
- Core domain knowledge
- Main architectural patterns
- Frequently-used workflows

**Medium:**
- General guidelines
- Best practices
- Optional patterns

**Low:**
- Nice-to-have improvements
- Style preferences
- Experimental patterns

## Validation

Validate your configuration:

```bash
bake claude:arsenal:validate
```

This checks for:
- Valid JSON syntax
- Required fields present
- Valid enum values
- Proper pattern syntax

## Troubleshooting

### Skill not activating

1. **Check keywords**: Are they in your prompt?
2. **Test patterns**: Use a regex tester
3. **Check priority**: Higher priority skills activate first
4. **Verify file paths**: Do glob patterns match your files?

### Too many skills activating

1. **Make keywords more specific**
2. **Use intent patterns instead of keywords**
3. **Adjust priorities**
4. **Review enforcement levels**

### Skills activating incorrectly

1. **Review intent patterns** - might be too broad
2. **Check file content patterns** - might match unintended files
3. **Test with actual prompts**

## Advanced Configuration

### Combining Triggers

All trigger conditions are OR'd within a category, AND'd across categories:

```
(keyword1 OR keyword2 OR pattern1) AND (if files present: filePath1 OR filePath2)
```

### Disabling a Skill Temporarily

Add underscore prefix to skill name:

```json
{
  "_backend-dev-DISABLED": {
    ...
  }
}
```

### Environment-Specific Rules

Use different configs for dev/production:

```json
{
  "database-migrations": {
    "enforcement": "suggest"  // dev
    "enforcement": "require"  // production
  }
}
```

