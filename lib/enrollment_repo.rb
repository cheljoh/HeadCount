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

    contents.each do |row|
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
      @enrollments[key] = enrollment
    end

    # contents.each do |row|
    #   district = row[:location]
    #
    #   if !@enrollments.has_key?(district)
    #     enrollment = Enrollment.new(district)
    #   end
    #
    #   year = row[:TimeFrame]
    #   rate = row[:Data]
    #
    #   enrollment.kindergarten_participation[year] = rate
    # end

    #   current_district = row[:location]
    #
    #   if previous_district != current_district  # save enrollment from previous district
    #     #since we've moved on to a new one
    #     enrollment = Enrollment.new({:name => previous_district,
    #       :kindergarten_participation => year_hash})
    #
    #     @enrollments[previous_district] = enrollment
    #
    #     #reset hash
    #     puts @enrollments[previous_district].name
    #     year_hash = {}
    #   end
    #
    #   year = row[:TimeFrame]
    #   rate = row[:Data]
    #   year_hash[year] = rate
    #
    #   previous_district = current_district
    # end
  end

  def find_by_name(name)
    @enrollments[name.upcase] #name is key
  end
end


# "../data/Kindergartners in full-day program.csv"

e = EnrollmentRepository.new
e.load_data({:enrollment => {:kindergarten => "../data/kindergartners in full-day program.csv"}})
enrollment = e.find_by_name("COLORADO")
rate = enrollment.kindergarten_participation["2012"]
puts rate
