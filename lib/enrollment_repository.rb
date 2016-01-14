require 'csv'
require_relative 'enrollment'

class EnrollmentRepository

  attr_accessor :enrollment_objects

  def initialize
    @enrollment_objects = {}
  end

  def load_data(hash)
    data_path = hash[:enrollment][:kindergarten]#key of  hash
    data_path2 = hash[:enrollment][:high_school_graduation]


    participation_hashes = load_kindergarten(data_path)
    graduation_hashes = load_high_school(data_path2)

    # All hashes are built, make Enrollment objects which require a
    # {district => {year => rate}} hash to construct
    # participation_hash.each do |district_name, participation_hash|
    #   enrollment = Enrollment.new({:name => district_name, :kindergarten_participation => participation_hash}) #inner hash is kindergarten_participation
    #   enrollment_objects[district_name] = enrollment
    # end
    #
    # graduation_hash.each do |district_name, graduation_hash|
    #   enrollment = Enrollment.new({:name => district_name, :high_school_graduation_rates => graduation_hash}) #inner hash is kindergarten_participation
    #   enrollment_objects[district_name] = enrollment
    # end

    participation_hashes.each_key do |district_name|
      participation_hash = participation_hashes[district_name]
      graduation_hash = graduation_hashes[district_name]

      enrollment = Enrollment.new({:name => district_name, :kindergarten_participation => participation_hash,
                                   :high_school_graduation_rates => graduation_hash}) #inner hash is kindergarten_participation

      enrollment_objects[district_name] = enrollment
    end
  end

  def load_kindergarten(data_path)
    # return participation_hash
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
        # require 'pry'
        # binding.pry
      end

      return hashes
  end

  def load_high_school(data_path)
    # return participation_hash
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
        # require 'pry'
        # binding.pry
      end

      return hashes
  end

  def find_by_name(name)
    enrollment_objects[name.upcase] #name is key
  end
end

# @enrollment = EnrollmentRepository.new
# @enrollment.load_data({:enrollment => {:kindergarten => "../test/fixtures/Kindergartners in full-day program.csv"}})
# puts @enrollment.enrollments
#puts @enrollment.find_by_name("hello")

er = EnrollmentRepository.new
er.load_data({:enrollment => { :kindergarten => "../data/Kindergartners in full-day program.csv",
    :high_school_graduation => "../data/High school graduation rates.csv"}})
enrollment = er.find_by_name("ACADEMY 20")
#puts enrollment
#puts enrollment

puts enrollment.graduation_rate_by_year
puts enrollment.graduation_rate_in_year(2010)
# => <Enrollment>
