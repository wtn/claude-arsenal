---
type: domain
enforcement: suggest
priority: high
keywords: [gem, gemspec, bundler, rake, bake, ruby gem, dependency]
intentPatterns:
  - "(create|update|modify|add).*?(gem|gemspec|dependency)"
  - "(build|release|publish).*?gem"
  - "(module|class).*?(Claude|Arsenal)"
pathPatterns:
  - "*.gemspec"
  - "Gemfile"
  - "Rakefile"
  - "lib/**/*.rb"
  - "bake/**/*.rb"
contentPatterns:
  - "Gem::Specification"
  - "spec\\.add_dependency"
  - "module Claude"
  - "module Arsenal"
---

# Ruby Gem Development Skill

## Purpose

This skill provides best practices and patterns for developing Ruby gems, specifically focused on the conventions and standards used in Claude Arsenal.

## When to Use This Skill

Use this skill when:
- Creating new Ruby gem functionality
- Modifying gemspec files
- Working with Bake tasks
- Managing dependencies
- Writing RBS type signatures
- Structuring gem modules

## Core Principles

### 1. Module Organization

Structure code using proper Ruby module hierarchy:

**Example:**
```ruby
# Good - Clear module hierarchy
module Claude
  module Arsenal
    module Generators
      class Skill
        # Implementation
      end
    end
  end
end

# Bad - Flat structure
class ClaudeArsenalSkillGenerator
  # Implementation
end
```

### 2. Gemspec Best Practices

Keep gemspec clean, accurate, and well-documented:

```ruby
# Good
Gem::Specification.new do |spec|
  spec.name = "claude-arsenal"
  spec.version = Claude::Arsenal::VERSION
  spec.authors = ["Author Name"]
  spec.summary = "Brief, clear summary"
  spec.description = "Detailed description"

  # Clear file selection
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{lib,context}/**/*", "README.md", "LICENSE"]
  end

  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.0.0"
end
```

### 3. Testing with Minitest

Write comprehensive tests for all gem functionality:

```ruby
# Good - Test structure
require "test_helper"

class Claude::Arsenal::GeneratorTest < Minitest::Test
  def setup
    @generator = Claude::Arsenal::Generators::Skill.new("test-skill", "domain")
  end

  def test_creates_skill_directory
    # Test implementation
  end

  def teardown
    # Cleanup
  end
end
```

### 4. Bake Task Organization

Organize tasks in logical groups with clear descriptions:

```ruby
# Good - tasks/claude/arsenal.rb
module Tasks
  module Claude
    module Arsenal
      def self.setup(context)
        context.task "install" do
          # Clear, focused task
        end
      end
    end
  end
end
```

## Patterns and Conventions

### Pattern 1: Version Management

**When to use:** Managing gem versions consistently

**Implementation:**
```ruby
# lib/claude/arsenal/version.rb
module Claude
  module Arsenal
    VERSION = "0.1.0"
  end
end

# In gemspec
spec.version = Claude::Arsenal::VERSION
```

### Pattern 2: CLI Entry Points

**When to use:** Creating command-line interfaces

**Implementation:**
```ruby
# lib/claude/arsenal/cli.rb
require 'samovar'

module Claude
  module Arsenal
    class CLI < Samovar::Command
      # Command implementation
    end
  end
end
```

**Resources:** See `resources/cli-patterns.md` for detailed examples

### Pattern 3: Template Rendering

**When to use:** Generating files from templates

**Implementation:**
```ruby
require 'erb'

template_path = File.join(__dir__, "templates", "skill.md.erb")
template = ERB.new(File.read(template_path))
content = template.result(binding)
```

**Resources:** See `resources/template-usage.md` for best practices

## Common Pitfalls

1. **File Path Handling**
   - Problem: Using relative paths that break in different contexts
   - Solution: Use `File.expand_path` and `__dir__` for reliable paths
   ```ruby
   # Good
   File.join(__dir__, "templates", "file.md.erb")

   # Bad
   "./templates/file.md.erb"
   ```

2. **Dependency Management**
   - Problem: Missing or overly broad dependency specifications
   - Solution: Specify exact version constraints
   ```ruby
   # Good
   spec.add_dependency "agent-context", "~> 1.0"

   # Bad
   spec.add_dependency "agent-context"
   ```

3. **Error Handling**
   - Problem: Letting exceptions bubble up without context
   - Solution: Wrap in meaningful error messages
   ```ruby
   # Good
   begin
     File.write(path, content)
   rescue => e
     raise "Failed to write skill file: #{e.message}"
   end
   ```

4. **File Generation Idempotency**
   - Problem: Overwriting user customizations
   - Solution: Check for existing files and prompt appropriately
   ```ruby
   # Good
   if File.exist?(path)
     puts "File exists. Overwrite? (y/n)"
     return unless gets.chomp.downcase == 'y'
   end
   ```

## Progressive Disclosure

For detailed information on specific topics, see the resources directory:

- `resources/cli-patterns.md` - Command-line interface best practices
- `resources/template-usage.md` - ERB template patterns
- `resources/testing-strategies.md` - Comprehensive testing approaches
- `resources/rbs-types.md` - Type signature conventions

## Checklist

Before completing gem development work:

- [ ] Module hierarchy follows gem conventions
- [ ] Gemspec is complete and accurate
- [ ] All new code has corresponding tests
- [ ] Tests pass with `rake test`
- [ ] RBS signatures validated with `rake rbs:validate`
- [ ] File paths use `__dir__` and `File.expand_path`
- [ ] Dependencies are properly specified
- [ ] Error handling provides meaningful messages
- [ ] Templates use proper variable binding
- [ ] Generated files respect existing user content

## Related Skills

- `generator-patterns` - For building file generators
- `test-coverage` - For ensuring comprehensive testing
- `documentation-writing` - For maintaining gem documentation

---

*This skill is part of Claude Arsenal. Keep under 500 lines for optimal loading.*
*Last updated: 2025-10-30*
