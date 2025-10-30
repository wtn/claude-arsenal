require 'fileutils'
require 'json'
require 'yaml'

module Claude
  module Arsenal
    class SkillLinker
      attr_reader :project_root, :context_dir, :claude_dir

      def initialize(project_root = Dir.pwd)
        @project_root = project_root
        @context_dir = File.join(project_root, ".context")
        @claude_dir = File.join(project_root, ".claude")
      end

      def link_skills
        unless Dir.exist?(@context_dir)
          puts "WARNING: No .context directory found. Run 'agent-context install' first."
          return false
        end

        skills = discover_skills

        if skills.empty?
          puts "No skills found in .context/"
          return true
        end

        create_skill_links(skills)
        update_skill_rules(skills)

        puts "\n==> Linked #{skills.size} skill(s) from .context/"
        true
      end

      def unlink_skills
        skill_rules = load_skill_rules
        linked_skills = skill_rules.select { |name, config| config["_linked"] }

        linked_skills.each do |name, _|
          link_path = File.join(@claude_dir, "skills", "gems", name)
          if File.symlink?(link_path)
            File.unlink(link_path)
            puts "  Unlinked #{name}"
          end
        end

        # Remove linked skills from skill-rules.json
        linked_skills.keys.each { |name| skill_rules.delete(name) }
        save_skill_rules(skill_rules)

        puts "\n==> Unlinked #{linked_skills.size} skill(s)"
        true
      end

      private

      def discover_skills
        skills = []

        return skills unless Dir.exist?(@context_dir)

        Dir.glob(File.join(@context_dir, "*", "skills", "*", "SKILL.md")).each do |skill_path|
          metadata = parse_skill_metadata(skill_path)
          next unless metadata

          skill_dir = File.dirname(skill_path)
          skill_name = File.basename(skill_dir)
          gem_name = skill_path.split("/")[-4] # Extract gem name from path

          skills << {
            name: skill_name,
            gem: gem_name,
            path: skill_dir,
            metadata: metadata
          }
        end

        skills
      end

      def parse_skill_metadata(skill_path)
        content = File.read(skill_path)

        # Extract YAML frontmatter
        if content =~ /\A---\s*\n(.*?\n)---\s*\n/m
          yaml_content = $1
          begin
            YAML.safe_load(yaml_content, permitted_classes: [Symbol], symbolize_names: false)
          rescue => e
            puts "WARNING: Failed to parse metadata in #{skill_path}: #{e.message}"
            nil
          end
        else
          puts "WARNING: No YAML frontmatter found in #{skill_path}"
          nil
        end
      end

      def create_skill_links(skills)
        # Gem skills go in .claude/skills/gems/ subdirectory
        gems_dir = File.join(@claude_dir, "skills", "gems")
        FileUtils.mkdir_p(gems_dir)

        skills.each do |skill|
          link_path = File.join(gems_dir, skill[:name])

          # Skip if already linked to the same target
          if File.symlink?(link_path)
            current_target = File.readlink(link_path)
            relative_target = make_relative_path(link_path, skill[:path])

            if current_target == relative_target
              puts "  -> #{skill[:name]} (already linked)"
              next
            else
              File.unlink(link_path)
            end
          end

          # Remove existing file/directory if it exists and is not a symlink
          if File.exist?(link_path) && !File.symlink?(link_path)
            puts "  WARNING: Skipping #{skill[:name]} (directory exists)"
            next
          end

          # Create relative symlink
          relative_target = make_relative_path(link_path, skill[:path])
          File.symlink(relative_target, link_path)
          puts "  Linked #{skill[:name]} (from #{skill[:gem]})"
        end
      end

      def make_relative_path(from, to)
        from_parts = File.dirname(from).split('/')
        to_parts = to.split('/')

        # Find common prefix
        common_length = 0
        [from_parts.length, to_parts.length].min.times do |i|
          break if from_parts[i] != to_parts[i]
          common_length += 1
        end

        # Build relative path
        up_levels = from_parts.length - common_length
        down_path = to_parts[common_length..-1]

        (['..'] * up_levels + down_path).join('/')
      end

      def update_skill_rules(skills)
        skill_rules = load_skill_rules

        skills.each do |skill|
          metadata = skill[:metadata]

          # Skip if rule already exists and is not linked
          if skill_rules[skill[:name]] && !skill_rules[skill[:name]]["_linked"]
            puts "  -> #{skill[:name]} (rule exists, skipping)"
            next
          end

          skill_rules[skill[:name]] = {
            "type" => metadata["type"],
            "enforcement" => metadata["enforcement"],
            "priority" => metadata["priority"],
            "promptTriggers" => {
              "keywords" => metadata["keywords"] || [],
              "intentPatterns" => metadata["intentPatterns"] || []
            },
            "fileTriggers" => {
              "pathPatterns" => metadata["pathPatterns"] || [],
              "contentPatterns" => metadata["contentPatterns"] || []
            },
            "_linked" => true,
            "_source" => skill[:gem]
          }
        end

        save_skill_rules(skill_rules)
      end

      def load_skill_rules
        rules_path = File.join(@claude_dir, "config", "skill-rules.json")

        if File.exist?(rules_path)
          JSON.parse(File.read(rules_path))
        else
          {
            "_meta" => {
              "version" => "1.0",
              "description" => "Skill activation rules for Claude Code"
            }
          }
        end
      end

      def save_skill_rules(rules)
        FileUtils.mkdir_p(File.join(@claude_dir, "config"))
        rules_path = File.join(@claude_dir, "config", "skill-rules.json")

        File.write(rules_path, JSON.pretty_generate(rules))
      end
    end
  end
end
