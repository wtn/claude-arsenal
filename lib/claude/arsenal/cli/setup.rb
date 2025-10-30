require 'fileutils'
require 'json'
require 'erb'

module Claude
  module Arsenal
    module CLI
      # Handles initial setup of .claude directory structure
      class Setup
        attr_reader :base_dir

        def initialize(base_dir: '.')
          @base_dir = base_dir
        end

        def run
          create_directory_structure
          create_initial_config
          create_gitignore
          create_dev_directories
          create_context_directory

          puts "Claude Arsenal setup complete!"
          puts "\nCreated directory structure:"
          puts "  .claude/hooks/       - Hook scripts"
          puts "  .claude/skills/      - Skill definitions"
          puts "  .claude/agents/      - Subagent configurations"
          puts "  .claude/commands/    - Slash commands"
          puts "  .claude/config/      - Configuration files"
          puts "  context/             - Project documentation (agent-context)"
          puts "  dev/active/          - Active development docs"
          puts "  dev/completed/       - Completed development docs"
          puts "\nNext steps:"
          puts "  1. Fill in context/ documentation templates"
          puts "  2. Generate hooks: bake claude:arsenal:hook_generate user-prompt-submit"
          puts "  3. Create skills: bake claude:arsenal:skill_create backend-dev domain"
          puts "  4. Add subagents: bake claude:arsenal:agent_create code-reviewer quality-control"
        end

        private

        def create_directory_structure
          directories = [
            '.claude/hooks',
            '.claude/skills',
            '.claude/agents/quality-control',
            '.claude/agents/testing',
            '.claude/agents/planning',
            '.claude/agents/debugging',
            '.claude/commands',
            '.claude/config'
          ]

          directories.each do |dir|
            path = File.join(base_dir, dir)
            FileUtils.mkdir_p(path)
            puts "Created: #{dir}"
          end
        end

        def create_initial_config
          config_path = File.join(base_dir, '.claude/config/skill-rules.json')

          return if File.exist?(config_path)

          initial_config = {
            "_meta" => {
              "version" => "1.0",
              "description" => "Skill activation rules for Claude Code"
            }
          }

          File.write(config_path, JSON.pretty_generate(initial_config))
          puts "Created: .claude/config/skill-rules.json"
        end

        def create_gitignore
          # Don't create any .gitignore files - let users decide
          # See documentation for recommendations
        end

        def create_dev_directories
          directories = [
            'dev/active',
            'dev/completed'
          ]

          directories.each do |dir|
            path = File.join(base_dir, dir)
            FileUtils.mkdir_p(path)

            # Add .gitkeep to ensure directories are tracked
            gitkeep = File.join(path, '.gitkeep')
            FileUtils.touch(gitkeep)

            puts "Created: #{dir}"
          end
        end

        def create_context_directory
          context_dir = File.join(base_dir, 'context')
          FileUtils.mkdir_p(context_dir)

          # Create context files from templates
          context_files = %w[index.yaml architecture.md conventions.md getting-started.md]

          # Project name used by ERB templates (accessed via binding)
          project_name = detect_project_name

          context_files.each do |filename|
            template_path = File.expand_path("../templates/context/#{filename}.erb", __dir__)
            output_path = File.join(context_dir, filename)

            next if File.exist?(output_path) # Don't overwrite existing files

            if File.exist?(template_path)
              template = ERB.new(File.read(template_path))
              content = template.result(binding)
              File.write(output_path, content)
              puts "Created: context/#{filename}"
            end
          end

          project_name  # Used via binding in ERB templates
        end

        # Detect project name from gemspec (if Ruby gem) or directory name
        def detect_project_name
          expanded_path = File.expand_path(base_dir)

          # Look for .gemspec file
          gemspec_files = Dir.glob(File.join(expanded_path, '*.gemspec'))

          if gemspec_files.any?
            begin
              # Load the gemspec and extract name
              spec = Gem::Specification.load(gemspec_files.first)
              return spec.name if spec&.name
            rescue StandardError
              # Fall through to directory name if gemspec parsing fails
            end
          end

          # Fall back to directory name
          File.basename(expanded_path)
        end
      end
    end
  end
end
