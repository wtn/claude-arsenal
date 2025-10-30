require "test_helper"

module Claude
  module Arsenal
    module Generators
      class TestSlashCommand < Minitest::Test
        include TestHelpers

        def test_initialize_with_name
          cmd = SlashCommand.new(name: 'dev-docs')
          assert_equal 'dev-docs', cmd.name
          assert_nil cmd.description
          assert_equal '.claude/commands', cmd.output_dir
        end

        def test_initialize_with_description
          cmd = SlashCommand.new(name: 'test', description: 'Test command')
          assert_equal 'Test command', cmd.description
        end

        def test_initialize_with_custom_output_dir
          cmd = SlashCommand.new(name: 'test', output_dir: 'custom/commands')
          assert_equal 'custom/commands', cmd.output_dir
        end

        def test_generate_creates_command_file
          cmd = SlashCommand.new(name: 'test-command')

          path = cmd.generate

          assert File.exist?(path)
          assert_equal '.claude/commands/test-command.md', path

          content = File.read(path)
          assert_match(%r{/test-command}, content)
          assert_match(/Usage/, content)
        end

        def test_generate_creates_directory_if_missing
          cmd = SlashCommand.new(name: 'test', output_dir: 'custom/commands')

          refute Dir.exist?('custom/commands')

          cmd.generate

          assert Dir.exist?('custom/commands')
        end

        def test_generate_with_description
          cmd = SlashCommand.new(
            name: 'code-review',
            description: 'Review code architecture'
          )

          path = cmd.generate
          content = File.read(path)

          assert_match(/code-review/, content)
        end
      end
    end
  end
end
