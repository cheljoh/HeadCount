require './lib/enrollment_repository'
require_relative 'test_helper'

class EnrollmentRepositoryTest < Minitest::Test

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
    assert_equal 0.391, rate
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

  def test_kindergarten_rate_with_missing_data_returns_na
    @enrollment.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergartners in full-day program.csv"}})
    find_name = @enrollment.find_by_name("WEST YUMA COUNTY RJ-1")
    rate = find_name.kindergarten_participation[2010]
    assert_equal "N/A", rate
  end

  def test_kindergarten_participation_in_year
    @enrollment.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    name = "GUNNISON WATERSHED RE1J"
    enrollment = @enrollment.find_by_name(name)
    assert_equal name, enrollment.name
    assert enrollment.is_a?(Enrollment)
    assert_equal 0.144, enrollment.kindergarten_participation_in_year(2004)
  end

  def test_kindergarten_participation_in_year_missing_data_returns_na
    @enrollment.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    name = "WEST YUMA COUNTY RJ-1"
    enrollment = @enrollment.find_by_name(name)
    assert_equal name, enrollment.name
    assert enrollment.is_a?(Enrollment)
    assert_equal "N/A", enrollment.kindergarten_participation_in_year(2010)
  end

  def test_kindergarten_participation_by_year
    @enrollment.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    name = "ACADEMY 20"
    find_name = @enrollment.find_by_name(name)
    expected =
    {2007=>0.391, 2006=>0.353, 2005=>0.267, 2004=>0.302, 2008=>0.384,
    2009=>0.39, 2010=>0.436, 2011=>0.489, 2012=>0.478, 2013=>0.487, 2014=>0.49}
    assert_equal expected, find_name.kindergarten_participation_by_year
  end

  def test_kindergarten_participation_by_year_missing_data_returns_na
    @enrollment.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    name = "WEST YUMA COUNTY RJ-1"
    find_name = @enrollment.find_by_name(name)
    expected =
    {2007=>"N/A", 2006=>"N/A", 2005=>"N/A", 2004=>"N/A", 2008=>"N/A",
    2009=>"N/A", 2010=>"N/A", 2011=>"N/A", 2012=>"N/A", 2013=>"N/A", 2014=>"N/A"}
    assert_equal expected, find_name.kindergarten_participation_by_year
  end

  def test_high_school_graduation_rate_by_year
    @enrollment.load_data({ :enrollment => { :kindergarten => "./test/fixtures/Kindergartners in full-day program.csv",
        :high_school_graduation => "./test/fixtures/High school graduation rates.csv"}})
    enrollment = @enrollment.find_by_name("ACADEMY 20")
    expected = ({2010=>0.895, 2011=>0.895, 2012=>0.889, 2013=>0.913, 2014=>0.898})
    assert_equal expected, enrollment.graduation_rate_by_year
  end

  def test_high_school_graduation_rate_by_year_returns_na_for_missing_data
    @enrollment.load_data({ :enrollment => { :kindergarten => "./test/fixtures/Kindergartners in full-day program.csv",
        :high_school_graduation => "./test/fixtures/High school graduation rates.csv"}})
    enrollment = @enrollment.find_by_name("WEST YUMA COUNTY RJ-1")
    expected = ({2010=>"N/A", 2011=>"N/A", 2012=>"N/A", 2013=>"N/A", 2014=>"N/A"})
    assert_equal expected, enrollment.graduation_rate_by_year
  end

  def test_high_school_graduation_rate_in_year
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
    @enrollment.load_data({ :enrollment => { :kindergarten => "./test/fixtures/Kindergartners in full-day program.csv",
        :high_school_graduation => "./test/fixtures/High school graduation rates.csv"}})
    enrollment = @enrollment.find_by_name("ACADEMY 20")
    assert_equal nil, enrollment.graduation_rate_in_year(2000)
  end

  def test_graduation_rate_returns_na_for_missing_data
    @enrollment.load_data({ :enrollment => { :kindergarten => "./test/fixtures/Kindergartners in full-day program.csv",
        :high_school_graduation => "./test/fixtures/High school graduation rates.csv"}})
    enrollment = @enrollment.find_by_name("WEST YUMA COUNTY RJ-1")
    assert_equal "N/A", enrollment.graduation_rate_in_year(2010)
  end
  
end
