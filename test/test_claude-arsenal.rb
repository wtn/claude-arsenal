require "test_helper"

class TestClaudeArsenal < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Claude::Arsenal::VERSION
  end

  def test_has_error_class
    assert_kind_of Class, ::Claude::Arsenal::Error
    assert ::Claude::Arsenal::Error < StandardError
  end
end
