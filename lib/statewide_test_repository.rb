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
    #all_districts = (third_grade_data.keys + math_by_ethnicity.keys).uniq
    require 'pry'
    binding.pry
    # all_districts = (kindergarten_data_by_district.keys + hs_data_by_district.keys).uniq
    third_grade_data.each_key do |district_name|
      # dont like using keys from one hash- make master list of districts?
      #need to use block var
      statewide_test = StatewideTest.new({:third_grade => third_grade_data, :eighth_grade => eighth_grade_data,
                                          :math => math_by_ethnicity, :reading => reading_by_ethnicity, :writing => writing_by_ethnicity})
      statewide_test_objects[district_name] = statewide_test
    end

    # district_hashes = {}
    # scores_hash = {}
    # data_path = hash[:statewide_testing][:third_grade]
    # #contents = data_path.values.map do |path|
    #   data = CSV.open data_path, headers: true, header_converters: :symbol
    #   data.each do |row|
    #     district_name = row[:location].upcase
    #     if !district_hashes.has_key?(district_name)
    #         district_hashes[district_name] = {}
    #          #binding.pry
    #     end
    #     year = row[:timeframe].to_i
    #     rate = row[:data].to_f
    #     subject = row[:score]
    #     scores_hash[subject] = rate
    #
    #     district_hashes.fetch(district_name)[year] = scores_hash
    #       #binding.pry
    #   end
    # #end
    #
    # district_hashes



  #   graduation_hashes = load_path(data_path_grad)
  #
  #   participation_hashes = load_path(data_path)
  #   # require 'pry'
  #   # binding.prys
  #
  #
  #   participation_hashes.each_key do |district_name|
  #     participation_hash = participation_hashes[district_name]
  #     if !graduation_hashes.nil?
  #       graduation_hash = graduation_hashes[district_name]
  #       enrollment = Enrollment.new({:name => district_name, :kindergarten_participation => participation_hash,
  #                                    :high_school_graduation_rates => graduation_hash})
  #     else
  #       enrollment = Enrollment.new({:name => district_name, :kindergarten_participation => participation_hash})
  #                                  #:high_school_graduation_rates => graduation_hash}) #inner hash is kindergarten_participation
  #     end
  #     enrollment_objects[district_name] = enrollment
  #   end
  # end
  #
  # def load_path(data_path) # return participation_hash
  #     contents = CSV.open data_path, headers: true, header_converters: :symbol
  #     # First, construct hashes which = {district => {year => rate}}
  #     hashes = {}
  #     contents.each do |row| #need to do input validation for district and year
  #       district_name = row[:location].upcase
  #       if !hashes.has_key?(district_name)
  #         hashes[district_name] = {}
  #       end
  #
  #       if row[:data] != "N/A"
  #         year = row[:timeframe].to_i
  #         rate = row[:data].to_f
  #         hashes.fetch(district_name)[year] = rate
  #       end
  #     end
  #
  #     cleaned_hashes = clean_bad_data(hashes)
  #     return cleaned_hashes


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
#
# #puts str.statewide_test_objects
# puts str.find_by_name("ACADEMY 20")
# => <StatewideTest>
#
# statewide_test = StatewideTest.new
# statewide_test.proficient_by_grade(3)
