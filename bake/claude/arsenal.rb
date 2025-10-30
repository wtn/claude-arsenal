require_relative '../../lib/claude-arsenal'

# Complete installation: installs agent-context, creates structure, links skills, updates .gitignore
# Usage: bake claude:arsenal:install
def install
  puts "Installing Claude Arsenal...\n\n"

  # Step 1: Install agent-context (meta-knowledge)
  puts "Step 1/5: Installing meta-knowledge from gems..."
  require 'agent/context/installer'
  require 'agent/context/index'
  installer = Agent::Context::Installer.new(root: Dir.pwd)
  installed = installer.install_all_context

  if installed.any?
    puts "   Installed context from #{installed.length} gem(s):"
    installed.each { |gem_name| puts "      - #{gem_name}" }
  else
    puts "   No gems with context found"
  end

  # Generate agents.md
  puts "   Generating agents.md..."
  index = Agent::Context::Index.new(installer.context_path)
  index.update_agents_md
  puts "   Created agents.md"

  # Create CLAUDE.md pointing to agents.md
  puts "   Generating CLAUDE.md..."
  File.write('CLAUDE.md', "@agents.md\n")
  puts "   Created CLAUDE.md"

  # Step 2: Create directory structure
  puts "\nStep 2/5: Creating directory structure..."
  ::Claude::Arsenal::CLI::Setup.new.run

  # Step 3: Link skills from .context/
  puts "\nStep 3/5: Linking skills from gems..."
  linker = ::Claude::Arsenal::SkillLinker.new
  linker.link_skills

  # Step 4: Copy skill-activator hook
  puts "\nStep 4/5: Installing skill-activator hook..."
  hook_source = File.join('.context', 'claude-arsenal', 'hooks', 'skill-activator.ts')
  hook_target = File.join('.claude', 'hooks', 'skill-activator.ts')

  if File.exist?(hook_source)
    FileUtils.cp(hook_source, hook_target)
    puts "   Installed: #{hook_target}"
  else
    puts "   WARNING: skill-activator hook not found in .context/"
  end

  # Step 5: Update .gitignore
  puts "\nStep 5/5: Configuring .gitignore..."
  gitignore_manager = ::Claude::Arsenal::CLI::GitignoreManager.new
  gitignore_manager.add_entries

  # Count linked skills
  linked_skills = Dir.glob('.claude/skills/gems/*').select { |f| File.directory?(f) || File.symlink?(f) }
  skill_count = linked_skills.length

  puts "\n==> Claude Arsenal installation complete!"
  if skill_count > 0
    puts "\n#{skill_count} gem skill#{skill_count == 1 ? '' : 's'} ready and auto-activating via skill-activator hook"
  end

  puts "\nTo finish setup, copy this to Claude Code:"
  puts "\n" + "="*60
  puts "Read agents.md to understand the claude-arsenal workflow,"
  puts "then help me fill in context/ templates with project info."
  puts "="*60
end

# Copy a reference hook to your project
# Usage: bake claude:arsenal:copy_hook skill-activator
def copy_hook(name)
  source = File.join('.context', 'claude-arsenal', 'hooks', "#{name}.ts")
  target = File.join('.claude', 'hooks', "#{name}.ts")

  unless File.exist?(source)
    puts "Hook not found: #{source}"
    puts "\nAvailable hooks in .context/claude-arsenal/hooks/:"
    Dir.glob('.context/claude-arsenal/hooks/*.ts').each do |f|
      puts "  - #{File.basename(f, '.ts')}"
    end
    exit 1
  end

  FileUtils.mkdir_p(File.dirname(target))

  if File.exist?(target)
    puts "WARNING: File exists: #{target}"
    print "Overwrite? (y/n): "
    return unless gets.chomp.downcase == 'y'
  end

  FileUtils.cp(source, target)
  puts "Copied hook to #{target}"
  puts "\nYou can now customize it for your project."
end

# Create a skill
# Usage: bake claude:arsenal:skill_create backend-dev domain
def skill_create(name, type = 'domain', priority: 'medium')
  generator = ::Claude::Arsenal::Generators::Skill.new(
    name: name,
    type: type,
    priority: priority
  )

  path = generator.generate
  puts "Generated skill: #{path}"
  puts "\nNext steps:"
  puts "  1. Edit .claude/skills/local/#{name}/SKILL.md"
  puts "  2. Add resources to .claude/skills/local/#{name}/resources/"
  puts "  3. Customize activation rules in .claude/config/skill-rules.json"
rescue ::Claude::Arsenal::Error => e
  puts "Error: #{e.message}"
  exit 1
end

# Copy a reference agent to your project
# Usage: bake claude:arsenal:copy_agent code-architecture-reviewer
def copy_agent(name)
  # Check common locations
  possible_sources = [
    File.join('.context', 'claude-arsenal', 'agents', "#{name}.md"),
    File.join('.context', 'claude-arsenal', 'agents', 'quality_control', "#{name}.md"),
    File.join('.context', 'claude-arsenal', 'agents', 'planning', "#{name}.md"),
  ]

  source = possible_sources.find { |s| File.exist?(s) }

  unless source
    puts "Agent not found: #{name}"
    puts "\nAvailable agents in .context/claude-arsenal/agents/:"
    Dir.glob('.context/claude-arsenal/agents/**/*.md').reject { |f| f.end_with?('README.md') }.each do |f|
      puts "  - #{File.basename(f, '.md')}"
    end
    exit 1
  end

  target = File.join('.claude', 'agents', "#{name}.md")
  FileUtils.mkdir_p(File.dirname(target))

  if File.exist?(target)
    puts "WARNING: File exists: #{target}"
    print "Overwrite? (y/n): "
    return unless gets.chomp.downcase == 'y'
  end

  FileUtils.cp(source, target)
  puts "Copied agent to #{target}"
  puts "\nYou can now customize it for your project."
end

# Copy a reference slash command to your project
# Usage: bake claude:arsenal:copy_command dev-docs
def copy_command(name)
  source = File.join('.context', 'claude-arsenal', 'commands', "#{name}.md")
  target = File.join('.claude', 'commands', "#{name}.md")

  unless File.exist?(source)
    puts "Command not found: #{source}"
    puts "\nAvailable commands in .context/claude-arsenal/commands/:"
    Dir.glob('.context/claude-arsenal/commands/*.md').reject { |f| f.end_with?('README.md') }.each do |f|
      puts "  - #{File.basename(f, '.md')}"
    end
    exit 1
  end

  FileUtils.mkdir_p(File.dirname(target))

  if File.exist?(target)
    puts "WARNING: File exists: #{target}"
    print "Overwrite? (y/n): "
    return unless gets.chomp.downcase == 'y'
  end

  FileUtils.cp(source, target)
  puts "Copied command to #{target}"
  puts "\nCommand available as: /#{name}"
  puts "You can now customize it for your project."
end

# Create dev docs for a feature
# Usage: bake claude:arsenal:dev_docs_create feature-name
def dev_docs_create(name)
  generator = ::Claude::Arsenal::Generators::DevDocs.new(
    name,
    action: 'create'
  )

  generator.generate
  puts "\nDev docs created for: #{name}"
  puts "\nNext steps:"
  puts "  1. Review and fill in the plan"
  puts "  2. Get approval before implementation"
  puts "  3. Update context and tasks as you work"
rescue ::Claude::Arsenal::Error => e
  puts "Error: #{e.message}"
  exit 1
end

# Update dev docs timestamps
# Usage: bake claude:arsenal:dev-docs:update
def dev_docs_update
  generator = ::Claude::Arsenal::Generators::DevDocs.new(
    'update',
    action: 'update'
  )

  generator.generate
  puts "Dev docs timestamps updated"
rescue ::Claude::Arsenal::Error => e
  puts "Error: #{e.message}"
  exit 1
end

# Move dev docs from active to completed
# Usage: bake claude:arsenal:dev_docs_complete feature-name
def dev_docs_complete(name)
  active_dir = File.join('.', 'dev', 'active', name)
  completed_dir = File.join('.', 'dev', 'completed', name)

  unless File.exist?(active_dir)
    puts "No active dev docs found for: #{name}"
    exit 1
  end

  FileUtils.mkdir_p(File.dirname(completed_dir))
  FileUtils.mv(active_dir, completed_dir)

  puts "Moved #{name} to completed/"
  puts "   Archive available at: dev/completed/#{name}/"
rescue => e
  puts "Error: #{e.message}"
  exit 1
end

# Validate configuration
# Usage: bake claude:arsenal:validate
def validate
  validator = ::Claude::Arsenal::Config::Validator.new
  result = validator.validate_all

  if result.valid?
    puts "All configurations are valid!"
  else
    puts "Validation errors found:\n"
    result.errors.each { |error| puts "  - #{error}" }
    exit 1
  end

  unless result.warnings.empty?
    puts "\nWarnings:"
    result.warnings.each { |warning| puts "  - #{warning}" }
  end
end

# Link skills from .context/ to .claude/skills/
# Usage: bake claude:arsenal:link_skills
def link_skills
  linker = ::Claude::Arsenal::SkillLinker.new
  success = linker.link_skills

  unless success
    exit 1
  end

  puts "\nSkills are now available and will auto-activate based on their triggers."
  puts "To customize, edit .claude/config/skill-rules.json"
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace.join("\n") if ENV['DEBUG']
  exit 1
end

# Unlink skills from .claude/skills/
# Usage: bake claude:arsenal:unlink_skills
def unlink_skills
  linker = ::Claude::Arsenal::SkillLinker.new
  linker.unlink_skills
rescue => e
  puts "Error: #{e.message}"
  exit 1
end

# List available templates
module List
  def self.hooks
    puts "Available hook types:"
    puts "  - user-prompt-submit  (Skill auto-activation)"
    puts "  - post-tool-use       (File edit tracking)"
    puts "  - stop                (Build checker, error reminders)"
    puts "\nUsage: bake claude:arsenal:hook_generate TYPE NAME"
  end

  def self.skills
    puts "Available skill types:"
    puts "  - domain      (Domain-specific guidelines)"
    puts "  - guidelines  (General best practices)"
    puts "  - guardrail   (Safety checks and validation)"
    puts "\nUsage: bake claude:arsenal:skill_create NAME TYPE"
  end

  def self.agents
    puts "Available agent categories:"
    puts "  - quality-control  (Code review, refactoring, error resolution)"
    puts "  - testing          (Test running, debugging)"
    puts "  - planning         (Strategic planning, documentation)"
    puts "  - debugging        (Error diagnosis, troubleshooting)"
    puts "\nUsage: bake claude:arsenal:agent_create NAME CATEGORY"
  end

  def self.commands
    puts "Common slash commands:"
    puts "  - dev-docs        (Create comprehensive strategic plans)"
    puts "  - code-review     (Run architectural review)"
    puts "  - build-and-fix   (Run builds and fix errors)"
    puts "  - test-affected   (Test affected files)"
    puts "\nUsage: bake claude:arsenal:command_create NAME"
  end

  def self.dev_docs
    puts "Dev docs workflow commands:"
    puts "  bake claude:arsenal:dev_docs_create feature-name"
    puts "    -> Creates plan, context, and tasks files in dev/active/"
    puts ""
    puts "  bake claude:arsenal:dev_docs_update"
    puts "    -> Updates timestamps before context compaction"
    puts ""
    puts "  bake claude:arsenal:dev_docs_complete feature-name"
    puts "    -> Moves feature from active/ to completed/"
    puts ""
    puts "This workflow helps prevent Claude from losing context during large features."
  end
end

# List tasks - these need to be instance methods too
def list_hooks
  List.hooks
end

def list_skills
  List.skills
end

def list_agents
  List.agents
end

def list_commands
  List.commands
end

def list_dev_docs
  List.dev_docs
end
