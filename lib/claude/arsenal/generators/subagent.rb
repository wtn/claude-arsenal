require 'fileutils'
require 'erb'

module Claude
  module Arsenal
    module Generators
      # Generator for Claude Code subagents
      class Subagent
        CATEGORIES = [:quality_control, :testing, :planning, :debugging].freeze

        attr_reader :name, :category, :output_dir

        def initialize(name:, category:, output_dir: '.claude/agents')
          @name = name
          @category = category.to_sym
          @output_dir = output_dir

          validate_category!
        end

        def generate
          category_dir = File.join(output_dir, category.to_s.gsub('_', '-'))
          FileUtils.mkdir_p(category_dir)

          template_path = find_template
          content = render_template(template_path)

          agent_path = File.join(category_dir, "#{name}.md")
          File.write(agent_path, content)

          agent_path
        end

        private

        def validate_category!
          unless CATEGORIES.include?(category)
            raise Error, "Invalid category: #{category}. Must be one of: #{CATEGORIES.join(', ')}"
          end
        end

        def find_template
          template_name = "#{name}.md.erb"
          template_path = File.join(template_dir, category.to_s, template_name)

          # Fall back to generic template if specific one doesn't exist
          unless File.exist?(template_path)
            template_path = File.join(template_dir, 'generic.md.erb')
          end

          template_path
        end

        def template_dir
          File.expand_path('../templates/agents', __dir__)
        end

        def render_template(template_path)
          template = File.read(template_path)
          ERB.new(template).result(binding)
        end
      end
    end
  end
end
