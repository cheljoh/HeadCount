require 'pry'
require 'csv'
require_relative 'data_loader'
require_relative 'statewide_test'


class StatewideTestRepository

  attr_reader :statewide_test_objects

  def initialize
    @statewide_test_objects = {}
  end

  def load_data(hash)
    loader = DataLoader.new
    third_grade_data = loader.load_data(:testing_by_grade,
                       hash[:statewide_testing][:third_grade])
    eighth_grade_data = loader.load_data(:testing_by_grade,
                        hash[:statewide_testing][:eighth_grade])
    math_by_ethnicity = loader.load_data(:ethnicity,
                        hash[:statewide_testing][:math])
    reading_by_ethnicity = loader.load_data(:ethnicity,
                           hash[:statewide_testing][:reading])
    writing_by_ethnicity = loader.load_data(:ethnicity,
                           hash[:statewide_testing][:writing])
    third_grade_data.each_key do |district_name|
      statewide_test = StatewideTest.new(
          {:name => district_name,
          :third_grade => third_grade_data[district_name],
          :eighth_grade => eighth_grade_data[district_name],
          :math => math_by_ethnicity[district_name],
          :reading => reading_by_ethnicity[district_name],
          :writing => writing_by_ethnicity[district_name]})
      statewide_test_objects[district_name] = statewide_test

    end
  end

  def find_by_name(district_name)
    statewide_test_objects[district_name.upcase]
  end

end
