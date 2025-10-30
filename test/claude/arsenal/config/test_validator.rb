require "test_helper"
require "json"

module Claude
  module Arsenal
    module Config
      class TestValidator < Minitest::Test
        include TestHelpers

        def test_validate_all_returns_result
          validator = Validator.new
          result = validator.validate_all

          assert_kind_of Validator::ValidationResult, result
          assert_respond_to result, :valid?
          assert_respond_to result, :errors
          assert_respond_to result, :warnings
        end

        def test_valid_skill_rules
          create_skill_rules({
            "backend-dev" => {
              "type" => "domain",
              "enforcement" => "suggest",
              "priority" => "high"
            }
          })

          validator = Validator.new
          errors = validator.validate_skill_rules

          assert_empty errors
        end

        def test_invalid_skill_rules_missing_type
          create_skill_rules({
            "backend-dev" => {
              "enforcement" => "suggest",
              "priority" => "high"
            }
          })

          validator = Validator.new
          errors = validator.validate_skill_rules

          assert_includes errors.first, "missing 'type'"
        end

        def test_invalid_enforcement_level
          create_skill_rules({
            "backend-dev" => {
              "type" => "domain",
              "enforcement" => "invalid",
              "priority" => "high"
            }
          })

          validator = Validator.new
          errors = validator.validate_skill_rules

          assert_includes errors.first, "invalid enforcement level"
        end

        def test_invalid_priority
          create_skill_rules({
            "backend-dev" => {
              "type" => "domain",
              "enforcement" => "suggest",
              "priority" => "invalid"
            }
          })

          validator = Validator.new
          errors = validator.validate_skill_rules

          assert_includes errors.first, "invalid priority"
        end

        def test_validate_skills_missing_skill_file
          FileUtils.mkdir_p('.claude/skills/backend-dev')

          validator = Validator.new
          errors = validator.validate_skills

          assert_includes errors.first, "Missing SKILL.md"
        end

        def test_validate_skills_file_too_large
          FileUtils.mkdir_p('.claude/skills/backend-dev')

          # Create a file with > 500 lines
          File.write('.claude/skills/backend-dev/SKILL.md', "line\n" * 501)

          validator = Validator.new
          errors = validator.validate_skills

          assert_includes errors.first, "exceeds 500 lines"
        end

        def test_validate_hooks_invalid_extension
          FileUtils.mkdir_p('.claude/hooks')
          File.write('.claude/hooks/invalid.txt', 'content')

          validator = Validator.new
          errors = validator.validate_hooks

          assert_includes errors.first, "invalid extension"
        end

        def test_validate_agents_not_in_category
          FileUtils.mkdir_p('.claude/agents')
          File.write('.claude/agents/agent.md', 'content')

          validator = Validator.new
          errors = validator.validate_agents

          assert_includes errors.first, "should be in a category directory"
        end

        def test_validate_commands_not_markdown
          FileUtils.mkdir_p('.claude/commands')
          File.write('.claude/commands/command.txt', 'content')

          validator = Validator.new
          errors = validator.validate_commands

          assert_includes errors.first, "should be markdown"
        end

        private

        def create_skill_rules(rules)
          FileUtils.mkdir_p('.claude/config')
          File.write('.claude/config/skill-rules.json', JSON.pretty_generate(rules))
        end
      end
    end
  end
end
