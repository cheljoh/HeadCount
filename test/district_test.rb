require './lib/district'
require_relative 'test_helper'

class DistrictTest < Minitest::Test

  def test_does_it_have_a_name
    district = District.new({:name => "Academy 20"})
    assert_equal "ACADEMY 20", district.name
  end


end
