require "test_helper"
require "json"

module Claude
  module Arsenal
    module CLI
      class TestSetup < Minitest::Test
        include TestHelpers

        def test_creates_directory_structure
          setup_instance = Setup.new

          # Capture output
          out, _err = capture_io do
            setup_instance.run
          end

          assert_match(/setup complete/, out)

          # Check directories were created
          assert Dir.exist?('.claude/hooks')
          assert Dir.exist?('.claude/skills')
          assert Dir.exist?('.claude/agents/quality-control')
          assert Dir.exist?('.claude/agents/testing')
          assert Dir.exist?('.claude/agents/planning')
          assert Dir.exist?('.claude/agents/debugging')
          assert Dir.exist?('.claude/commands')
          assert Dir.exist?('.claude/config')
        end

        def test_creates_initial_config
          setup_instance = Setup.new

          capture_io { setup_instance.run }

          assert File.exist?('.claude/config/skill-rules.json')

          config = JSON.parse(File.read('.claude/config/skill-rules.json'))
          assert config['_meta']
          assert_equal '1.0', config['_meta']['version']
        end

        def test_does_not_create_gitignore
          setup_instance = Setup.new

          capture_io { setup_instance.run }

          # We don't auto-create .gitignore - users decide
          refute File.exist?('.claude/.gitignore')
        end

        def test_creates_dev_directories
          setup_instance = Setup.new

          capture_io { setup_instance.run }

          assert Dir.exist?('dev/active')
          assert Dir.exist?('dev/completed')
          assert File.exist?('dev/active/.gitkeep')
          assert File.exist?('dev/completed/.gitkeep')
        end

        def test_creates_context_directory
          setup_instance = Setup.new

          capture_io { setup_instance.run }

          assert Dir.exist?('context')
          assert File.exist?('context/index.yaml')
          assert File.exist?('context/architecture.md')
          assert File.exist?('context/conventions.md')
          assert File.exist?('context/getting-started.md')

          # Verify index.yaml has project name
          index_content = File.read('context/index.yaml')
          assert_match(/name:/, index_content)
        end

        def test_does_not_overwrite_existing_context_files
          FileUtils.mkdir_p('context')
          existing_content = "# My existing docs"
          File.write('context/architecture.md', existing_content)

          setup_instance = Setup.new
          capture_io { setup_instance.run }

          # Should not overwrite existing file
          content = File.read('context/architecture.md')
          assert_equal existing_content, content
        end

        def test_does_not_overwrite_existing_config
          FileUtils.mkdir_p('.claude/config')
          existing_config = { 'test' => 'value' }
          File.write('.claude/config/skill-rules.json', JSON.pretty_generate(existing_config))

          setup_instance = Setup.new
          capture_io { setup_instance.run }

          config = JSON.parse(File.read('.claude/config/skill-rules.json'))
          assert_equal 'value', config['test']
          refute config['_meta']
        end

        def test_with_custom_base_dir
          custom_dir = File.join(@tmp_dir, 'custom')
          FileUtils.mkdir_p(custom_dir)

          setup_instance = Setup.new(base_dir: custom_dir)
          capture_io { setup_instance.run }

          assert Dir.exist?(File.join(custom_dir, '.claude/hooks'))
          assert Dir.exist?(File.join(custom_dir, 'dev/active'))
        end
      end
    end
  end
end
