require './lib/headcount_analyst'
require './lib/district_repository'
require_relative 'test_helper'

class EnrollmentTest < Minitest::Test

  def setup
    dr = DistrictRepository.new
    @headcount_analyst = HeadcountAnalyst.new(dr)
  end

  def test_compare_kindergarten_participation_rate_to_state_average
    rate = @headcount_analyst.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
    assert_equal 0.766, rate # => 0.766
  end
end
