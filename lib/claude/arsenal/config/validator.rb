require 'json'

module Claude
  module Arsenal
    module Config
      # Validates Claude Arsenal configurations
      class Validator
        ValidationResult = Struct.new(:valid?, :errors, :warnings) do
          def initialize(valid: true, errors: [], warnings: [])
            super(valid, errors, warnings)
          end
        end

        attr_reader :base_dir

        def initialize(base_dir: '.')
          @base_dir = base_dir
        end

        def validate_all
          errors = []
          warnings = []

          errors.concat(validate_skill_rules)
          errors.concat(validate_skills)
          errors.concat(validate_hooks)
          errors.concat(validate_agents)
          errors.concat(validate_commands)

          ValidationResult.new(
            valid: errors.empty?,
            errors: errors,
            warnings: warnings
          )
        end

        def validate_skill_rules
          errors = []
          rules_path = File.join(base_dir, '.claude/config/skill-rules.json')

          return errors unless File.exist?(rules_path)

          begin
            rules = JSON.parse(File.read(rules_path))

            rules.each do |skill_name, config|
              errors << "Skill '#{skill_name}': missing 'type'" unless config['type']
              errors << "Skill '#{skill_name}': invalid enforcement level" unless valid_enforcement?(config['enforcement'])
              errors << "Skill '#{skill_name}': invalid priority" unless valid_priority?(config['priority'])
            end
          rescue JSON::ParserError => e
            errors << "Invalid JSON in skill-rules.json: #{e.message}"
          end

          errors
        end

        def validate_skills
          errors = []
          skills_dir = File.join(base_dir, '.claude/skills')

          return errors unless Dir.exist?(skills_dir)

          Dir.glob(File.join(skills_dir, '*')).each do |skill_dir|
            next unless File.directory?(skill_dir)

            skill_file = File.join(skill_dir, 'SKILL.md')
            unless File.exist?(skill_file)
              errors << "Missing SKILL.md in #{File.basename(skill_dir)}"
              next
            end

            # Check file size (should be < 500 lines as per best practices)
            line_count = File.readlines(skill_file).count
            if line_count > 500
              errors << "#{File.basename(skill_dir)}/SKILL.md exceeds 500 lines (#{line_count} lines)"
            end
          end

          errors
        end

        def validate_hooks
          errors = []
          hooks_dir = File.join(base_dir, '.claude/hooks')

          return errors unless Dir.exist?(hooks_dir)

          # Validate that hook files exist and have .ts or .js extension
          Dir.glob(File.join(hooks_dir, '*')).each do |hook_file|
            next if File.directory?(hook_file)

            unless hook_file.end_with?('.ts', '.js')
              errors << "Hook file has invalid extension: #{File.basename(hook_file)}"
            end
          end

          errors
        end

        def validate_agents
          errors = []
          agents_dir = File.join(base_dir, '.claude/agents')

          return errors unless Dir.exist?(agents_dir)

          # Ensure agents are organized in category directories
          Dir.glob(File.join(agents_dir, '*')).each do |path|
            if File.file?(path)
              errors << "Agent file should be in a category directory: #{File.basename(path)}"
            end
          end

          errors
        end

        def validate_commands
          errors = []
          commands_dir = File.join(base_dir, '.claude/commands')

          return errors unless Dir.exist?(commands_dir)

          # Validate that command files are markdown
          Dir.glob(File.join(commands_dir, '*')).each do |command_file|
            next if File.directory?(command_file)

            unless command_file.end_with?('.md')
              errors << "Command file should be markdown: #{File.basename(command_file)}"
            end
          end

          errors
        end

        private

        def valid_enforcement?(enforcement)
          %w[suggest require block].include?(enforcement)
        end

        def valid_priority?(priority)
          %w[low medium high critical].include?(priority)
        end
      end
    end
  end
end
