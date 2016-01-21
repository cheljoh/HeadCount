require_relative 'truncate'

class DataLoader


  def load_data(category, path)
    data = {}
    contents = CSV.open path, headers: true, header_converters: :symbol
    contents.each do |row|
        data = add_row(category, data, row)
    end
    data
  end

  def add_row(category, data, row)
    if category == :testing_by_grade
      testing_by_grade_row(data, row)
    elsif category == :ethnicity
      subject_proficiency_by_ethnicity_row(data, row)
    elsif category == :participation
      participation_rates(data, row)
    end
  end

  def testing_by_grade_row(data, row) #need to have something for N/A
    district_name = row[:location].upcase
    data = initialize_new_key(district_name, data)
    year = row[:timeframe].to_i
    begin
      rate = Truncate.truncate_number(Float(row[:data]))
    rescue
      rate = "N/A"
    end
    subject = row[:score].to_sym.downcase
    year_hash = initialize_new_key(year, data.fetch(district_name))
    year_hash[year][subject] = rate
    data[district_name] = year_hash
    data
  end

  def subject_proficiency_by_ethnicity_row(data, row)
    district_name = row[:location].upcase
    data = initialize_new_key(district_name, data)
    year = row[:timeframe].to_i
    begin
      rate = Truncate.truncate_number(Float(row[:data]))
    rescue
      rate = "N/A"
    end
    ethnicity = row[:race_ethnicity].gsub("Hawaiian/", "").gsub(" ", "_").to_sym.downcase
    ethnicity_hash = initialize_new_key(ethnicity, data.fetch(district_name))
    ethnicity_hash.fetch(ethnicity)[year] = rate
    data[district_name] = ethnicity_hash
    data
  end

  def participation_rates(data, row) # return participation_hash
      district_name = row[:location].upcase
      data = initialize_new_key(district_name, data)
      year = row[:timeframe].to_i
      begin
        rate = Truncate.truncate_number(Float(row[:data]))
      rescue
        rate = "N/A"
      end
      data.fetch(district_name)[year] = rate
      return data
  end

  def initialize_new_key(key, data)
    if !data.has_key?(key)
        data[key] = {}
    end
    data
  end
end
