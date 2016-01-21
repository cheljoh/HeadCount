require 'csv'
require_relative 'enrollment'
require_relative 'data_loader'

class EnrollmentRepository

  attr_reader :enrollment_objects

  def initialize
    @enrollment_objects = {}
  end

  def load_data(hash)
    kindergarten_hashes = load_paths(hash, :kindergarten)
    graduation_hashes = load_paths(hash, :high_school_graduation)
    kindergarten_hashes.each_key do |district_name|
      kindergarten_hash = kindergarten_hashes[district_name]
      graduation_hash = graduation_hashes[district_name]
      enrollment = Enrollment.new({:name => district_name,
                :kindergarten_participation => kindergarten_hash,
                :high_school_graduation_rates => graduation_hash})
      enrollment_objects[district_name] = enrollment
    end
  end

  def load_paths(hash, symbol)
    loader = DataLoader.new
    enrollment_data = {}
    if hash[:enrollment].has_key?(symbol)
      enrollment_data =
      loader.load_data(:participation, hash[:enrollment][symbol])
    end
    enrollment_data
  end


  def find_by_name(name)
    enrollment_objects[name.upcase]
  end
end
