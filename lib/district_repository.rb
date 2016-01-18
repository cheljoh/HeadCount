require 'csv'
require_relative 'enrollment_repository'
require_relative 'enrollment'
require_relative 'district'
require_relative 'statewide_test'
require_relative 'statewide_test_repository'

class DistrictRepository

  attr_accessor :districts

  def initialize
    @districts = {}
  end

  def load_data(hash) #search through enrollment hash, create a new district instance for each one
    #enrollment_repo = EnrollmentRepository.new
    #enrollment_repo.load_data({:enrollment => hash[:enrollment]})

    # if !hash[:enrollment][:statewide_testing].nil?
    #   statewide_test_repo = StatewideTestRepository.new
    #   statewide_test_repo.load_data({:statewide_testing => hash[:statewide_testing]})
    #
    #   enrollment_repo.enrollment_objects.each_key do |district_name|
    #     enrollment_object = enrollment_repo.find_by_name(district_name)
    #     statewide_test_object = statewide_test_repo.find_by_name(district_name)
    #     d = District.new({:name => district_name, :enrollment => enrollment_object, :statewide_test => statewide_test_object}) #need to set enrollment to something
    #     districts[district_name] = d
    #   end
    # else
    #   enrollment_repo.enrollment_objects.each do |district_name, enrollment_object|
    #     d = District.new({:name => district_name, :enrollment => enrollment_object}) #need to set enrollment to something
    #     districts[district_name] = d
    #   end
    # end
    #load_enrollment = hash.has_key?(:enrollment)
    #load_statewide_testing = hash.has_key?(:statewide_testing)

    enrollment_repo = EnrollmentRepository.new
    if hash.has_key?(:enrollment)
      enrollment_repo.load_data({:enrollment => hash[:enrollment]})
    end

    statewide_test_repo = StatewideTestRepository.new
    if hash.has_key?(:statewide_testing)
      statewide_test_repo.load_data({:statewide_testing => hash[:statewide_testing]})
    end

    enrollment_repo.enrollment_objects.each_key do |district_name|
      enrollment_object = enrollment_repo.find_by_name(district_name)
      statewide_test_object = statewide_test_repo.find_by_name(district_name)
      d = District.new({:name => district_name, :enrollment => enrollment_object, :statewide_test => statewide_test_object}) #need to set enrollment to something
      districts[district_name] = d
    end
  end

  def find_by_name(district_name) #returns nil or instance of District
    districts[district_name.upcase]
  end

  def find_all_matching(name_fragment)
    matching_districts = districts.select do |district_name|
      district_name.include?(name_fragment.upcase)
    end
    matching_districts.values
  end

end


# When the DistrictRepository is built from the data folder, an instance of District
# should now be connected to an instance of StatewideTest:

# dr = DistrictRepository.new
# dr.load_data({
#   :enrollment => {
#     :kindergarten => "../data/Kindergartners in full-day program.csv",
#     :high_school_graduation => "../data/High school graduation rates.csv",
#   },
#   :statewide_testing => {
#     :third_grade => "../data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
#     :eighth_grade => "../data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
#     :math => "../data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
#     :reading => "../data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
#     :writing => "../data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
#   }
# })
# district = dr.find_by_name("ACADEMY 20")
# puts statewide_test = district.statewide_test
#
#
# enrollment_repo = EnrollmentRepository.new
# enrollment_repo.load_data(hash)
#
# dr = DistrictRepository.new
# dr.load_data({
#   :enrollment => {
#     :kindergarten => "../data/Kindergartners in full-day program.csv"
#   }
# })
#
# district = dr.find_by_name("ACADEMY 20")
# puts district.enrollment.kindergarten_participation_in_year(2010)




# def load_data(hash) #loads the file you want it to load
#   data_path = hash[:enrollment][:kindergarten]
#   contents = CSV.open data_path, headers: true, header_converters: :symbol
#
#   hashes = {}
#
#   contents.each do |row|
#     district = row[:location].upcase
#
#     if !hashes.has_key?(district)
#       hashes[district] = row
#     end
#
#     hashes.each do |key, value|
#       districts = District.new(:name => key, :value => value)
#       puts districts
#
#
#
#     end
#
#     #hashes.fetch(district)
#   end
#   # district objects
# end
