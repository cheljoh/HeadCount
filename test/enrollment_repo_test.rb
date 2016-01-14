require './lib/enrollment_repository'
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
    @enrollment.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergartners in full-day program.csv"}})
    find_name = @enrollment.find_by_name("adams county 14")
    rate = find_name.kindergarten_participation[2009]
    assert_equal 1, rate
  end

  def test_kindergarten_rate_academy_20_2007
    @enrollment.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergartners in full-day program.csv"}})
    find_name = @enrollment.find_by_name("academy 20")
    rate = find_name.kindergarten_participation[2007] #district.enrollment.kindergarten_participation in harness
    assert_equal 0.39159, rate
  end

  def test_kindergarten_rate_academy_20_unknown_year_returns_nil
    @enrollment.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergartners in full-day program.csv"}})
    find_name = @enrollment.find_by_name("academy 20")
    rate = find_name.kindergarten_participation[2000]
    assert_equal nil, rate
  end

  def test_find_name_of_unknown_school_returns_nil
    @enrollment.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergartners in full-day program.csv"}})
    find_name = @enrollment.find_by_name("hello")
    assert_equal nil, find_name
  end

  def test_gunnison_shed_rates
    er = EnrollmentRepository.new
    er.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})

    name = "GUNNISON WATERSHED RE1J"
    enrollment = er.find_by_name(name)
    assert_equal name, enrollment.name
    assert enrollment.is_a?(Enrollment)
    assert_in_delta 0.144, enrollment.kindergarten_participation_in_year(2004), 0.005 #this is failing
  end

  def test_high_school_graduation_by_year
    @enrollment.load_data({ :enrollment => { :kindergarten => "./test/fixtures/Kindergartners in full-day program.csv",
        :high_school_graduation => "./test/fixtures/High school graduation rates.csv"}})
    enrollment = @enrollment.find_by_name("ACADEMY 20")

    expected = ({2010=>0.895, 2011=>0.895, 2012=>0.889, 2013=>0.913, 2014=>0.898})

    assert_equal expected, enrollment.graduation_rate_by_year
  end

  def test_high_school_graduation_in_year
    @enrollment.load_data({ :enrollment => { :kindergarten => "./test/fixtures/Kindergartners in full-day program.csv",
        :high_school_graduation => "./test/fixtures/High school graduation rates.csv"}})
    enrollment = @enrollment.find_by_name("ACADEMY 20")
    assert_equal 0.895, enrollment.graduation_rate_in_year(2010)
  end

  def test_does_find_by_name_return_Enrollment_object
    @enrollment.load_data({ :enrollment => { :kindergarten => "./test/fixtures/Kindergartners in full-day program.csv",
        :high_school_graduation => "./test/fixtures/High school graduation rates.csv"}})
    enrollment = @enrollment.find_by_name("ACADEMY 20")
    assert_equal Enrollment, enrollment.class
  end

  def test_graduation_rate_in_unknown_year_returns_nil

  end
end

#hello
