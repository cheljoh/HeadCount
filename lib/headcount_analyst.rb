require_relative 'district_repository'
require_relative 'truncate'
require_relative 'data_errors'

class HeadcountAnalyst

  def initialize(district_repository)
    @district_repository = DistrictRepository.new
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

  def growth_percentages_for_all_districts_by_subject(grade, subject)
    growth_by_district = {}
    @district_repository.districts.each do |district_name, district_object|
      testing_hash = get_third_or_eighth_grade_data(district_object, grade)
      min_year, max_year = testing_hash.keys.min_by {|year| year}, testing_hash.keys.max_by {|year| year}
      min_results, max_results = testing_hash[min_year][subject], testing_hash[max_year][subject]
      total_growth = (max_results - min_results)/(max_year - min_year)
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

  def growth_percentages_for_all_districts_in_all_subjects(grade, weights=nil)
    growth_by_district = {}
    @district_repository.districts.each do |district_name, district_object|
      testing_hash = get_third_or_eighth_grade_data(district_object, grade)
      min_year, max_year = testing_hash.keys.min_by {|year| year}, testing_hash.keys.max_by {|year| year}

      growths = {}
      testing_hash[min_year].each do |subject, value|
        growths[subject] = (testing_hash[max_year][subject] - value)/(max_year - min_year)
      end

      if weights.nil?
        growth_by_district[district_name] = compute_average(growths.values)
      else
        growth_by_district[district_name] = compute_weighted_average(growths.values, weights.values)
      end
    end

    growth_by_district
  end

  def compute_weighted_average(values, weights)
    if weights.inject(0){|sum, number| sum + number} != 1.0
      raise UnknownDataError
    end
    average = 0
    values.each_index do |index|
      average += values[index]*weights[index]
    end
    average
  end

  def add_values(values)
    values.inject(0) {|sum, number| sum + number}
  end

  def find_max_number(district_hash)
    district_hash.max_by {|key, number| number}
  end

  def top_statewide_test_year_over_year_growth(hash)
    valid_grades = [3, 8]
    grade = hash[:grade]
    subject  = hash[:subject]
    n_districts = hash[:top]
    weights = hash[:weighting]

    testing_hash = {}
    if !valid_grades.include?(grade)
      insufficient_information_error(grade)
    end
    if subject.nil? && n_districts.nil?
      growth_by_district_all_subjects = growth_percentages_for_all_districts_in_all_subjects(grade, weights)
      return find_max_number(growth_by_district_all_subjects) #.max_by {|key, number| number}
    else
      growth_by_district = growth_percentages_for_all_districts_by_subject(grade, subject)
    end
    if hash[:top].nil?
      find_max_number(growth_by_district) #.max_by {|key, number| number}
    else
      find_top_n_districts(growth_by_district, n_districts)
    end
  end

  def find_top_n_districts(growth_by_district, n_districts)
    sorted = growth_by_district.sort_by {|key, value| value}
    sorted.last(n_districts)
  end

  def insufficient_information_error(grade)
    if grade.nil?
      fail InsufficientInformationError
      "#{InsufficientInformationError}: A grade must be provided to answer this question"
    else
      fail UnknownDataError
      "#{UnknownDataError}: #{grade} is not a known grade"
    end
  end

end




# dr = DistrictRepository.new
# headcount_analyst = HeadcountAnalyst.new(dr)
#puts headcount_analyst.top_statewide_test_year_over_year_growth(grade: 8, subject: :writing)
#puts headcount_analyst.top_statewide_test_year_over_year_growth(grade: 3, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
#puts headcount_analyst.top_statewide_test_year_over_year_growth(grade: 3)
#puts headcount_analyst.top_statewide_test_year_over_year_growth(grade: 3, :weighting => {:math => 0.33, :reading => 0.33, :writing => 0.33})



# puts headcount_analyst.top_statewide_test_year_over_year_growth(grade: 3, top: 3, subject: :math)
#=> [['top district name', growth_1], ['second district name', growth_2], ['third district name', growth_3]]



# puts headcount_analyst.kindergarten_participation_correlates_with_high_school_graduation(for: 'academy 20')
# puts headcount_analyst.kindergarten_participation_correlates_with_high_school_graduation(:for => 'STATEWIDE')
# puts headcount_analyst.kindergarten_participation_correlates_with_high_school_graduation(:across => ["ACADEMY 20", 'PARK (ESTES PARK) R-3', 'YUMA SCHOOL DISTRICT 1'])



 #=> {2009 => 0.766, 2010 => 0.566, 2011 => 0.46 }
# dr = DistrictRepository.new
# @headcount_analyst = HeadcountAnalyst.new(dr)
# rate = @headcount_analyst.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
# puts rate
