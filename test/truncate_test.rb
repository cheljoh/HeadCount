require './lib/truncate'
require_relative 'test_helper'

class TruncateTest < Minitest::Test
  def test_does_truncate_method_work
    value = 0.2677
    assert_equal 0.267, Truncate.truncate_number(value)
  end
end
