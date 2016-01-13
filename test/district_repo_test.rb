require './lib/district_repo'
require_relative 'test_helper'

class DistrictRepositoryTest < Minitest::Test
  # class TestEconomicProfile < Minitest::Test
  #   def test_free_or_reduced_lunch_in_year
  #     path       = File.expand_path("../data", __dir__)
  #     repository = DistrictRepository.from_csv(path)
  #     district   = repository.find_by_name("ACADEMY 20")
  #
  #     assert_equal 0.125, district.economic_profile.free_or_reduced_lunch_in_year(2012)
  #   end
  # end

  def setup
    @district = DistrictRepository.new
  end

  def test_a_method
    assert @district.respond_to?(:load_data)
  end

  def test_does_find_by_name_return_district_object
    @district.load_data({ :enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    district_object = @district.find_by_name("academy 20")
    assert_equal District, district_object.class
  end

  def test_does_an_incorrect_name_return_nil_for_find_by_name
    @district.load_data({ :enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    district_object = @district.find_by_name("hello")
    assert_equal nil, district_object
  end

  def test_find_one_matching_name_fragment
    @district.load_data({ :enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    district_objects = @district.find_all_matching("aca")
    assert_equal 1, district_objects.count
  end

  def test_find_multiple_matching_name_fragments
    @district.load_data({ :enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    district_objects = @district.find_all_matching("co")
    assert_equal 33, district_objects.count
  end

  def test_unmatched_name_fragment_returns_empty_array
    @district.load_data({ :enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    district_objects = @district.find_all_matching("hello")
    assert_equal [], district_objects
  end
end
