require_relative "arsenal/version"

# Generators
require_relative "arsenal/generators/hook"
require_relative "arsenal/generators/skill"
require_relative "arsenal/generators/subagent"
require_relative "arsenal/generators/slash_command"
require_relative "arsenal/generators/dev_docs"

# Configuration
require_relative "arsenal/config/skill_rules"
require_relative "arsenal/config/validator"

# CLI
require_relative "arsenal/cli/setup"
require_relative "arsenal/cli/gitignore_manager"

# Skill Management
require_relative "arsenal/skill_linker"

module Claude
  module Arsenal
    class Error < StandardError; end
  end
end
