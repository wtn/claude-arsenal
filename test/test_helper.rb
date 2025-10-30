$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "claude-arsenal"

require "minitest/autorun"
require "fileutils"
require "tmpdir"
require "stringio"

module TestHelpers
  def setup
    super
    @tmp_dir = Dir.mktmpdir
    @original_dir = Dir.pwd
    Dir.chdir(@tmp_dir)

    # Suppress stdout during tests
    @original_stdout = $stdout
    $stdout = StringIO.new
  end

  def teardown
    # Restore stdout
    $stdout = @original_stdout

    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@tmp_dir)
    super
  end

  def fixture_path(name)
    File.join(File.expand_path('fixtures', __dir__), name)
  end
end
