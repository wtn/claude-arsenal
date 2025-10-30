require 'fileutils'
require 'erb'
require 'json'

module Claude
  module Arsenal
    module Generators
      # Generator for Claude Code skills
      class Skill
        SKILL_TYPES = [:domain, :guidelines, :guardrail].freeze
        PRIORITIES = [:low, :medium, :high, :critical].freeze

        attr_reader :name, :type, :priority, :output_dir

        def initialize(name:, type:, priority: :medium, output_dir: '.claude/skills/local')
          @name = name
          @type = type.to_sym
          @priority = priority.to_sym
          @output_dir = output_dir

          validate_parameters!
        end

        def generate
          skill_dir = File.join(output_dir, name)
          FileUtils.mkdir_p(skill_dir)
          FileUtils.mkdir_p(File.join(skill_dir, 'resources'))

          # Generate main SKILL.md file
          skill_path = generate_skill_file(skill_dir)

          # Print reminder to manually update skill-rules.json
          print_skill_rules_reminder

          skill_path
        end

        private

        def validate_parameters!
          unless SKILL_TYPES.include?(type)
            raise Error, "Invalid skill type: #{type}. Must be one of: #{SKILL_TYPES.join(', ')}"
          end

          unless PRIORITIES.include?(priority)
            raise Error, "Invalid priority: #{priority}. Must be one of: #{PRIORITIES.join(', ')}"
          end
        end

        def generate_skill_file(skill_dir)
          template_path = File.join(template_dir, "#{type}.md.erb")
          content = render_template(template_path)

          skill_path = File.join(skill_dir, 'SKILL.md')
          File.write(skill_path, content)

          skill_path
        end

        def print_skill_rules_reminder
          puts "\nNext step: Add activation rules to .claude/config/skill-rules.json"
          puts "   Example:"
          puts "   {"
          puts "     \"#{name}\": {"
          puts "       \"type\": \"#{type}\","
          puts "       \"enforcement\": \"suggest\","
          puts "       \"priority\": \"#{priority}\","
          puts "       \"promptTriggers\": {"
          puts "         \"keywords\": [\"keyword1\", \"keyword2\"]"
          puts "       }"
          puts "     }"
          puts "   }"
          puts "\n   See context/configuration.md for full schema documentation\n\n"
        end

        def template_dir
          File.expand_path('../templates/skills', __dir__)
        end

        def render_template(template_path)
          template = File.read(template_path)
          ERB.new(template).result(binding)
        end
      end
    end
  end
end
