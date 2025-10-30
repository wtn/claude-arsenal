require "test_helper"

module Claude
  module Arsenal
    module CLI
      class TestGitignoreManager < Minitest::Test
        include TestHelpers

        def test_adds_entries
          manager = GitignoreManager.new

          capture_io do
            manager.add_entries
          end

          assert File.exist?('.gitignore')
          content = File.read('.gitignore')

          assert_match(/# Added by claude-arsenal/, content)
          assert_match(/^\/\.context\/$/, content)
          assert_match(/^\/\.claude\/tmp\/$/, content)
          assert_match(/^\/\.claude\/skills\/gems\/$/, content)
          assert_match(/^\/dev\/active\/$/, content)
        end

        def test_updates_existing_section
          # Create initial .gitignore with claude-arsenal section
          initial_content = <<~GITIGNORE
            # Some other entries
            *.log

            # Added by claude-arsenal
            .context/
            .claude/

            # More entries
            node_modules/
          GITIGNORE

          File.write('.gitignore', initial_content)

          manager = GitignoreManager.new

          capture_io do
            manager.add_entries
          end

          content = File.read('.gitignore')

          # Should still have the marker
          assert_match(/# Added by claude-arsenal/, content)

          # Should have updated entries with leading slashes
          assert_match(/^\/\.claude\/tmp\/$/, content)
          assert_match(/^\/dev\/active\/$/, content)

          # Should preserve other entries
          assert_match(/\*\.log/, content)
          assert_match(/node_modules\//, content)

          # Should only have one claude-arsenal section
          assert_equal 1, content.scan(/# Added by claude-arsenal/).length
        end

        def test_appends_to_existing_gitignore
          # Create a .gitignore without claude-arsenal section
          initial_content = <<~GITIGNORE
            # Project specific
            *.log
            node_modules/
          GITIGNORE

          File.write('.gitignore', initial_content)

          manager = GitignoreManager.new

          capture_io do
            manager.add_entries
          end

          content = File.read('.gitignore')

          # Should preserve original content
          assert_match(/\*\.log/, content)
          assert_match(/node_modules\//, content)

          # Should add new section with leading slashes
          assert_match(/# Added by claude-arsenal/, content)
          assert_match(/^\/\.context\/$/, content)
        end

        def test_creates_gitignore_if_missing
          refute File.exist?('.gitignore')

          manager = GitignoreManager.new

          capture_io do
            manager.add_entries
          end

          assert File.exist?('.gitignore')
          content = File.read('.gitignore')

          assert_match(/# Added by claude-arsenal/, content)
        end

        def test_with_custom_base_dir
          custom_dir = File.join(@tmp_dir, 'custom')
          FileUtils.mkdir_p(custom_dir)

          manager = GitignoreManager.new(base_dir: custom_dir)

          capture_io do
            manager.add_entries
          end

          gitignore_path = File.join(custom_dir, '.gitignore')
          assert File.exist?(gitignore_path)

          content = File.read(gitignore_path)
          assert_match(/# Added by claude-arsenal/, content)
        end
      end
    end
  end
end
