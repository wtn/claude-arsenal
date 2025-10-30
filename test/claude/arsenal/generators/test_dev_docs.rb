require "test_helper"
require "fileutils"
require "tmpdir"

class Claude::Arsenal::Generators::TestDevDocs < Minitest::Test
  def setup
    @tmp_dir = Dir.mktmpdir
    @old_pwd = Dir.pwd
    Dir.chdir(@tmp_dir)
  end

  def teardown
    Dir.chdir(@old_pwd)
    FileUtils.rm_rf(@tmp_dir)
  end

  def test_create_dev_docs
    generator = Claude::Arsenal::Generators::DevDocs.new('user-auth', action: 'create', quiet: true)
    generator.generate

    # Check that directories were created
    assert File.exist?('dev/active/user-auth'), "Dev docs directory should be created"

    # Check that all three files were created
    assert File.exist?('dev/active/user-auth/user-auth-plan.md'), "Plan file should be created"
    assert File.exist?('dev/active/user-auth/user-auth-context.md'), "Context file should be created"
    assert File.exist?('dev/active/user-auth/user-auth-tasks.md'), "Tasks file should be created"

    # Check content includes expected sections
    plan_content = File.read('dev/active/user-auth/user-auth-plan.md')
    assert_match(/Implementation Plan/, plan_content)
    assert_match(/Executive Summary/, plan_content)
    assert_match(/Goals/, plan_content)
    assert_match(/Approach/, plan_content)

    context_content = File.read('dev/active/user-auth/user-auth-context.md')
    assert_match(/Context/, context_content)
    assert_match(/Current/, context_content)
    assert_match(/Key Files/, context_content)

    tasks_content = File.read('dev/active/user-auth/user-auth-tasks.md')
    assert_match(/Tasks/, tasks_content)
    assert_match(/Phase 1/, tasks_content)
    assert_match(/Phase 2/, tasks_content)
  end

  def test_create_with_hyphens_in_name
    generator = Claude::Arsenal::Generators::DevDocs.new('feature-with-hyphens', action: 'create', quiet: true)
    generator.generate

    assert File.exist?('dev/active/feature-with-hyphens'), "Dev docs directory should handle hyphens"
    assert File.exist?('dev/active/feature-with-hyphens/feature-with-hyphens-plan.md')
  end

  def test_create_normalizes_name
    generator = Claude::Arsenal::Generators::DevDocs.new('Feature With Spaces!', action: 'create', quiet: true)
    generator.generate

    # Name should be normalized to lowercase with hyphens
    assert File.exist?('dev/active/feature-with-spaces-'), "Dev docs directory should normalize name"
  end

  def test_create_fails_if_directory_exists
    FileUtils.mkdir_p('dev/active/existing-feature')

    generator = Claude::Arsenal::Generators::DevDocs.new('existing-feature', action: 'create', quiet: true)

    assert_raises(RuntimeError) do
      generator.generate
    end
  end

  def test_update_timestamps
    # First create dev docs
    FileUtils.mkdir_p('dev/active/feature-1')
    File.write('dev/active/feature-1/feature-1-plan.md', "# Plan\nLast Updated: 2024-01-01 10:00\nContent")
    File.write('dev/active/feature-1/feature-1-context.md', "# Context\nLast Updated: 2024-01-01 10:00\nContent")

    FileUtils.mkdir_p('dev/active/feature-2')
    File.write('dev/active/feature-2/feature-2-plan.md', "# Plan\nLast Updated: 2024-01-01 10:00\nContent")

    # Run update
    generator = Claude::Arsenal::Generators::DevDocs.new('update', action: 'update', quiet: true)
    generator.generate

    # Check that timestamps were updated (not checking exact time, just that they changed)
    plan1_content = File.read('dev/active/feature-1/feature-1-plan.md')
    refute_match(/2024-01-01 10:00/, plan1_content)
    assert_match(/Last Updated:/, plan1_content)

    context1_content = File.read('dev/active/feature-1/feature-1-context.md')
    refute_match(/2024-01-01 10:00/, context1_content)

    plan2_content = File.read('dev/active/feature-2/feature-2-plan.md')
    refute_match(/2024-01-01 10:00/, plan2_content)
  end

  def test_update_with_no_active_docs
    # Should not fail when no active docs exist
    generator = Claude::Arsenal::Generators::DevDocs.new('update', action: 'update', quiet: true)
    generator.generate # Should complete without error

    assert true, "Update should handle missing active directory gracefully"
  end

  def test_empty_name_raises_error
    assert_raises(ArgumentError) do
      Claude::Arsenal::Generators::DevDocs.new('', action: 'create', quiet: true).generate
    end
  end

  def test_long_name_raises_error
    long_name = 'a' * 51
    assert_raises(ArgumentError) do
      Claude::Arsenal::Generators::DevDocs.new(long_name, action: 'create', quiet: true).generate
    end
  end

  def test_templates_include_timestamp
    generator = Claude::Arsenal::Generators::DevDocs.new('test-feature', action: 'create', quiet: true)
    generator.generate

    plan_content = File.read('dev/active/test-feature/test-feature-plan.md')
    assert_match(/Last Updated:/, plan_content)
    # Should have a timestamp that looks like YYYY-MM-DD HH:MM
    assert_match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}/, plan_content)
  end
end
