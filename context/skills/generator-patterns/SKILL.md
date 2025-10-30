---
type: domain
enforcement: suggest
priority: high
keywords: [generator, template, ERB, generate, scaffold, create file]
intentPatterns:
  - "(create|build|implement).*?(generator|template)"
  - "(render|generate).*?(file|template)"
  - "ERB.*?(template|rendering)"
pathPatterns:
  - "lib/claude/arsenal/generators/**/*.rb"
  - "lib/claude/arsenal/templates/**/*.erb"
  - "lib/**/generators/**/*.rb"
  - "lib/**/templates/**/*.erb"
contentPatterns:
  - "class.*Generator"
  - "ERB\\.new"
  - "template\\.result"
  - "def generate"
---

# Generator Patterns Skill

## Purpose

This skill provides patterns and best practices for building file generators in Claude Arsenal, focusing on ERB templates, directory creation, and user-friendly generation workflows.

## When to Use This Skill

Use this skill when:
- Creating new generator classes
- Working with ERB templates
- Building file scaffolding systems
- Generating skill, hook, or agent files
- Designing user-facing generation commands

## Core Principles

### 1. Template Organization

Keep templates organized by type with clear naming:

**Example:**
```
lib/claude/arsenal/templates/
 skills/
‚    domain.md.erb
‚    guidelines.md.erb
‚    guardrail.md.erb
 hooks/
‚    user_prompt_submit.ts.erb
‚    post_tool_use.ts.erb
 agents/
     quality-control.md.erb
```

**Best Practice:** One template file per type, use ERB for variable substitution.

### 2. Generator Class Structure

Follow a consistent pattern for all generators:

```ruby
module Claude
  module Arsenal
    module Generators
      class Skill
        attr_reader :name, :type, :options

        def initialize(name, type, options = {})
          @name = name
          @type = type
          @options = options
        end

        def generate
          create_directory
          render_template
          update_config
          show_completion_message
        end

        private

        def create_directory
          # Directory creation logic
        end

        def render_template
          # Template rendering logic
        end
      end
    end
  end
end
```

### 3. Idempotency and User Respect

Always check for existing files and respect user content:

```ruby
# Good - Check before overwriting
def generate
  if File.exist?(target_path)
    puts "  File already exists: #{target_path}"
    puts "Overwrite? (y/n)"
    return unless $stdin.gets.chomp.downcase == 'y'
  end

  File.write(target_path, rendered_content)
  puts " Created #{target_path}"
end

# Bad - Always overwrite
def generate
  File.write(target_path, rendered_content)
end
```

### 4. Progressive Enhancement

Generate minimal starting points that users can expand:

```ruby
# Good - Minimal template with clear extension points
# <%= name %> Skill

## Purpose
[Add your purpose here]

## Core Principles
### 1. [Add principle]
[Description]

# Bad - Overly prescriptive template
# Don't pre-fill with assumptions
```

## Patterns and Conventions

### Pattern 1: ERB Template Rendering

**When to use:** Generating files with variable content

**Implementation:**
```ruby
require 'erb'

def render_template
  template_path = File.join(__dir__, "templates", "#{type}.md.erb")
  template = ERB.new(File.read(template_path), trim_mode: '-')

  # Variables available in template via binding
  name = @name
  type = @type
  timestamp = Time.now.strftime('%Y-%m-%d')

  template.result(binding)
end
```

**Key Points:**
- Use `binding` to pass local variables to templates
- Set `trim_mode: '-'` for cleaner whitespace handling
- Keep template logic minimal

**Resources:** See `resources/erb-advanced.md` for complex scenarios

### Pattern 2: Directory Creation with Safety

**When to use:** Creating nested directory structures

**Implementation:**
```ruby
require 'fileutils'

def create_directory_structure
  base_path = ".claude/skills/#{name}"
  resources_path = File.join(base_path, "resources")

  FileUtils.mkdir_p(resources_path)
  puts " Created directory structure"
rescue => e
  raise "Failed to create directories: #{e.message}"
end
```

**Key Points:**
- Use `FileUtils.mkdir_p` for creating parent directories
- Provide clear error messages
- Return created paths for chaining

### Pattern 3: File Path Construction

**When to use:** Building paths for generated files

**Implementation:**
```ruby
# Good - Consistent path construction
def target_path
  File.join(
    Dir.pwd,
    ".claude",
    component_type,  # "skills", "hooks", etc.
    name,
    "#{filename_prefix}.md"
  )
end

# Normalize name for file system
def normalized_name
  name.downcase.gsub(/[^a-z0-9]+/, '-')
end

# Bad - String concatenation
def target_path
  "#{Dir.pwd}/.claude/#{component_type}/#{name}/file.md"
end
```

### Pattern 4: User Feedback

**When to use:** Providing clear generation status

**Implementation:**
```ruby
def generate
  puts "\n¨ Generating #{type} skill: #{name}"

  create_directory
  puts "   Created directory structure"

  render_and_write_main_file
  puts "   Created SKILL.md"

  create_resources_directory
  puts "   Created resources directory"

  puts "\n Skill generated successfully!"
  puts "    Edit: .claude/skills/#{name}/SKILL.md"
  puts "    Add resources: .claude/skills/#{name}/resources/"
  puts "\n Next step: Update .claude/config/skill-rules.json"
end
```

**Key Points:**
- Use emojis sparingly for visual distinction
- Show progress for multi-step operations
- Provide next steps after completion
- Include file paths for quick access

## Common Pitfalls

1. **Template Variable Scope**
   - Problem: Variables not accessible in template
   - Solution: Define variables in method scope before `binding`
   ```ruby
   # Good
   def render
     name = @name
     type = @type
     ERB.new(template).result(binding)
   end

   # Bad
   def render
     ERB.new(template).result(binding) # @name not accessible
   end
   ```

2. **Path Separator Issues**
   - Problem: Hard-coded `/` fails on Windows
   - Solution: Always use `File.join`
   ```ruby
   # Good
   File.join(".claude", "skills", name)

   # Bad
   ".claude/skills/#{name}"
   ```

3. **Missing Directory Creation**
   - Problem: Writing to non-existent directories
   - Solution: Use `FileUtils.mkdir_p` before writing
   ```ruby
   # Good
   FileUtils.mkdir_p(File.dirname(path))
   File.write(path, content)

   # Bad
   File.write(path, content) # May fail if directory doesn't exist
   ```

4. **Silent Overwrites**
   - Problem: Destroying user customizations
   - Solution: Always prompt before overwriting
   ```ruby
   # Good - Check and prompt
   if File.exist?(path)
     return unless confirm_overwrite?
   end

   # Bad - Silent overwrite
   File.write(path, content)
   ```

5. **Template Complexity**
   - Problem: Business logic in ERB templates
   - Solution: Keep templates simple, logic in generator class
   ```ruby
   # Good - Logic in class
   def formatted_date
     Time.now.strftime('%Y-%m-%d')
   end

   # Template: <%= formatted_date %>

   # Bad - Logic in template
   # Template: <%= Time.now.strftime('%Y-%m-%d') %>
   ```

## Generator Checklist

Before completing generator work:

- [ ] Template variables are defined in method scope
- [ ] File paths use `File.join` for cross-platform compatibility
- [ ] Directories created with `FileUtils.mkdir_p` before writing files
- [ ] Existing files are detected with overwrite confirmation
- [ ] User feedback shows progress for multi-step operations
- [ ] Error messages are clear and actionable
- [ ] Templates use minimal logic (prefer helper methods)
- [ ] Generated file paths are displayed to user
- [ ] Next steps are communicated after generation
- [ ] Tests verify directory structure and file content

## Progressive Disclosure

For detailed information on specific topics:

- `resources/erb-advanced.md` - Complex ERB patterns and helpers
- `resources/file-operations.md` - Advanced file handling
- `resources/user-interaction.md` - CLI prompts and confirmations
- `resources/testing-generators.md` - Testing generated files

## Related Skills

- `ruby-gem-development` - For overall gem structure
- `test-coverage` - For testing generated output
- `cli-design` - For user-facing command patterns

## Quick Reference

### Standard Generator Flow
```ruby
def generate
  validate_inputs
  create_directory_structure
  render_and_write_files
  update_configuration_files
  show_completion_message
end
```

### ERB Template Structure
```erb
# <%= name.split('-').map(&:capitalize).join(' ') %>

## Purpose
<%= description %>

## Created
<%= Time.now.strftime('%Y-%m-%d') %>
```

### File Writing Pattern
```ruby
FileUtils.mkdir_p(File.dirname(path))
File.write(path, content)
```

---

*This skill is part of Claude Arsenal. Keep under 500 lines for optimal loading.*
*Last updated: 2025-10-30*
