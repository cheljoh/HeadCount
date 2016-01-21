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

  def test_top_statewide_test_year_over_year_for_eighth_grade_writing
    skip #i wrote this test, aspen prolly not right anymore
    assert_equal ["ASPEN 1", 0.125], @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 8, subject: :writing)
  end

  def test_top_statewide_test_year_over_year_by_subject_and_grade_three_leaders
    #float/string comparison
    expected = [["CENTENNIAL R-1", 0.088], ["WESTMINSTER 50", 0.099], ["SPRINGFIELD RE-4", 0.149]]
    assert_equal expected, @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 3, top: 3, subject: :math)
  end

  def test_top_statewide_test_year_over_year_weighted_subjects
    #skip# getting PLATEAU
    top_performer = @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
    assert_equal ["OURAY R-1", 0.153], top_performer
  end

  def test_top_statewide_test_year_over_year_growth_all_subjects_eighth_grade
    top_performer = @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 8)
    assert_equal ["OURAY R-1", 0.11], top_performer
  end

  def test_statewide_test_year_over_year_growth_eighth_grade_reading
    top_performer = @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 8, subject: :reading)
    assert_equal ["COTOPAXI RE-3", 0.13], top_performer
  end

  def test_statewide_year_over_year_growth_third_grade_writing
    top_performer = @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 3, subject: :writing)
    assert_equal ["BETHUNE R-5", 0.148], top_performer
  end

  def test_top_overall_subjects_grade_three
    #skip, getting SPRINGFIELD
    top_performer = @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 3)
    assert_equal ["SANGRE DE CRISTO RE-22J", 0.071], top_performer
  end

  def test_statewide_test_year_over_year_growth_for_third_grade_math
    top_performer = @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 3, subject: :math)
    assert_equal ["WILEY RE-13 JT", 0.3], top_performer
  end

  def test_top_statewide_test_year_over_year_for_all_subjects_weighted_averages_do_not_add_up_to_one
    assert_raises UnknownDataError do
      @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.5})
    end
  end

  def test_insufficient_information_error_for_grade
    assert_raises InsufficientInformationError do
      @headcount_analyst.top_statewide_test_year_over_year_growth(subject: :math)
    end
  end

  def test_unknown_data_error_for_grade
    assert_raises UnknownDataError do
      @headcount_analyst.top_statewide_test_year_over_year_growth(grade: 9, subject: :math)
    end
  end

  #add new tests for statewide data
end
