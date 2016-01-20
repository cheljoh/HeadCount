require './lib/enrollment'
require_relative 'test_helper'
require './lib/district_repository'


class EnrollmentTest < Minitest::Test

  def setup
    @enrollment = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation =>
      {2010 => 0.391, 2011 => 0.353, 2012 => 0.267},
        :high_school_graduation_rates => {2010 => 0.895, 2011 => 0.895, 2012 => 0.889,
          2013 => 0.913, 2014 => 0.898}})
  end

  def test_participation_with_unknown_year
    assert_equal nil, @enrollment.kindergarten_participation_in_year(2005)
  end

  def test_participation_with_known_year
    assert_equal 0.391, @enrollment.kindergarten_participation_in_year(2010)
  end

  def test_participation_by_year
    expected =
    {2010 => 0.391, 2011 => 0.353, 2012 => 0.267}
    assert_equal expected, @enrollment.kindergarten_participation_by_year
  end

  def test_graduation_by_year
    expected =
    {2010 => 0.895, 2011 => 0.895, 2012 => 0.889,
      2013 => 0.913, 2014 => 0.898}
    assert_equal expected, @enrollment.graduation_rate_by_year
  end

  def test_graduation_rate_in_year
    assert_equal 0.889, @enrollment.graduation_rate_in_year(2012)
  end

  def test_graduation_rate_with_unknown_year
    assert_equal nil, @enrollment.graduation_rate_in_year(2000)
  end

end
