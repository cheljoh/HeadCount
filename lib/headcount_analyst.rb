require_relative 'district_repository'
require_relative 'truncate'

class HeadcountAnalyst

  def initialize(district_repository)
    @district_repository = district_repository
    @district_repository.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergartners in full-day program.csv"}})
  end

  def kindergarten_participation_rate_variation(district_name, hash)
    comparison = hash[:against]
    district_average = get_enrollment_values(district_name)
    comparison_average = get_enrollment_values(comparison)
    average = district_average/comparison_average
    Truncate.truncate_number(average)
  end

  def get_enrollment_values(value)
    instance = @district_repository.find_by_name(value)
    instance_hash = instance.enrollment.kindergarten_participation_by_year
    instance_values = instance_hash.values
    average_values = get_average_values(instance_values)
  end

  def get_average_values(average_values)
    average_values.inject(0) do |sum, value|
      sum + value
    end/(average_values.count)
  end

end
# 
# dr = DistrictRepository.new
# ha = HeadcountAnalyst.new(dr)
#
# puts ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO') # => 0.766
