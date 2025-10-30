require "test_helper"

module Claude
  module Arsenal
    module Generators
      class TestSkill < Minitest::Test
        include TestHelpers

        def test_initialize_with_valid_parameters
          skill = Skill.new(name: 'backend-dev', type: :domain)
          assert_equal 'backend-dev', skill.name
          assert_equal :domain, skill.type
          assert_equal :medium, skill.priority
          assert_equal '.claude/skills/local', skill.output_dir
        end

        def test_initialize_with_string_type
          skill = Skill.new(name: 'test', type: 'guidelines', priority: 'high')
          assert_equal :guidelines, skill.type
          assert_equal :high, skill.priority
        end

        def test_initialize_with_invalid_type
          error = assert_raises(Claude::Arsenal::Error) do
            Skill.new(name: 'test', type: :invalid)
          end
          assert_match(/Invalid skill type/, error.message)
        end

        def test_initialize_with_invalid_priority
          error = assert_raises(Claude::Arsenal::Error) do
            Skill.new(name: 'test', type: :domain, priority: :invalid)
          end
          assert_match(/Invalid priority/, error.message)
        end

        def test_generate_creates_skill_directory
          skill = Skill.new(name: 'test-skill', type: :domain)

          path = skill.generate

          assert Dir.exist?('.claude/skills/local/test-skill')
          assert Dir.exist?('.claude/skills/local/test-skill/resources')
          assert File.exist?(path)
          assert_equal '.claude/skills/local/test-skill/SKILL.md', path
        end

        def test_generate_creates_skill_file_with_content
          skill = Skill.new(name: 'backend-dev', type: :domain, priority: :high)

          path = skill.generate
          content = File.read(path)

          assert_match(/Backend Dev Skill/, content)
          assert_match(/Purpose/, content)
          assert_match(/Progressive Disclosure/, content)
        end

        def test_skill_types_constant
          assert_equal [:domain, :guidelines, :guardrail], Skill::SKILL_TYPES
        end

        def test_priorities_constant
          assert_equal [:low, :medium, :high, :critical], Skill::PRIORITIES
        end
      end
    end
  end
end
