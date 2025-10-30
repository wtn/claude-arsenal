require 'fileutils'

module Claude
  module Arsenal
    module CLI
      # Manages .gitignore entries for Claude Arsenal
      class GitignoreManager
        SECTION_MARKER = "# Added by claude-arsenal"

        attr_reader :base_dir, :gitignore_path

        def initialize(base_dir: '.')
          @base_dir = base_dir
          @gitignore_path = File.join(base_dir, '.gitignore')
        end

        # Add recommended .gitignore entries
        def add_entries
          entries = build_entries
          add_to_gitignore(entries)

          puts "\n==> Updated .gitignore"
          puts "\nIgnored (regeneratable):"
          puts "   - /dev/active/"
          puts "   - /.context/"
          puts "   - /.claude/tmp/"
          puts "   - /.claude/skills/gems/"
          puts "   - /CLAUDE.md"
          puts "\nCommitted:"
          puts "   - agents.md"
          puts "   - .claude/skills/local/"
          puts "   - .claude/hooks/, agents/, commands/, config/"
        end

        private

        def build_entries
          [
            '/dev/active/',
            '/.context/',
            '/.claude/tmp/',
            '/.claude/skills/gems/',
            '/CLAUDE.md'
          ]
        end

        def add_to_gitignore(entries)
          existing_content = File.exist?(gitignore_path) ? File.read(gitignore_path) : ''

          # Check if we already have a claude-arsenal section
          if existing_content.include?(SECTION_MARKER)
            # Update existing section
            update_existing_section(existing_content, entries)
          else
            # Add new section
            add_new_section(existing_content, entries)
          end
        end

        def update_existing_section(content, entries)
          # Find and replace the claude-arsenal section
          section_regex = /#{Regexp.escape(SECTION_MARKER)}.*?(?=\n(?:#[^#]|\n|\z))/m

          new_section = build_section(entries)
          updated_content = content.gsub(section_regex, new_section.strip)

          File.write(gitignore_path, updated_content)
        end

        def add_new_section(content, entries)
          # Add to end of file with proper spacing
          separator = content.end_with?("\n\n") ? "" : (content.end_with?("\n") ? "\n" : "\n\n")
          new_content = content + separator + build_section(entries)

          File.write(gitignore_path, new_content)
        end

        def build_section(entries)
          section = "#{SECTION_MARKER}\n"
          entries.each do |entry|
            section += "#{entry}\n"
          end
          section
        end
      end
    end
  end
end
