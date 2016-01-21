require_relative 'district_repository'
require_relative 'truncate'
require_relative 'data_errors'

class HeadcountAnalyst


#make headcount analyst class for participation and testing
  def initialize(district_repository)
    @district_repository = district_repository
    @district_repository.load_data({
      :enrollment => {
        :kindergarten => "./data/Kindergartners in full-day program.csv",
        :high_school_graduation => "./data/High school graduation rates.csv",
      },
      :statewide_testing => {
        :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
        :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
        :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
        :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
      }
    })
  end

  def kindergarten_participation_rate_variation(district_name, hash)
    comparison_name = hash[:against]
    district_average = average_enrollment_kindergarten_rate(district_name)
    comparison_average = average_enrollment_kindergarten_rate(comparison_name)
    na_divide_and_truncate(district_average, comparison_average)
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
    compute_average(instance_val)
  end

  def get_average_enrollment_graduation_rate(district_name)
    instance = @district_repository.find_by_name(district_name)
    instance_values = instance.enrollment.graduation_rate_by_year.values
    compute_average(instance_values)
  end

  def compute_average(values)
    filtered = values.reject{|value| value == "N/A"}
    if filtered.count == 0
      return "N/A"
    end

    filtered.inject(0) do |sum, value|
      sum + value
    end/(filtered.count)
  end

  def kindergarten_participation_rate_variation_trend(district_name, hash)
    comparison_name = hash[:against]
    comparison_average = average_enrollment_kindergarten_rate(comparison_name)
    district_instance = @district_repository.find_by_name(district_name)
    district = district_instance.enrollment.kindergarten_participation_by_year
    get_trend_for_each_year(district, comparison_average)
  end

  def get_trend_for_each_year(district_hash, comparison_average)
    trends = district_hash.map do |key, value|
      [key, na_divide_and_truncate(value, comparison_average)]
    end.to_h
    trends
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

  def growth_percentages_for_all_districts_by_subject(grade, subject)
    growth_by_district = {}
    @district_repository.districts.each do |district_name, district_object|
      testing_hash = get_third_or_eighth_grade_data(district_object, grade)
      subject_only = testing_hash.map{|key, value| [key, value[subject]]}.to_h
      filtered = subject_only.reject {|_key, value| value == "N/A"}
      min_year = filtered.keys.min_by {|year| year}
      max_year = filtered.keys.max_by {|year| year}
      min_num, max_num = filtered[min_year], filtered[max_year]
      if ![max_num, min_num, max_year, min_year].include?("N/A") &&
         ![max_num, min_num, max_year, min_year].include?(nil) &&
         min_year != max_year
        total_growth =
        Truncate.truncate_number((max_num - min_num)/(max_year - min_year))
      else
        total_growth = "N/A"
      end
      growth_by_district[district_name] = total_growth
    end
    growth_by_district
  end

  def get_third_or_eighth_grade_data(district_object, grade)
    if grade == 3
        district_object.statewide_test.third_grade
    else
        district_object.statewide_test.eighth_grade
    end
  end

  def growth_percentages_for_all_districts_in_all_subjects(grade, weights = nil)
    growth_by_district = {}
    @district_repository.districts.each do |district_name, district_object|
      testing_hash = get_third_or_eighth_grade_data(district_object, grade)
      filtered = testing_hash.reject {|_key, inner_hash|
      inner_hash.values.inject(0){|counter, value| counter +
        (value == "N/A" ? 1 : 0)} >= 2}
      min_year, max_year =
      filtered.keys.min_by {|year| year}, filtered.keys.max_by {|year| year}
      if filtered.nil? || filtered.count == 0 || (min_year == max_year)
        average = "N/A"
      else
        average =
        growth_percentage_average(filtered, min_year, max_year, weights)
      end
      growth_by_district[district_name] =
      average != "N/A" ? Truncate.truncate_number(average) : "N/A"
    end
    growth_by_district
  end

  def growth_percentage_average(filtered, min_year, max_year, weights=nil)
    growths = {}
    filtered[min_year].each do |subject, value|
        upper_rate = filtered[max_year][subject]
        lower_rate = value
        if ![upper_rate, lower_rate, max_year, min_year].include?("N/A")
          growths[subject] = (upper_rate - lower_rate)/(max_year - min_year)
        end
    end
    if weights.nil?
       average = compute_average(growths.values)
    else
       average = compute_weighted_average(growths.values, weights.values)
    end
    average
  end

  def compute_weighted_average(values, weights)
    if weights.inject(0){|sum, number| sum + number} != 1.0
      incorrect_data_for_weights
    end
    average = 0
    values.each_index do |index|
      average += values[index] * weights[index]
    end
    average
  end

  def incorrect_data_for_weights
    fail UnknownDataError,
    "Grade weights must add up to zero"
  end

  def add_values(values)
    values.inject(0) {|sum, number| sum + number}
  end

  def find_max_number(district_hash)
    filtered = filter_hash(district_hash)
    filtered.max_by {|_key, number| number}
  end

  def top_statewide_test_year_over_year_growth(hash)
    valid_grades = [3, 8]
    grade = hash[:grade]
    subject = hash[:subject]
    n_districts = hash[:top]
    weights = hash[:weighting]
    if !hash.keys.include?(:grade) || !valid_grades.include?(grade)
      grade_errors(grade)
    end
    if subject.nil? && n_districts.nil? #for only grade
      growth_by_district_all_subjects =
      growth_percentages_for_all_districts_in_all_subjects(grade, weights)
      name_and_growth = find_max_number(growth_by_district_all_subjects)
    else
      growth_by_district =
      growth_percentages_for_all_districts_by_subject(grade, subject)
      if hash[:top].nil? #for only grade and subject
        name_and_growth = find_max_number(growth_by_district)
      else #for top, grade, and subjects
        name_and_growth = find_top_n_districts(growth_by_district, n_districts)
      end
    end
    name_and_growth
  end

  def filter_hash(hash)
    filtered = hash.reject{|_key, value| value == "N/A"}
  end

  def find_top_n_districts(growth_by_district, n_districts)
    filtered = filter_hash(growth_by_district)
    sorted = filtered.sort_by {|_key, value| value}
    sorted.last(n_districts)
  end

  def grade_errors(grade)
    if grade.nil?
      fail InsufficientInformationError,
      "A grade must be provided to answer this question"
    else
      fail UnknownDataError,
      "#{grade} is not a known grade"
    end
  end

end
