require 'erb'
require 'fileutils'
require 'pathname'

module Claude
  module Arsenal
    module Generators
      class DevDocs
        def initialize(name, options = {})
          @name = name.to_s.downcase.gsub(/[^a-z0-9-]/, '-')
          @action = options[:action] || 'create'
          @timestamp = Time.now.strftime('%Y-%m-%d %H:%M')
          @quiet = options[:quiet] || false
        end

        def generate
          case @action
          when 'create'
            create_dev_docs
          when 'update'
            update_dev_docs
          else
            raise ArgumentError, "Unknown action: #{@action}"
          end
        end

        private

        def create_dev_docs
          validate_name

          # Create directory
          dev_dir = File.join('.', 'dev', 'active', @name)
          if File.exist?(dev_dir)
            raise "Dev docs directory already exists: #{dev_dir}"
          end

          FileUtils.mkdir_p(dev_dir)

          # Generate files
          generate_plan_file(dev_dir)
          generate_context_file(dev_dir)
          generate_tasks_file(dev_dir)

          unless @quiet
            puts "Created dev docs in #{dev_dir}/"
            puts "   #{@name}-plan.md"
            puts "   #{@name}-context.md"
            puts "   #{@name}-tasks.md"
            puts ""
            puts "Next steps:"
            puts "1. Fill in the plan with your strategic approach"
            puts "2. Update context as you work"
            puts "3. Check off tasks as completed"
          end
        end

        def update_dev_docs
          # Find active dev docs
          active_dir = File.join('.', 'dev', 'active')
          unless File.exist?(active_dir)
            puts "No active dev docs found" unless @quiet
            return
          end

          dirs = Dir.glob(File.join(active_dir, '*')).select { |f| File.directory?(f) }
          if dirs.empty?
            puts "No active dev docs found" unless @quiet
            return
          end

          dirs.each do |dir|
            update_timestamps(dir)
          end

          puts "Updated timestamps in #{dirs.length} dev docs" unless @quiet
        end

        def generate_plan_file(dir)
          template = plan_template
          content = ERB.new(template, trim_mode: '-').result(binding)

          file_path = File.join(dir, "#{@name}-plan.md")
          File.write(file_path, content)
        end

        def generate_context_file(dir)
          template = context_template
          content = ERB.new(template, trim_mode: '-').result(binding)

          file_path = File.join(dir, "#{@name}-context.md")
          File.write(file_path, content)
        end

        def generate_tasks_file(dir)
          template = tasks_template
          content = ERB.new(template, trim_mode: '-').result(binding)

          file_path = File.join(dir, "#{@name}-tasks.md")
          File.write(file_path, content)
        end

        def update_timestamps(dir)
          Dir.glob(File.join(dir, '*.md')).each do |file|
            content = File.read(file)
            updated = content.sub(/Last Updated: .*/, "Last Updated: #{@timestamp}")
            File.write(file, updated)
          end
        end

        def validate_name
          if @name.empty?
            raise ArgumentError, "Name cannot be empty"
          end

          if @name.length > 50
            raise ArgumentError, "Name too long (max 50 characters)"
          end
        end

        def template_dir
          File.expand_path('../templates', __dir__)
        end

        def plan_template
          template_path = File.join(template_dir, 'dev_docs', 'plan.md.erb')
          if File.exist?(template_path)
            File.read(template_path)
          else
            default_plan_template
          end
        end

        def context_template
          template_path = File.join(template_dir, 'dev_docs', 'context.md.erb')
          if File.exist?(template_path)
            File.read(template_path)
          else
            default_context_template
          end
        end

        def tasks_template
          template_path = File.join(template_dir, 'dev_docs', 'tasks.md.erb')
          if File.exist?(template_path)
            File.read(template_path)
          else
            default_tasks_template
          end
        end

        def default_plan_template
          <<~TEMPLATE
            # <%= @name.split('-').map(&:capitalize).join(' ') %> - Implementation Plan

            Last Updated: <%= @timestamp %>
            Status: Planning

            ## Executive Summary

            [Brief description of what this feature/task accomplishes]

            ## Goals

            1. [Primary goal]
            2. [Secondary goal]
            3. [Additional goals...]

            ## Approach

            ### Phase 1: Foundation
            [Initial setup and groundwork]

            ### Phase 2: Core Implementation
            [Main feature development]

            ### Phase 3: Integration
            [Connect with existing systems]

            ### Phase 4: Testing & Refinement
            [Validation and polish]

            ## Technical Design

            ### Architecture
            [High-level architecture decisions]

            ### Components
            - **Component A**: [Description]
            - **Component B**: [Description]

            ### Data Flow
            1. [Step 1]
            2. [Step 2]
            3. [Step 3]

            ## Dependencies

            - [External dependency 1]
            - [External dependency 2]

            ## Risks & Mitigations

            | Risk | Impact | Mitigation |
            |------|--------|------------|
            | [Risk 1] | Medium | [Strategy] |
            | [Risk 2] | Low | [Strategy] |

            ## Success Metrics

            - [ ] [Metric 1]
            - [ ] [Metric 2]
            - [ ] [Metric 3]

            ## Timeline Estimate

            - Phase 1: [Duration]
            - Phase 2: [Duration]
            - Phase 3: [Duration]
            - Phase 4: [Duration]

            **Total: [Estimate]**
          TEMPLATE
        end

        def default_context_template
          <<~TEMPLATE
            # <%= @name.split('-').map(&:capitalize).join(' ') %> - Context

            Last Updated: <%= @timestamp %>

            ## Current Focus

            [What we're working on right now]

            ## Key Files

            ### Modified
            - `path/to/file1.rb` - [What changed]
            - `path/to/file2.rb` - [What changed]

            ### Created
            - `path/to/new_file.rb` - [Purpose]

            ### To Review
            - `path/to/review.rb` - [Why review needed]

            ## Decisions Made

            1. **[Decision 1]**
               - Rationale: [Why]
               - Alternative considered: [What else we looked at]

            2. **[Decision 2]**
               - Rationale: [Why]

            ## Open Questions

            - [ ] [Question 1]
            - [ ] [Question 2]

            ## Integration Points

            - **System A**: [How this connects]
            - **System B**: [How this connects]

            ## Test Coverage

            - [ ] Unit tests for [component]
            - [ ] Integration tests for [feature]
            - [ ] Edge cases for [scenario]

            ## Next Session Notes

            **Continue with:** [Specific next action]

            **Remember to:** [Important reminder]

            **Context needed:** [Files or docs to review]
          TEMPLATE
        end

        def default_tasks_template
          <<~TEMPLATE
            # <%= @name.split('-').map(&:capitalize).join(' ') %> - Tasks

            Last Updated: <%= @timestamp %>
            Progress: 0/0 (0%)

            ## Phase 1: Foundation

            - [ ] Research existing implementation
            - [ ] Identify affected components
            - [ ] Create initial structure
            - [ ] Set up test framework

            ## Phase 2: Core Implementation

            - [ ] [Core task 1]
            - [ ] [Core task 2]
            - [ ] [Core task 3]
            - [ ] Write unit tests

            ## Phase 3: Integration

            - [ ] Connect to existing systems
            - [ ] Update API endpoints
            - [ ] Modify database schema
            - [ ] Write integration tests

            ## Phase 4: Testing & Refinement

            - [ ] Run full test suite
            - [ ] Fix any failing tests
            - [ ] Performance optimization
            - [ ] Code review
            - [ ] Documentation update

            ## Additional Tasks (discovered during implementation)

            _Add tasks here as you discover them_

            ---

            ## Completed Tasks Archive

            _Move completed tasks here to keep the main list clean_
          TEMPLATE
        end
      end
    end
  end
end
