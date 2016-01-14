require_relative 'district_repository'
require_relative 'truncate'

class HeadcountAnalyst

  def initialize(district_repository)
    @district_repository = district_repository
    @district_repository.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
  end                                                               #should this use test fixtures?

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

end


 #=> {2009 => 0.766, 2010 => 0.566, 2011 => 0.46 }
# dr = DistrictRepository.new
# @headcount_analyst = HeadcountAnalyst.new(dr)
# rate = @headcount_analyst.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
# puts rate
