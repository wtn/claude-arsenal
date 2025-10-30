require "bundler/gem_tasks"
require "minitest/test_task"
require "rbs/validate/tasks"

Minitest::TestTask.create

task default: %w[test rbs:validate]
