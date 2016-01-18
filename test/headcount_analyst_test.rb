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

  def test_graduation_rate_variation
    rate = @headcount_analyst.graduation_rate_variation('Academy 20', :against => 'COLORADO')
    assert_equal 1.194, rate
  end

  def test_kindergarten_participation_against_high_school_graduation
    kindergarten_graduation_variance = @headcount_analyst.kindergarten_participation_against_high_school_graduation("Academy 20")
    assert_equal 0.641, kindergarten_graduation_variance
  end

  def test_kindergarten_participation_correlates_with_high_school_graduation_district_true
    does_it_correlate = @headcount_analyst.kindergarten_participation_correlates_with_high_school_graduation(for: 'ACADEMY 20')
    assert does_it_correlate
  end

  def test_kindergarten_participation_correlates_with_high_school_graduation_district_false
    does_it_correlate = @headcount_analyst.kindergarten_participation_correlates_with_high_school_graduation(for: 'ADAMS COUNTY 14')
    refute does_it_correlate
  end

  def test_kindergarten_participation_correlates_with_high_school_graduation_statewide
    statewide_correlation = @headcount_analyst.kindergarten_participation_correlates_with_high_school_graduation(:for => 'STATEWIDE')
    refute statewide_correlation
  end

  def test_kindergarten_participation_correlates_with_high_school_graduation_multiple_districts
    district_correlation = @headcount_analyst.kindergarten_participation_correlates_with_high_school_graduation(:across => ["ACADEMY 20", 'PARK (ESTES PARK) R-3', 'YUMA SCHOOL DISTRICT 1'])
    assert district_correlation
  end

  def test_top_statewide_test_year_over_year_by_subject_and_grade
    assert_equal ["ASPEN 1", 0.125], @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 8, subject: :writing)
  end

  def test_top_statewide_test_year_over_year_by_subject_and_grade_three_leaders
    expected = [["CENTENNIAL R-1", 0.088], ["WESTMINSTER 50", 0.099], ["SPRINGFIELD RE-4", 0.149]]
    assert_equal expected, @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 3, top: 3, subject: :math)
  end

  def test_top_statewide_test_year_over_year_for_all_subjects
    expected = ["SPRINGFIELD RE-4", 0.132]
    assert_equal expected, @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 3)
  end

  def test_top_statewide_test_year_over_year_for_all_subjects_weighted_subjects
    expected = ["PLATEAU RE-5", 0.101]
    assert_equal expected, @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
  end

  def test_weighted_subjects
    skip
    top_performer = @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
        assert_equal "OURAY R-1", top_performer.first
        assert_in_delta 0.153, top_performer.last, 0.005
  end

  def test_top_overall_subjects
    skip
    assert_equal "SANGRE DE CRISTO RE-22J", ha.top_statewide_test_year_over_year_growth(grade: 3).first
    assert_in_delta 0.071, ha.top_statewide_test_year_over_year_growth(grade: 3).last, 0.005
  end


  def test_top_statewide_test_year_over_year_for_all_subjects_weighted_averages_do_not_add_up_to_one
    skip
  end

  def test_insufficient_information_error
    skip
  end

  def test_unknown_data_error
    skip
  end

  #add new tests for statewide data
end
