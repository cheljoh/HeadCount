require './lib/district_repository'
require './lib/enrollment'
require_relative 'test_helper'

class DistrictRepositoryTest < Minitest::Test

  def setup
    @district = DistrictRepository.new
    @district.load_data({
      :enrollment => {
        :kindergarten => "./test/fixtures/Kindergartners in full-day program.csv",
        :high_school_graduation => "./test/fixtures/High school graduation rates.csv",
      },
      :statewide_testing => {
        :third_grade => "./test/fixtures/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./test/fixtures/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
        :math => "./test/fixtures/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
        :reading => "./test/fixtures/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
        :writing => "./test/fixtures/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
      }
    })
  end

  def test_a_method
    assert @district.respond_to?(:load_data)
  end

  def test_does_find_by_name_return_district_object
    district_object = @district.find_by_name("academy 20")
    assert_equal District, district_object.class
  end

  def test_does_an_incorrect_name_return_nil_for_find_by_name
    district_object = @district.find_by_name("hello")
    assert_equal nil, district_object
  end

  def test_find_one_matching_name_fragment
    district_object = @district.find_all_matching("acad")
    assert_equal 1, district_object.count
  end

  def test_find_two_matching_name_fragments
    district_objects = @district.find_all_matching("colo")
    assert_equal 2, district_objects.count
  end

  def test_loading_and_finding_districts 
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    district = dr.find_by_name("ACADEMY 20")
    assert_equal "ACADEMY 20", district.name
    assert_equal 7, dr.find_all_matching("WE").count
  end

  def test_unmatched_name_fragment_returns_empty_array
    district_objects = @district.find_all_matching("hello")
    assert_equal [], district_objects
  end

  def test_a_single_letter
    district_objects = @district.find_all_matching("o")
    assert_equal 7, district_objects.count
  end

  def test_district_contains_enrollment_attribute
    district = @district.find_by_name("ACADEMY 20")
    assert_equal 0.436, district.enrollment.kindergarten_participation_in_year(2010)
  end

end
