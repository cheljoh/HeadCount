require 'csv'
require_relative 'enrollment'

class EnrollmentRepository

  attr_accessor :enrollment_objects

  def initialize
    @enrollment_objects = {}
  end

  def load_data(hash)
    data_path = hash[:enrollment][:kindergarten] #key of  hash
    contents = CSV.open data_path, headers: true, header_converters: :symbol

    # First, construct hashes which = {district => {year => rate}}
    hashes = {}
    contents.each do |row| #need to do input validation for district and year
      district = row[:location].upcase
      if !hashes.has_key?(district)
        hashes[district] = {}
      end
      year = row[:timeframe].to_i
      rate = row[:data].to_f
      hashes.fetch(district)[year] = rate
    end

    # All hashes are built, make Enrollment objects which require a
    # {district => {year => rate}} hash to construct
    hashes.each do |district_name, participation_hash|
      enrollment = Enrollment.new({:name => district_name, :kindergarten_participation => participation_hash}) #inner hash is kindergarten_participation
      enrollment_objects[district_name] = enrollment
    end

  end

  def find_by_name(name)
    enrollment_objects[name.upcase] #name is key
  end
end

# @enrollment = EnrollmentRepository.new
# @enrollment.load_data({:enrollment => {:kindergarten => "../test/fixtures/Kindergartners in full-day program.csv"}})
# puts @enrollment.enrollments
#puts @enrollment.find_by_name("hello")
