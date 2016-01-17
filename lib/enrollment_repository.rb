require 'csv'
require_relative 'enrollment'
require_relative 'data_loader'

class EnrollmentRepository

  attr_reader :enrollment_objects

  def initialize
    @enrollment_objects = {}
  end

  def load_data(hash)

    loader = DataLoader.new

    graduation_hashes, kindergarten_hashes = {}
    if hash[:enrollment].has_key?(:kindergarten)
      kindergarten_hashes = loader.load_data(:participation, hash[:enrollment][:kindergarten])
    end

    if hash[:enrollment].has_key?(:high_school_graduation)
      graduation_hashes = loader.load_data(:participation, hash[:enrollment][:high_school_graduation])
    end

    kindergarten_hashes.each_key do |district_name|
      kindergarten_hash = kindergarten_hashes[district_name]
      graduation_hash = graduation_hashes[district_name]
      enrollment = Enrollment.new({:name => district_name,
                :kindergarten_participation => kindergarten_hash,
                :high_school_graduation_rates => graduation_hash})
      enrollment_objects[district_name] = enrollment
    end
  end


  def find_by_name(name)
    enrollment_objects[name.upcase] #name is key
  end
end




# @enrollment = EnrollmentRepository.new
# @enrollment.load_data({:enrollment => {:kindergarten => "../test/fixtures/Kindergartners in full-day program.csv"}})
# puts @enrollment.enrollment_objects
# puts @enrollment.find_by_name("academy 20")
# #

# er = EnrollmentRepository.new
# er.load_data({:enrollment => {:high_school_graduation => "../data/High school graduation rates.csv"}})
# er = EnrollmentRepository.new
# er.load_data({:enrollment => { :kindergarten => "../data/Kindergartners in full-day program.csv",
#     :high_school_graduation => "../data/High school graduation rates.csv"}})
# puts enrollment = er.find_by_name("ACADEMY 20")
# puts enrollment.kindergarten_participation[:timeframe]
#
# puts enrollment.kindergarten_participation_by_year
# puts enrollment.graduation_rate_by_year
#puts enrollment.graduation_rate_in_year(2010)
# => <Enrollment>


#instructor ideas:
# k_path = hash[:enrollment][:kindergarten]
# kindergarten_data_by_district = csv_data_by_district(k_path)
#
# hs_path = hash[:enrollment][:high_school_graduation]
# hs_data_by_district = csv_data_by_district(hs_path)
#
# all_districts = (kindergarten_data_by_district.keys + hs_data_by_district.keys).uniq
#
# enrollment_objs = {}
# all_districts.each do |district| #is array, needs to be hash
#   enrollment = Enrollment.new(name: district,
#                  kindergarten_participation: kindergarten_data_by_district[district],
#                  high_school_graduation_rates: hs_data_by_district[district])
#  enrollment_objects[district] = enrollment
# end

#load both or one csvs
#aggregate a unique list of districts (from district repo)
#for each district, aggregate the hs hash and k hash from csvs

# def csv_data_by_district(csv_path)
#   csv_data = CSV.open(csv_path, headers: true, header_converters: :symbol).map{|row|row.to_hash}
#   csv_data.group_by{|hash| hash.delete(:location)}
# end
