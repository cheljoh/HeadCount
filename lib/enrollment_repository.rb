require 'csv'
require_relative 'enrollment'

class EnrollmentRepository

  attr_reader :enrollment_objects

  def initialize
    @enrollment_objects = {}
  end

  def load_data(hash)
    data_path = hash[:enrollment][:kindergarten]#key of  hash
    if !hash[:enrollment][:high_school_graduation].nil?
      data_path = hash[:enrollment][:high_school_graduation]
      graduation_hashes = load_path(data_path)
    end

    participation_hashes = load_path(data_path)

    participation_hashes.each_key do |district_name|
      participation_hash = participation_hashes[district_name]
      if !graduation_hashes.nil?
        graduation_hash = graduation_hashes[district_name]
        enrollment = Enrollment.new({:name => district_name, :kindergarten_participation => participation_hash,
                                     :high_school_graduation_rates => graduation_hash})
      else
        enrollment = Enrollment.new({:name => district_name, :kindergarten_participation => participation_hash})
                                   #:high_school_graduation_rates => graduation_hash}) #inner hash is kindergarten_participation
      end

      enrollment_objects[district_name] = enrollment
    end
  end

  def load_path(data_path) # return participation_hash
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

      return hashes
  end

  def find_by_name(name)
    enrollment_objects[name.upcase] #name is key
  end
end

# @enrollment = EnrollmentRepository.new
# @enrollment.load_data({:enrollment => {:kindergarten => "../test/fixtures/Kindergartners in full-day program.csv"}})
# #puts @enrollment.enrollment_objects
# puts @enrollment.find_by_name("academy 20")
#
# er = EnrollmentRepository.new
# er.load_data({:enrollment => { :kindergarten => "../data/Kindergartners in full-day program.csv",
#     :high_school_graduation => "../data/High school graduation rates.csv"}})
# enrollment = er.find_by_name("ACADEMY 20")
# puts enrollment
#
# puts enrollment.kindergarten_participation_by_year
# puts enrollment.graduation_rate_by_year
#puts enrollment.graduation_rate_in_year(2010)
# => <Enrollment>
