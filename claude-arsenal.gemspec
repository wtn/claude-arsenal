require_relative "lib/claude/arsenal/version"

Gem::Specification.new do |spec|
  spec.name = "claude-arsenal"
  spec.version = Claude::Arsenal::VERSION
  spec.authors = ["William T. Nelson"]
  spec.email = ["35801+wtn@users.noreply.github.com"]

  spec.summary = "Claude Code configuration generators"
  spec.description = "A Ruby gem that helps developers set up and manage Claude Code configurations using proven patterns. Includes generators for hooks, skills, subagents, and slash commands with progressive disclosure and auto-activation."
  spec.homepage = "https://github.com/wtn/claude_arsenal"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/wtn/claude_arsenal"
  spec.metadata["changelog_uri"] = "https://github.com/wtn/claude_arsenal/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "agent-context"
end
