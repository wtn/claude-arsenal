require 'fileutils'
require 'erb'

module Claude
  module Arsenal
    module Generators
      # Generator for Claude Code slash commands
      class SlashCommand
        attr_reader :name, :description, :output_dir

        def initialize(name:, description: nil, output_dir: '.claude/commands')
          @name = name
          @description = description
          @output_dir = output_dir
        end

        def generate
          FileUtils.mkdir_p(output_dir)

          template_path = find_template
          content = render_template(template_path)

          command_path = File.join(output_dir, "#{name}.md")
          File.write(command_path, content)

          command_path
        end

        private

        def find_template
          template_name = "#{name}.md.erb"
          template_path = File.join(template_dir, template_name)

          # Fall back to generic template if specific one doesn't exist
          unless File.exist?(template_path)
            template_path = File.join(template_dir, 'generic.md.erb')
          end

          template_path
        end

        def template_dir
          File.expand_path('../templates/commands', __dir__)
        end

        def render_template(template_path)
          template = File.read(template_path)
          ERB.new(template).result(binding)
        end
      end
    end
  end
end
