require './lib/compute_average'
require_relative 'test_helper'

class ComputeAverageTest < Minitest::Test

  def test_does_it_compute_normal_average
    values = [1, 2, 3, 4, 5]
    assert_equal 3, ComputeAverage.average(values)
  end

  def test_does_it_return_na_for_empty_array
    values = []
    assert_equal "N/A", ComputeAverage.average(values)
  end

  def test_does_it_reject_na_values
    values = [1, 2, 3, "N/A", 4, 5, "N/A"]
    assert_equal 3, ComputeAverage.average(values)
  end

end
