require_relative '../../lib/claude-arsenal'

# Complete installation: installs agent-context, creates structure, links skills, updates .gitignore
# Usage: bake claude:arsenal:install
def install
  puts "Installing Claude Arsenal...\n\n"

  # Step 1: Install agent-context (meta-knowledge)
  puts "Step 1/4: Installing meta-knowledge from gems..."
  begin
    require_relative '../../bonus_info/agent-context/lib/agent/context/installer'
    installer = Agent::Context::Installer.new(root: Dir.pwd)
    installed = installer.install_all_context

    if installed.any?
      puts "   Installed context from #{installed.length} gem(s):"
      installed.each { |gem_name| puts "      - #{gem_name}" }
    else
      puts "   No gems with context found"
    end
  rescue LoadError => e
    puts "   WARNING: agent-context not available (#{e.message})"
    puts "   Continuing with setup..."
  end

  # Step 2: Create directory structure
  puts "\nStep 2/4: Creating directory structure..."
  ::Claude::Arsenal::CLI::Setup.new.run

  # Step 3: Link skills from .context/
  puts "\nStep 3/4: Linking skills from gems..."
  linker = ::Claude::Arsenal::SkillLinker.new
  linker.link_skills

  # Step 4: Update .gitignore (runs AFTER skill linking so it can detect symlinks)
  puts "\nStep 4/4: Configuring .gitignore..."
  gitignore_manager = ::Claude::Arsenal::CLI::GitignoreManager.new
  gitignore_manager.add_entries

  puts "\n==> Claude Arsenal installation complete!"
  puts "\n4 gem skills ready in .claude/skills/gems/:"
  puts "   - ruby-gem-development, generator-patterns, documentation-writing, test-coverage"
  puts "\nDirectory structure:"
  puts "   .claude/skills/gems/   (gem skills - symlinked, gitignored)"
  puts "   .claude/skills/local/  (project skills - committed)"
  puts "\nNext steps:"
  puts "   1. Copy the skill-activator hook:"
  puts "      bake claude:arsenal:copy_hook skill-activator"
  puts "   2. (Optional) Create project-specific skills:"
  puts "      bake claude:arsenal:skill_create backend-api domain"
  puts "\nBrowse reference implementations:"
  puts "   - Hooks: .context/claude-arsenal/hooks/"
  puts "   - Agents: .context/claude-arsenal/agents/"
  puts "   - Commands: .context/claude-arsenal/commands/"
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
    puts "⚠️  File exists: #{target}"
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
    puts "⚠️  File exists: #{target}"
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
    puts "⚠️  File exists: #{target}"
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
    puts "    → Creates plan, context, and tasks files in dev/active/"
    puts ""
    puts "  bake claude:arsenal:dev_docs_update"
    puts "    → Updates timestamps before context compaction"
    puts ""
    puts "  bake claude:arsenal:dev_docs_complete feature-name"
    puts "    → Moves feature from active/ to completed/"
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
