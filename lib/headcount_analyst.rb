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
    district_average = get_average_enrollment_kindergarten_rate(district_name)
    comparison_average = get_average_enrollment_kindergarten_rate(comparison_name)
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
    comparison_average = get_average_enrollment_kindergarten_rate(comparison_name)
    district_instance = @district_repository.find_by_name(district_name)
    district_hash = district_instance.enrollment.kindergarten_participation_by_year
    get_trend_for_each_year(district_hash, comparison_average)
  end

  def get_trend_for_each_year(district_hash, comparison_average)
    trends = district_hash.map do |key, value|
      [key, na_divide_and_truncate(value, comparison_average)]
    end.to_h
    trends
  end

  def kindergarten_participation_against_high_school_graduation(district_name)
    kindergarten_variation = kindergarten_participation_rate_variation(district_name, :against => 'COLORADO')
    graduation_variation = graduation_rate_variation(district_name, :against => 'COLORADO')
    na_divide_and_truncate(kindergarten_variation,graduation_variation)
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
    percent_true > 0.7
  end

  def correlation_for_single_district(district_name)
    kindergarten_graduation_variance = kindergarten_participation_against_high_school_graduation(district_name)
    if kindergarten_graduation_variance == "N/A"
      return "N/A"
    else
      kindergarten_graduation_variance >= 0.6 && kindergarten_graduation_variance <= 1.5
    end
  end

  def growth_percentages_for_all_districts_by_subject(grade, subject)
    growth_by_district = {}
    @district_repository.districts.each do |district_name, district_object|
      testing_hash = get_third_or_eighth_grade_data(district_object, grade)
      filtered = testing_hash.reject {|_or_key, value| value == "N/A"}
      min_year, max_year = filtered.keys.min_by {|year| year}, filtered.keys.max_by {|year| year}
      min_results, max_results = filtered[min_year][subject], filtered[max_year][subject]

      if ![max_results, min_results, max_year, min_year].include?("N/A")
        total_growth = Truncate.truncate_number((max_results - min_results)/(max_year - min_year))
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

  def growth_percentages_for_all_districts_in_all_subjects(grade, weights=nil)
    growth_by_district = {}
    @district_repository.districts.each do |district_name, district_object|
      testing_hash = get_third_or_eighth_grade_data(district_object, grade)
      filtered = testing_hash.reject {|key, inner_hash| inner_hash.values.all?{|value| value == "N/A"}}
      min_year, max_year = filtered.keys.min_by {|year| year}, filtered.keys.max_by {|year| year}
      if filtered.nil? || filtered.count == 0 || (min_year == max_year)
        average = "N/A"
      else
        average = growth_percentage_average(filtered, min_year, max_year, weights)
      end
      growth_by_district[district_name] =  average != "N/A" ? Truncate.truncate_number(average) : "N/A"
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
    filtered = district_hash.reject{|key, value| value == "N/A"}
    filtered.max_by {|key, number| number}
  end

  def top_statewide_test_year_over_year_growth(hash)
    valid_grades = [3, 8]
    grade = hash[:grade]
    subject = hash[:subject]
    n_districts = hash[:top]
    weights = hash[:weighting]
    if !valid_grades.include?(grade)
      insufficient_information_error(grade)
    end
    if subject.nil? && n_districts.nil? #for only grade
      growth_by_district_all_subjects = growth_percentages_for_all_districts_in_all_subjects(grade, weights)
      name_and_growth = find_max_number(growth_by_district_all_subjects) #.max_by {|key, number| number}
    else
      growth_by_district = growth_percentages_for_all_districts_by_subject(grade, subject)
      if hash[:top].nil? #for only grade and subject
        name_and_growth = find_max_number(growth_by_district) #.max_by {|key, number| number}
      else #for top, grade, and subjects
        name_and_growth = find_top_n_districts(growth_by_district, n_districts)
      end
    end
    name_and_growth
  end

  def find_top_n_districts(growth_by_district, n_districts) #need to change key here
    sorted = growth_by_district.sort_by {|key, value| value}
    sorted.last(n_districts)
  end

  def insufficient_information_error(grade)
    if grade.nil?
      fail InsufficientInformationError
      "#{InsufficientInformationError}: A grade must be provided to answer this question"
    else
      fail UnknownDataError #this is apparentely unreachable
      "#{UnknownDataError}: #{grade} is not a known grade"
    end
  end

end




#dr = DistrictRepository.new
#headcount_analyst = HeadcountAnalyst.new(dr)
#puts headcount_analyst.top_statewide_test_year_over_year_growth(grade: 8, subject: :writing)
#puts headcount_analyst.top_statewide_test_year_over_year_growth(grade: 3, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
#puts headcount_analyst.top_statewide_test_year_over_year_growth(grade: 8)
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
