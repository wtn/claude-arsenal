# Agent

## Context

This section provides links to project context and documentation from installed packages.

**💡 Tip:** The `.context/` directory contains project-specific patterns, conventions, and workflows. When working on tasks, it's helpful to check the relevant context files below first - they often have the information you need about how this project works.

This section provides links to documentation from installed packages. It is automatically generated and may be updated by running `bake agent:context:install`.

**Important:** Before performing any code, documentation, or analysis tasks, always read and apply the full content of any relevant documentation referenced in the following sections. These context files contain authoritative standards and best practices for documentation, code style, and project-specific workflows. **Do not proceed with any actions until you have read and incorporated the guidance from relevant context files.**

**Setup Instructions:** If the referenced files are not present or if dependencies have been updated, run `bake agent:context:install` to install the latest context files.

### agent-context

Install and manage context files from Ruby gems.

#### [Getting Started](.context/agent-context/getting-started.md)

This guide explains how to use `agent-context`, a tool for discovering and installing contextual information from Ruby gems to help AI agents.

### bake

A replacement for rake with a simpler syntax.

#### [Getting Started](.context/bake/getting-started.md)

This guide gives a general overview of `bake` and how to use it.

#### [Command Line Interface](.context/bake/command-line-interface.md)

The `bake` command is broken up into two main functions: `list` and `call`.

#### [Project Integration](.context/bake/project-integration.md)

This guide explains how to add `bake` to a Ruby project.

#### [Gem Integration](.context/bake/gem-integration.md)

This guide explains how to add `bake` to a Ruby gem and export standardised tasks for use by other gems and projects.

#### [Input and Output](.context/bake/input-and-output.md)

`bake` has built in tasks for reading input and writing output in different formats. While this can be useful for general processing, there are some limitations, notably that rich object representations like `json` and `yaml` often don't support stream processing.

### claude-arsenal

Claude Code configuration generators and workflow tools

#### [Getting Started](.context/claude-arsenal/getting-started.md)

Quick start guide and installation instructions

#### [Dev Docs Workflow](.context/claude-arsenal/dev-docs.md)

Prevent context loss with persistent documentation across sessions

#### [Configuration](.context/claude-arsenal/configuration.md)

Understanding skill-rules.json and configuration options

#### [Hooks](.context/claude-arsenal/hooks.md)

Hook system overview and templates

#### [Skills](.context/claude-arsenal/skills.md)

Creating and organizing skills with progressive disclosure

#### [Subagents](.context/claude-arsenal/agents.md)

Specialized subagent configurations

#### [Slash Commands](.context/claude-arsenal/commands.md)

Custom slash command creation

#### [Examples](.context/claude-arsenal/examples.md)

Real-world usage patterns and complete setups

### samovar

Samovar is a flexible option parser excellent support for sub-commands and help documentation.

#### [Getting Started](.context/samovar/getting-started.md)

This guide explains how to use `samovar` to build command-line tools and applications.
