require 'csv'
require_relative 'enrollment'

class EnrollmentRepository

  attr_accessor :enrollments

  def initialize
    @enrollments = {}
  end

  def load_data(hash)
    data_path = hash[:enrollment][:kindergarten]
    contents = CSV.open data_path, headers: true, header_converters: :symbol
    hashes = {}
    contents.each do |row| #need to do input validation for district and year
      district = row[:location].upcase
      if !hashes.has_key?(district)
        hashes[district] = {}
      end
      year = row[:timeframe]
      rate = row[:data]
      hashes.fetch(district)[year] = rate
    end
    # All hashes are built, make Enrollment objects
    hashes.each do |key, value|
      enrollment = Enrollment.new({:name => key, :kindergarten_participation => value})
      enrollments[key] = enrollment
    end

  end

  def find_by_name(name)
    enrollments[name.upcase] #name is key
  end
end
