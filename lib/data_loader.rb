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
    scores_by_ethnicity = {}
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
      #district_hashes = {} #needs to return district even if it contains NA
      #if row[:data] != "N/A" #|| row[:data] != "LNE" || row[:data] != "#VALUE!"#or LNE or #VALUE!
      #  year = row[:timeframe].to_i

      #  begin
      #    rate = Float(row[:data])
      #    data.fetch(district_name)[year] = Truncate.truncate_number(rate)
      #
      #  end
      #end
      #data
      #cleaned_hashes = clean_bad_data(data) #if don't have this, then another test fails
      #return cleaned_hashes
      year = row[:timeframe].to_i
      begin
        rate = Truncate.truncate_number(Float(row[:data]))
      rescue
        rate = "N/A"
      end
      data.fetch(district_name)[year] = rate
      return data
  end

  # def take_out_bad_data #if data == N/A or LNE or #VALUE!
  #
  # end

  # def clean_bad_data(hashes) #make test that makes sure bad data is out
  #   cleaned_hashes = {}
  #
  #   hashes.each do |key, value| #only get districs that have good values
  #     if value.count != 0
  #       cleaned_hashes[key] = value #need to have west yuma in though
  #     end
  #   end
  #
  #   cleaned_hashes
  # end

  def initialize_new_key(key, data)
    if !data.has_key?(key)
        data[key] = {}
    end
    data
  end
end
