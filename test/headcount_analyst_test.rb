require './lib/headcount_analyst'
require './lib/district_repository'
require_relative 'test_helper'

class HeadcountAnalystTest < Minitest::Test

  def setup
    dr = DistrictRepository.new
    @headcount_analyst = HeadcountAnalyst.new(dr)
  end

  def test_can_headcount_analyst_access_kindergarten_participation_rate_variation
    rate = @headcount_analyst.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
    assert_equal 0.766, rate
  end

  def test_can_headcount_analyst_access_kindergarten_participation_rate_variation_trend
    trend = @headcount_analyst.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
    expected =
    {2007=>0.737, 2006=>0.665, 2005=>0.503,
    2004=>0.569, 2008=>0.724, 2009=>0.735,
    2010=>0.822, 2011=>0.922, 2012=>0.901,
    2013=>0.918, 2014=>0.924}
    assert_equal expected, trend
  end

  def test_can_headcount_analyst_access_participation_against_high_school_graduation
    comparison = @headcount_analyst.kindergarten_participation_against_high_school_graduation('ACADEMY 20')
    assert_equal 0.641, comparison
  end

  def test_can_headcount_analyst_access_kindergarten_participation_correlates_with_graduation
    correlation = @headcount_analyst.kindergarten_participation_correlates_with_high_school_graduation(for: 'ACADEMY 20')
    assert correlation
  end

  def test_can_headcount_analyst_access_top_statewide_test_year_over_year_growth
    top_performer = @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 8)
    assert_equal ["OURAY R-1", 0.11], top_performer
  end

end
