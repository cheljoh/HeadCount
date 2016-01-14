require './lib/headcount_analyst'
require './lib/district_repository'
require_relative 'test_helper'

class HeadcountAnalystTest < Minitest::Test

  def setup
    dr = DistrictRepository.new
    @headcount_analyst = HeadcountAnalyst.new(dr)
  end

  def test_compare_kindergarten_participation_rate_to_state_average
    rate = @headcount_analyst.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
    assert_equal 0.766, rate
  end

  def test_compare_kindergarten_participation_rate_to_another_district
    #skip
    rate = @headcount_analyst.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1')
    assert_equal 0.446, rate
  end

  def test_kindergarten_participation_rate_variation_trend
    #skip
    trends = @headcount_analyst.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
    expected = ({2007=>0.737, 2006=>0.665, 2005=>0.503, 2004=>0.569, 2008=>0.724,
                2009=>0.735, 2010=>0.822, 2011=>0.922, 2012=>0.901, 2013=>0.918, 2014=>0.924})
    assert_equal expected, trends
  end
end
