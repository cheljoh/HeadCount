require './lib/participation_analyst'
require './lib/district_repository'
require './lib/headcount_analyst'
require_relative 'test_helper'

class StatewideTestAnalystTest < Minitest::Test

  def setup
    dr = DistrictRepository.new
    @headcount_analyst = HeadcountAnalyst.new(dr)
    @test_analyst = StatewideTestAnalyst.new(dr)
  end

  def test_top_statewide_test_year_over_year_for_eighth_grade_writing
    assert_equal ["DE BEQUE 49JT", 0.17], @test_analyst.top_statewide_test_year_over_year_growth(grade: 8, subject: :writing)
  end

  def test_top_statewide_test_year_over_year_by_subject_and_grade_three_leaders
    expected =
    [["COTOPAXI RE-3", 0.07], ["SANGRE DE CRISTO RE-22J", 0.071], ["WILEY RE-13 JT", 0.3]]
    assert_equal expected, @test_analyst.top_statewide_test_year_over_year_growth(grade: 3, top: 3, subject: :math)
  end

  def test_top_statewide_test_year_over_year_weighted_subjects
    top_performer = @test_analyst.top_statewide_test_year_over_year_growth(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
    assert_equal ["OURAY R-1", 0.153], top_performer
  end

  def test_top_statewide_test_year_over_year_growth_all_subjects_eighth_grade
    top_performer = @test_analyst.top_statewide_test_year_over_year_growth(grade: 8)
    assert_equal ["OURAY R-1", 0.11], top_performer
  end

  def test_statewide_test_year_over_year_growth_eighth_grade_reading
    top_performer = @test_analyst.top_statewide_test_year_over_year_growth(grade: 8, subject: :reading)
    assert_equal ["COTOPAXI RE-3", 0.13], top_performer
  end

  def test_statewide_year_over_year_growth_third_grade_writing
    top_performer = @test_analyst.top_statewide_test_year_over_year_growth(grade: 3, subject: :writing)
    assert_equal ["BETHUNE R-5", 0.148], top_performer
  end

  def test_top_overall_subjects_grade_three
    top_performer = @test_analyst.top_statewide_test_year_over_year_growth(grade: 3)
    assert_equal ["SANGRE DE CRISTO RE-22J", 0.071], top_performer
  end

  def test_statewide_test_year_over_year_growth_for_third_grade_math
    top_performer = @test_analyst.top_statewide_test_year_over_year_growth(grade: 3, subject: :math)
    assert_equal ["WILEY RE-13 JT", 0.3], top_performer
  end

  def test_top_statewide_test_year_over_year_for_all_subjects_weighted_averages_do_not_add_up_to_one
    assert_raises UnknownDataError do
      @test_analyst.top_statewide_test_year_over_year_growth(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.5})
    end
  end

  def test_insufficient_information_error_for_grade
    assert_raises InsufficientInformationError do
      @test_analyst.top_statewide_test_year_over_year_growth(subject: :math)
    end
  end

  def test_unknown_data_error_for_grade
    assert_raises UnknownDataError do
      @test_analyst.top_statewide_test_year_over_year_growth(grade: 9, subject: :math)
    end
  end

end
