require "test_helper"

module Claude
  module Arsenal
    module Generators
      class TestSubagent < Minitest::Test
        include TestHelpers

        def test_initialize_with_valid_category
          agent = Subagent.new(name: 'code-reviewer', category: :quality_control)
          assert_equal 'code-reviewer', agent.name
          assert_equal :quality_control, agent.category
          assert_equal '.claude/agents', agent.output_dir
        end

        def test_initialize_with_string_category
          agent = Subagent.new(name: 'test', category: 'testing')
          assert_equal :testing, agent.category
        end

        def test_initialize_with_invalid_category
          error = assert_raises(Claude::Arsenal::Error) do
            Subagent.new(name: 'test', category: :invalid)
          end
          assert_match(/Invalid category/, error.message)
        end

        def test_generate_creates_agent_file
          agent = Subagent.new(name: 'test-agent', category: :planning)

          path = agent.generate

          assert File.exist?(path)
          assert_equal '.claude/agents/planning/test-agent.md', path

          content = File.read(path)
          assert_match(/Test Agent Agent/, content)
          assert_match(/Role/, content)
        end

        def test_generate_creates_category_directory
          agent = Subagent.new(name: 'debugger', category: :debugging)

          refute Dir.exist?('.claude/agents/debugging')

          agent.generate

          assert Dir.exist?('.claude/agents/debugging')
        end

        def test_categories_constant
          assert_equal [:quality_control, :testing, :planning, :debugging], Subagent::CATEGORIES
        end

        def test_category_name_converted_to_kebab_case
          agent = Subagent.new(name: 'test', category: :quality_control)
          path = agent.generate

          assert_match(/quality-control/, path)
        end
      end
    end
  end
end
