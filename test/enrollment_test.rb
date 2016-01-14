require './lib/enrollment'
require_relative 'test_helper'
require './lib/district_repository'


class EnrollmentTest < Minitest::Test
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
    @enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation =>
      {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
  end

  def test_participation_with_unknown_year
    assert_equal nil, @enrollment.kindergarten_participation_in_year(2005)
  end

  def test_participation_with_known_year
    assert_equal 0.391, @enrollment.kindergarten_participation_in_year(2010)
  end

  def test_participation_by_year
    assert_equal [2010, 2011, 2012], @enrollment.kindergarten_participation_by_year.keys
    assert_equal  [0.391, 0.353, 0.267], @enrollment.kindergarten_participation_by_year.values
  end
end
