require './lib/enrollment_repo'
require_relative 'test_helper'

class EnrollmentRepositoryTest < Minitest::Test
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
    @enrollment = EnrollmentRepository.new
  end

  def test_kindergarten_rate_adams
    puts File.expand_path(".")
    @enrollment.load_data({:enrollment => {:kindergarten => "./data/kindergartners in full-day program.csv"}})
    #path = File.expand_path("./data", __dir__)
    find_name = @enrollment.find_by_name("adams county 14")
    rate = find_name.kindergarten_participation["2009"]
    assert_equal "1", rate
  end

  def test_kindergarten_rate_academy_20_2007
    @enrollment.load_data({:enrollment => {:kindergarten => "./data/kindergartners in full-day program.csv"}})
    find_name = @enrollment.find_by_name("academy 20")
    rate = find_name.kindergarten_participation["2007"]
    assert_equal "0.39159", rate
  end
end

#hello
