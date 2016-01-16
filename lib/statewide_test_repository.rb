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
    third_grade_data = loader.load_data(:third_grade, hash[:statewide_testing][:third_grade])
    eighth_grade_data = loader.load_data(:eighth_grade, hash[:statewide_testing][:eighth_grade])
    math_by_ethnicity = loader.load_data(:math, hash[:statewide_testing][:math])
    reading_by_ethnicity = loader.load_data(:reading, hash[:statewide_testing][:reading])
    writing_by_ethnicity = loader.load_data(:writing, hash[:statewide_testing][:writing])
    third_grade_data.each_key do |district_name|
      # dont like using keys from one hash- make master list of districts?
      statewide_test = StatewideTest.new({:name => district_name, :third_grade => third_grade_data[district_name], :eighth_grade => eighth_grade_data[district_name],
                                          :math => math_by_ethnicity[district_name], :reading => reading_by_ethnicity[district_name], :writing => writing_by_ethnicity[district_name]})
      statewide_test_objects[district_name] = statewide_test

    end
    binding.pry
  end

  def find_by_name(district_name) #returns nil or instance of StatewideTest with case insensitive search
    statewide_test_objects[district_name.upcase]
  end

end


# str = StatewideTestRepository.new
# str.load_data({
#   :statewide_testing => {
#     :third_grade => "../data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
#     :eighth_grade => "../data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
#     :math => "../data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
#     :reading => "../data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
#     :writing => "../data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
#   }
# })
# #
# # #puts str.statewide_test_objects
# statewide_test = str.find_by_name("ACADEMY 20")
# puts statewide_test.third_grade
# puts statewide_test.eighth_grade
# puts statewide_test.reading
# puts statewide_test.writing
# puts statewide_test.math
#binding.pry
# => <StatewideTest>
#
# statewide_test = StatewideTest.new
# statewide_test.proficient_by_grade(3)
