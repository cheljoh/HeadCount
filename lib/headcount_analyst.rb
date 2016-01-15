require_relative 'district_repository'
require_relative 'truncate'

class HeadcountAnalyst

  def initialize(district_repository)
    @district_repository = district_repository
    @district_repository.load_data({ :enrollment => { :kindergarten => "./data/Kindergartners in full-day program.csv",
      :high_school_graduation => "./data/High school graduation rates.csv"}})
  end

  def kindergarten_participation_rate_variation(district_name, hash)
    comparison_name = hash[:against]
    district_average = get_average_enrollment_kindergarten_rate(district_name)
    comparison_average = get_average_enrollment_kindergarten_rate(comparison_name)
    average = district_average/comparison_average
    Truncate.truncate_number(average)
  end

  def graduation_rate_variation(district_name, hash)
    comparison_name = hash[:against]
    district_average = get_average_enrollment_graduation_rate(district_name)
    comparison_average = get_average_enrollment_graduation_rate(comparison_name)
    average = district_average/comparison_average
    Truncate.truncate_number(average)
  end

  def get_average_enrollment_kindergarten_rate(district_name)
    instance = @district_repository.find_by_name(district_name)
    instance_values = instance.enrollment.kindergarten_participation_by_year.values
    compute_average(instance_values)
  end

  def get_average_enrollment_graduation_rate(district_name)
    instance = @district_repository.find_by_name(district_name)
    instance_values = instance.enrollment.graduation_rate_by_year.values
    compute_average(instance_values)
  end

  def compute_average(values)
    # require 'pry'
    # binding.pry
    values.inject(0) do |sum, value|
      sum + value
    end/(values.count)
  end

  def kindergarten_participation_rate_variation_trend(district_name, hash)
    comparison_name = hash[:against]
    comparison_average = get_average_enrollment_kindergarten_rate(comparison_name)
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
    kindergarten_variation = kindergarten_participation_rate_variation(district_name, :against => 'COLORADO')
    graduation_variation = graduation_rate_variation(district_name, :against => 'COLORADO')
    Truncate.truncate_number(kindergarten_variation/graduation_variation)
  end

  def kindergarten_participation_correlates_with_high_school_graduation(hash)
    #hash.keys
    #comparison = hash[:for]
    if hash.values != ['STATEWIDE'] && hash.keys == [:for]
      correlation = correlation_for_single_district(hash[:for])
    elsif hash.values == ["STATEWIDE"]
      correlation = statewide_correlation
    elsif hash.values.class == Array
      districts = hash[:across]
      correlations = districts.map do |district|
          correlation_for_single_district(district)
      end
      correlation = compare_true_and_false_values(correlations)
    end
    correlation
  end

  def statewide_correlation
    all_districts = @district_repository.districts
    correlations = all_districts.each_key.map do |district|
       correlation_for_single_district(district) #fails on east yuma county because of NA
    end
    compare_true_and_false_values(correlations)
  end

  def compare_true_and_false_values(correlations)
    true_correlations = correlations.select {|value| value == true }
    number_true, total_number_of_districts = true_correlations.count.to_f, correlations.count.to_f
    percent_true = number_true/total_number_of_districts
    correlation = (percent_true > 0.7)
  end

  def correlation_for_single_district(district_name)
    kindergarten_graduation_variance = kindergarten_participation_against_high_school_graduation(district_name)
    correlation = true if kindergarten_graduation_variance >= 0.6 && kindergarten_graduation_variance <= 1.5
    correlation
  end

end




#dr = DistrictRepository.new
#headcount_analyst = HeadcountAnalyst.new(dr)
# puts headcount_analyst.kindergarten_participation_correlates_with_high_school_graduation(for: 'academy 20')
# puts headcount_analyst.kindergarten_participation_correlates_with_high_school_graduation(:for => 'STATEWIDE')
#puts headcount_analyst.kindergarten_participation_correlates_with_high_school_graduation(:across => ["ACADEMY 20", 'PARK (ESTES PARK) R-3', 'YUMA SCHOOL DISTRICT 1'])



 #=> {2009 => 0.766, 2010 => 0.566, 2011 => 0.46 }
# dr = DistrictRepository.new
# @headcount_analyst = HeadcountAnalyst.new(dr)
# rate = @headcount_analyst.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
# puts rate
