require 'csv'

class DistrictRepository

  attr_accessor :district

  def initalize
    @district = District.new
  end

  # Dir.foreach('../data') do |item| #prints out name of each district
  #   next if File.directory? item
  #   contents = CSV.open "../data/#{item}", headers: true, header_converters: :symbol
  #   contents.each do |row|
  #   district = row[:location]
  #   puts district
  #   end
  # end

  def district_hash
    district = Hash.new
    district[:enrollment] = gather_enrollment_files
    #district[:statewide_testing] =>
    #district[:economic_profile] =>

  end

  def gather_enrollment_files
    enrollment_files = []
    enrollment_files = ["../data/dropout rates by race and ethnicity.csv",
    "../data/kindergartners in full-day program.csv", "../data/onlne pupil enrollment.csv",
    "../data/pupil enrollment.csv", "../data/pupil enrollment by race_ethnicity.csv",
    "../data/high school graduation rates.csv", "../data/special education.csv"]
  end

  def load_data(key1, key2) #loads the file you want it to load

  end

  def find_by_name(district_name) #returns nil or instance of District

  end

  def find_all_matching #returns [] or one or more matches whcih contain the supplied name fragment

  end

end

repo = DistrictRepository.new
puts repo.district_hash
