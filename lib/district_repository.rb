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

  def load_data(hash)

    enrollment_repo = EnrollmentRepository.new
    if hash.has_key?(:enrollment)
      enrollment_repo.load_data({:enrollment => hash[:enrollment]})
    end

    statewide_test_repo = StatewideTestRepository.new
    if hash.has_key?(:statewide_testing)
      statewide_test_repo.load_data(
        {:statewide_testing => hash[:statewide_testing]})
    end

    enrollment_repo.enrollment_objects.each_key do |district_name|
      enrollment_object = enrollment_repo.find_by_name(district_name)
      statewide_test_object = statewide_test_repo.find_by_name(district_name)
      d = District.new(
        {:name => district_name,
        :enrollment => enrollment_object,
        :statewide_test => statewide_test_object})
      districts[district_name] = d
    end
  end

  def find_by_name(district_name)
    districts[district_name.upcase]
  end

  def find_all_matching(name_fragment)
    matching_districts = districts.select do |district_name|
      district_name.include?(name_fragment.upcase)
    end
    matching_districts.values
  end

end
