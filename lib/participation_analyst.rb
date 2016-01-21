require_relative 'truncate'
require_relative 'compute_average'

class ParticipationAnalyst

  def initialize(district_repository)
    @district_repository = district_repository
  end

  def kindergarten_participation_rate_variation(district_name, hash)
    comparison_name = hash[:against]
    district_average = average_enrollment_kindergarten_rate(district_name)
    comparison_average = average_enrollment_kindergarten_rate(comparison_name)
    na_divide_and_truncate(district_average, comparison_average)
  end

  def kindergarten_participation_rate_variation_trend(district_name, hash)
    comparison_name = hash[:against]
    comparison_average = average_enrollment_kindergarten_rate(comparison_name)
    district_instance = @district_repository.find_by_name(district_name)
    district = district_instance.enrollment.kindergarten_participation_by_year
    get_trend_for_each_year(district, comparison_average)
  end

  def kindergarten_participation_against_high_school_graduation(name)
    kindergarten_var =
    kindergarten_participation_rate_variation(name, :against => 'COLORADO')
    graduation_var = graduation_rate_variation(name, :against => 'COLORADO')
    na_divide_and_truncate(kindergarten_var,graduation_var)
  end

  def kindergarten_participation_correlates_with_high_school_graduation(hash)
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

  def graduation_rate_variation(district_name, hash)
    comparison_name = hash[:against]
    district_average = get_average_enrollment_graduation_rate(district_name)
    comparison_average = get_average_enrollment_graduation_rate(comparison_name)
    na_divide_and_truncate(district_average, comparison_average)
  end

  def na_divide_and_truncate(value1, value2)
    if [value1, value2].include?("N/A")
      return "N/A"
    else
        Truncate.truncate_number(value1/value2)
    end
  end

  def average_enrollment_kindergarten_rate(district_name)
    instance = @district_repository.find_by_name(district_name)
    instance_val = instance.enrollment.kindergarten_participation_by_year.values
    ComputeAverage.average(instance_val)
  end

  def get_average_enrollment_graduation_rate(district_name)
    instance = @district_repository.find_by_name(district_name)
    instance_values = instance.enrollment.graduation_rate_by_year.values
    ComputeAverage.average(instance_values)
  end

  def get_trend_for_each_year(district_hash, comparison_average)
    trends = district_hash.map do |key, value|
      [key, na_divide_and_truncate(value, comparison_average)]
    end.to_h
    trends
  end

  def statewide_correlation
    all_districts = @district_repository.districts
    correlations = all_districts.each_key.map do |district|
       correlation_for_single_district(district)
    end
    compare_true_and_false_values(correlations)
  end

  def compare_true_and_false_values(correlations)
    true_correlations = correlations.select {|value| value == true }
    number_true = true_correlations.count.to_f
    total_number_of_districts = correlations.count.to_f
    percent_true = number_true/total_number_of_districts
    percent_true > 0.7
  end

  def correlation_for_single_district(district_name)
    kindergarten_graduation_variance =
    kindergarten_participation_against_high_school_graduation(district_name)
    if kindergarten_graduation_variance == "N/A"
      return "N/A"
    else
      kindergarten_graduation_variance >= 0.6 &&
      kindergarten_graduation_variance <= 1.5
    end
  end


end
