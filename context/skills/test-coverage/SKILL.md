---
type: guardrail
enforcement: require
priority: critical
keywords: [test, testing, minitest, spec, coverage, test case]
intentPatterns:
  - "(write|create|add|update).*?test"
  - "(add|implement).*?(feature|functionality|method)"
  - "(modify|change|update).*?(class|module|generator)"
pathPatterns:
  - "lib/**/*.rb"
  - "test/**/*_test.rb"
contentPatterns:
  - "class.*< Minitest::Test"
  - "def test_"
  - "assert"
  - "refute"
---

# Test Coverage Guardrail

## Purpose

This guardrail skill ensures comprehensive test coverage for all new code in Claude Arsenal, following Minitest conventions and best practices.

## When to Apply This Guardrail

This guardrail activates when:
- Adding new functionality to lib/
- Modifying existing generator classes
- Creating new CLI commands
- Updating configuration validators
- Changing file operations

## Required Checks

Before completing any code changes:

- [ ] All new public methods have corresponding tests
- [ ] Tests cover happy path scenarios
- [ ] Tests cover error/edge cases
- [ ] Tests verify file operations (creation, modification)
- [ ] Tests include proper setup and teardown
- [ ] All tests pass with `rake test`
- [ ] Test names clearly describe what they verify
- [ ] Fixtures/test data are properly isolated

## Testing Principles

### 1. Test Every Public Interface

All public methods must have tests:

**Example:**
```ruby
# lib/claude/arsenal/generators/skill.rb
class Skill
  def generate
    create_directory
    write_file
  end

  def create_directory
    FileUtils.mkdir_p(path)
  end
end

# test/claude/arsenal/generators/skill_test.rb
class SkillTest < Minitest::Test
  def test_generate_creates_directory
    generator = Skill.new("test-skill", "domain")
    generator.generate

    assert File.directory?(".claude/skills/local/test-skill")
  end

  def test_generate_writes_file
    generator = Skill.new("test-skill", "domain")
    generator.generate

    assert File.exist?(".claude/skills/local/test-skill/SKILL.md")
  end
end
```

### 2. Test Both Success and Failure

Cover happy path AND edge cases:

**Example:**
```ruby
# Happy path
def test_creates_skill_with_valid_input
  generator = Skill.new("valid-name", "domain")
  assert generator.generate
end

# Edge cases
def test_raises_error_with_empty_name
  assert_raises(ArgumentError) do
    Skill.new("", "domain")
  end
end

def test_raises_error_with_invalid_type
  assert_raises(ArgumentError) do
    Skill.new("test", "invalid-type")
  end
end

def test_handles_existing_directory
  # Create directory first
  FileUtils.mkdir_p(".claude/skills/local/existing")

  generator = Skill.new("existing", "domain")
  # Should handle gracefully, not crash
  assert generator.generate
end
```

### 3. Isolate Test Data

Use proper setup and teardown:

**Example:**
```ruby
class GeneratorTest < Minitest::Test
  def setup
    @test_dir = File.join(Dir.pwd, "tmp", "test_#{Time.now.to_i}")
    FileUtils.mkdir_p(@test_dir)
    @original_dir = Dir.pwd
    Dir.chdir(@test_dir)
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@test_dir) if File.exist?(@test_dir)
  end

  def test_generator_creates_files
    # Test runs in isolated @test_dir
    generator = Skill.new("test-skill", "domain")
    generator.generate

    assert File.exist?(".claude/skills/local/test-skill/SKILL.md")
  end
end
```

### 4. Clear, Descriptive Test Names

Test names should describe behavior:

**Good:**
```ruby
def test_creates_directory_structure_with_resources_folder
def test_raises_argument_error_when_name_is_empty
def test_overwrites_existing_file_when_confirmed
def test_skips_generation_when_user_declines_overwrite
```

**Bad:**
```ruby
def test_skill_1
def test_creation
def test_error
def test_directory
```

## Test Structure Pattern

### Standard Minitest Structure

```ruby
require "test_helper"

class Claude::Arsenal::ComponentTest < Minitest::Test
  def setup
    # Prepare test environment
    @subject = Component.new(args)
  end

  def test_specific_behavior
    # Arrange
    input = prepare_input

    # Act
    result = @subject.method(input)

    # Assert
    assert_equal expected, result
  end

  def teardown
    # Clean up test artifacts
  end
end
```

### File Operation Tests

```ruby
def test_creates_file_with_correct_content
  generator = Skill.new("test-skill", "domain")
  generator.generate

  path = ".claude/skills/local/test-skill/SKILL.md"

  assert File.exist?(path), "File should exist"

  content = File.read(path)
  assert_includes content, "# Test Skill"
  assert_includes content, "## Purpose"
end

def test_creates_nested_directory_structure
  generator = Skill.new("test-skill", "domain")
  generator.generate

  assert File.directory?(".claude/skills/test-skill")
  assert File.directory?(".claude/skills/local/test-skill/resources")
end
```

### Configuration Tests

```ruby
def test_validates_skill_rules_json
  validator = Validator.new
  config = {
    "skill-name" => {
      "type" => "domain",
      "enforcement" => "suggest"
    }
  }

  result = validator.validate(config)
  assert result.valid?
end

def test_rejects_invalid_enforcement_level
  validator = Validator.new
  config = {
    "skill-name" => {
      "type" => "domain",
      "enforcement" => "invalid"
    }
  }

  result = validator.validate(config)
  refute result.valid?
  assert_includes result.errors, /invalid enforcement/i
end
```

## Common Testing Pitfalls

### 1. No Cleanup

**Problem:** Tests leave artifacts that affect other tests

**Solution:**
```ruby
# Good
def teardown
  FileUtils.rm_rf(@test_dir) if @test_dir && File.exist?(@test_dir)
end

# Bad
# No teardown, files accumulate
```

### 2. Testing Implementation, Not Behavior

**Problem:** Tests break when implementation changes

**Solution:**
```ruby
# Good - Test observable behavior
def test_generates_skill_file
  generator.generate
  assert File.exist?(".claude/skills/local/test/SKILL.md")
end

# Bad - Test internal implementation
def test_calls_create_directory_method
  generator.expects(:create_directory).once
  generator.generate
end
```

### 3. Dependent Tests

**Problem:** Tests must run in specific order

**Solution:**
```ruby
# Good - Each test is independent
def test_creates_directory
  generator.generate
  assert File.directory?(path)
end

def test_creates_file
  generator.generate
  assert File.exist?(file_path)
end

# Bad - test_creates_file depends on test_creates_directory
```

### 4. Missing Edge Cases

**Problem:** Only happy path tested

**Solution:**
```ruby
# Good - Cover edge cases
def test_with_empty_string
def test_with_nil_value
def test_with_special_characters
def test_with_very_long_input
def test_with_existing_file

# Bad - Only one test
def test_creates_skill
```

## Required Test Coverage

### Generators
- [ ] Directory creation
- [ ] File writing
- [ ] Template rendering
- [ ] Overwrite handling
- [ ] Invalid input handling
- [ ] Cleanup on failure

### CLI Commands
- [ ] Successful execution
- [ ] Help text display
- [ ] Invalid argument handling
- [ ] Required argument validation
- [ ] Output messages

### Validators
- [ ] Valid input acceptance
- [ ] Invalid input rejection
- [ ] Error message clarity
- [ ] Edge cases (empty, nil, malformed)

### Configuration
- [ ] JSON parsing
- [ ] Schema validation
- [ ] Default value handling
- [ ] Missing field detection

## Running Tests

### Run All Tests
```bash
rake test
```

### Run Specific Test File
```bash
ruby test/claude/arsenal/generators/skill_test.rb
```

### Run Specific Test
```bash
ruby test/claude/arsenal/generators/skill_test.rb -n test_creates_directory
```

### Verbose Output
```bash
rake test TESTOPTS="-v"
```

## Assertion Reference

### Common Assertions
```ruby
assert condition, "message"
refute condition, "message"
assert_equal expected, actual
refute_equal expected, actual
assert_nil value
refute_nil value
assert_includes collection, item
assert_raises(ExceptionClass) { code }
assert_match /pattern/, string
```

### File Assertions
```ruby
assert File.exist?(path)
assert File.directory?(path)
assert File.file?(path)
assert_equal expected_content, File.read(path)
```

## Enforcement Level: REQUIRE

 **This is a required guardrail**

When activated, you MUST:
1. Write tests for all new code
2. Ensure all tests pass before completing
3. Cover both success and failure cases
4. Include proper setup/teardown
5. Use descriptive test names

**Do not proceed with code changes without tests.**

## Progressive Disclosure

For detailed testing strategies:

- `resources/minitest-patterns.md` - Advanced Minitest techniques
- `resources/fixture-management.md` - Test data organization
- `resources/mocking-stubbing.md` - Test doubles and mocks
- `resources/integration-tests.md` - Testing full workflows

## Related Skills

- `ruby-gem-development` - For overall gem testing strategy
- `generator-patterns` - For testing generated output

## Quick Test Template

```ruby
require "test_helper"

class Claude::Arsenal::NewFeatureTest < Minitest::Test
  def setup
    # Prepare test environment
  end

  def test_primary_behavior
    # Test main functionality
  end

  def test_error_handling
    # Test failure cases
  end

  def teardown
    # Clean up
  end
end
```

---

*This skill is part of Claude Arsenal. Keep under 500 lines for optimal loading.*
*Last updated: 2025-10-30*
*Enforcement: REQUIRE*
