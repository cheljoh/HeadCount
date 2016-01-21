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
    try_load(hash, :enrollment, enrollment_repo)
    statewide_test_repo = StatewideTestRepository.new
    try_load(hash, :statewide_testing, statewide_test_repo)
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

  def try_load(hash, key, object)
    if hash.has_key?(key)
      object.load_data({key => hash[key]})
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
