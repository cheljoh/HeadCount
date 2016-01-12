require 'csv'

class DistrictRepository



  def find_by_name
    #contents = CSV.open "../data/Title I students.csv", headers: true, header_converters: :symbol
    Dir.foreach('../data') do |item|
      next if File.directory? item
      # require 'pry'
      # binding.pry
      contents = CSV.open "../data/#{item}", headers: true, header_converters: :symbol
      contents.each do |row|
      district = row[:location]
      puts district
      end
    end
  end

  def find_all_matching

  end

end

repo = DistrictRepository.new
repo.find_by_name
