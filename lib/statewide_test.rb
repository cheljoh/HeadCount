require_relative 'data_errors'

class StatewideTest

attr_accessor :name, :third_grade, :eighth_grade, :math, :reading, :writing

  def initialize(hash)
    @name = hash[:name]
    @third_grade = hash[:third_grade]
    @eighth_grade = hash[:eighth_grade]
    @math = hash[:math]
    @reading = hash[:reading]
    @writing = hash[:writing]
  end

  def proficient_by_grade(grade) #unkown data error with unknown grade. Method returns a hash grouped by year that points to subjects
    if grade == 3
      third_grade
    elsif grade == 8
      eighth_grade
    else
      #raise ArgumentError #should be unknown data error, make own class?
      unknown_data_error
    end
  end

  def proficient_by_race_or_ethnicity(ethnicity) #right now, race is string
    year_hash, data_by_subject = {}
    if valid_ethnicity?(ethnicity)
      reading_scores, writing_scores, math_scores = reading[ethnicity], writing[ethnicity], math[ethnicity]
      math_scores.each_key do |key|
        data_by_subject = {:reading => reading_scores[key], :writing => writing_scores[key], :math => math_scores[key]}
        year_hash[key] = data_by_subject
      end
      year_hash
    else
      #raise ArgumentError #UnknownRaceError
      unknown_race_error
    end
  end

  def valid_ethnicity?(ethnicity)
    valid_ethnicities = [:asian, :black, :pacific_islander, :hispanic, :native_american, :two_or_more, :white]
    valid_ethnicities.include?(ethnicity)
  end

  def valid_subject?(subject)
    valid_subjects = [:math, :reading, :writing]
    valid_subjects.include?(subject)
  end

  def valid_grade?(grade)
    valid_grades = [3, 8]
    valid_grades.include?(grade)
  end

  def valid_year?(year)
    valid_years = [2008, 2009, 2010, 2011, 2012, 2013, 2014]
    valid_years.include?(year)
  end

  def proficient_for_subject_by_grade_in_year(subject, grade, year)
    if valid_subject?(subject) && valid_grade?(grade) && valid_year?(year)
      get_data_by_grade_and_year_and_subject(subject, grade, year)
    else
      #raise ArgumentError #UnknownDataError
      unknown_data_error
    end
  end

  def get_data_by_grade_and_year_and_subject(subject, grade, year)
    if grade == 3
      third_grade[year][subject]
    elsif grade == 8
      eighth_grade[year][subject]
    end
  end

  def get_data_by_subject_and_ethnicity_and_year(subject, ethnicity, year)
    if subject == :math
      math[ethnicity][year]
    elsif subject == :reading
      reading[ethnicity][year]
    elsif subject == :writing
      writing[ethnicity][year]
    end
  end

  def proficient_for_subject_by_race_in_year(subject, ethnicity, year)
    if valid_ethnicity?(ethnicity) && valid_subject?(subject) && valid_year?(year)
      get_data_by_subject_and_ethnicity_and_year(subject, ethnicity, year)
    else
      #raise ArgumentError #UnknownDataError
      unknown_data_error
    end

  end

  def unknown_data_error
    fail UnknownDataError
  end

  def unknown_race_error
    fail UnknownRaceError
  end

end
