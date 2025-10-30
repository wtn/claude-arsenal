require 'fileutils'
require 'erb'

module Claude
  module Arsenal
    module Generators
      # Generator for Claude Code hooks
      class Hook
        HOOK_TYPES = [:user_prompt_submit, :post_tool_use, :stop].freeze

        attr_reader :type, :name, :output_dir

        def initialize(type:, name:, output_dir: '.claude/hooks')
          @type = type.to_sym
          @name = name
          @output_dir = output_dir

          validate_type!
        end

        def generate
          FileUtils.mkdir_p(output_dir)

          template_path = find_template
          content = render_template(template_path)

          output_path = File.join(output_dir, "#{name}.ts")
          File.write(output_path, content)

          output_path
        end

        private

        def validate_type!
          unless HOOK_TYPES.include?(type)
            raise Error, "Invalid hook type: #{type}. Must be one of: #{HOOK_TYPES.join(', ')}"
          end
        end

        def find_template
          template_name = case type
          when :user_prompt_submit
            'skill-activator.ts.erb'
          when :post_tool_use
            'file-edit-tracker.ts.erb'
          when :stop
            'build-checker.ts.erb'
          end

          File.join(template_dir, template_name)
        end

        def template_dir
          File.expand_path('../templates/hooks', __dir__)
        end

        def render_template(template_path)
          template = File.read(template_path)
          ERB.new(template).result(binding)
        end
      end
    end
  end
end
