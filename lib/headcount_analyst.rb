require_relative 'district_repository'
require_relative 'truncate'

class HeadcountAnalyst

  def initialize(district_repository)
    @district_repository = district_repository
    @district_repository.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
#   @district_repository_both.load_data({ :enrollment => { :kindergarten => "./data/Kindergartners in full-day program.csv",
#       :high_school_graduation => "./data/High school graduation rates.csv"}})
    #if I have both paths, high school overwrites kindergarten data, district repo obj not enrollment
  end

  def kindergarten_participation_rate_variation(district_name, hash)
    comparison_name = hash[:against]
    district_average = get_average_enrollment_rate(district_name)
    comparison_average = get_average_enrollment_rate(comparison_name)
    average = district_average/comparison_average
    Truncate.truncate_number(average)
  end

  def get_average_enrollment_rate(district_name)
    instance = @district_repository.find_by_name(district_name)
    instance_values = instance.enrollment.kindergarten_participation_by_year.values
    average_value = compute_average(instance_values)
  end

  def compute_average(values)
    values.inject(0) do |sum, value|
      sum + value
    end/(values.count)
  end

  def kindergarten_participation_rate_variation_trend(district_name, hash)
    comparison_name = hash[:against]
    comparison_average = get_average_enrollment_rate(comparison_name)
    district_instance = @district_repository.find_by_name(district_name)
    district_hash = district_instance.enrollment.kindergarten_participation_by_year
    get_trend_for_each_year(district_hash, comparison_average)
  end

  def get_trend_for_each_year(district_hash, comparison_average)
    trends = district_hash.map do |key, value|
      [key, Truncate.truncate_number(value/comparison_average)]
    end.to_h
    trends
  end

  def kindergarten_participation_against_high_school_graduation(district_name)
  #   average_enrollment_kindergarten = get_average_enrollment_rate(district_name)
  #   #pulling out high school rates not kindergarten, maybe because district repo object and not enrollment?
  #
  end

end

# dr = DistrictRepository.new
# headcount_analyst = HeadcountAnalyst.new(dr)
# puts headcount_analyst.kindergarten_participation_against_high_school_graduation("Academy 20")

# There's thinking that kindergarten participation has long-term effects. Given our limited data set,
# let's assume that variance in kindergarten rates for a given district is similar to when current high school
# students were kindergarten age (~10 years ago). Let's compare the variance in kindergarten participation
# and high school graduation.
#
# For a single district:
#
# ha.kindergarten_participation_against_high_school_graduation('ACADEMY 20') # => 1.234
# Call kindergarten variation the result of dividing the district's kindergarten participation by the
# statewide average. Call graduation variation the result of dividing the district's graduation rate by
# the statewide average. Divide the kindergarten variation by the graduation variation to find the kindergarten-graduation
#  variance.
#
# If this result is close to 1, then we'd infer that the kindergarten variation and the graduation
# variation are closely related.


 #=> {2009 => 0.766, 2010 => 0.566, 2011 => 0.46 }
# dr = DistrictRepository.new
# @headcount_analyst = HeadcountAnalyst.new(dr)
# rate = @headcount_analyst.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
# puts rate
