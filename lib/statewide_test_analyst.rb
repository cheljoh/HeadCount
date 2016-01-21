require_relative 'truncate'

class StatewideTestAnalyst

  def initialize(district_repository)
    @district_repository = district_repository
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
      inner_hash.values.inject(0){|counter, value| counter + (value == "N/A" ? 1 : 0)} >= 2}
      min_year, max_year = filtered.keys.min_by {|year| year}, filtered.keys.max_by {|year| year}
      if filtered.nil? || filtered.count == 0 || (min_year == max_year)
        average = "N/A"
      else
        average = growth_percentage_average(filtered, min_year, max_year, weights)
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
       average = ComputeAverage.average(growths.values)
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
      growth_by_district_all_subjects = growth_percentages_for_all_districts_in_all_subjects(grade, weights)
      name_and_growth = find_max_number(growth_by_district_all_subjects)
    else
      growth_by_district = growth_percentages_for_all_districts_by_subject(grade, subject)
      if hash[:top].nil? #for only grade and subject
        name_and_growth = find_max_number(growth_by_district)
      else #for top, grade, and subjects
        name_and_growth = find_top_n_districts(growth_by_district, n_districts)
      end
    end
    name_and_growth
  end

  def filter_hash(hash)
    hash.reject{|_key, value| value == "N/A"}
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
