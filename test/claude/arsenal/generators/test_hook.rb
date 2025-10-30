require "test_helper"

module Claude
  module Arsenal
    module Generators
      class TestHook < Minitest::Test
        include TestHelpers

        def test_initialize_with_valid_type
          hook = Hook.new(type: :user_prompt_submit, name: 'test-hook')
          assert_equal :user_prompt_submit, hook.type
          assert_equal 'test-hook', hook.name
          assert_equal '.claude/hooks', hook.output_dir
        end

        def test_initialize_with_string_type
          hook = Hook.new(type: 'post_tool_use', name: 'tracker')
          assert_equal :post_tool_use, hook.type
        end

        def test_initialize_with_custom_output_dir
          hook = Hook.new(type: :stop, name: 'checker', output_dir: 'custom/hooks')
          assert_equal 'custom/hooks', hook.output_dir
        end

        def test_initialize_with_invalid_type
          error = assert_raises(Claude::Arsenal::Error) do
            Hook.new(type: :invalid_type, name: 'test')
          end
          assert_match(/Invalid hook type/, error.message)
        end

        def test_generate_creates_hook_file
          hook = Hook.new(type: :user_prompt_submit, name: 'skill-activator')

          path = hook.generate

          assert File.exist?(path)
          assert_equal '.claude/hooks/skill-activator.ts', path

          content = File.read(path)
          assert_match(/export async function hook/, content)
          assert_match(/Skill Activator/, content)
        end

        def test_generate_creates_directory_if_missing
          hook = Hook.new(type: :stop, name: 'build-checker', output_dir: 'custom/path')

          refute Dir.exist?('custom/path')

          hook.generate

          assert Dir.exist?('custom/path')
        end

        def test_hook_types_constant
          assert_equal [:user_prompt_submit, :post_tool_use, :stop], Hook::HOOK_TYPES
        end
      end
    end
  end
end
