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
      data = testing_by_grade_row(data, row)
    elsif category == :ethnicity
      data = subject_proficiency_by_ethnicity_row(data, row)
    elsif category == :participation
      data = participation_rates(data, row)
    end
  end

  def testing_by_grade_row(data, row)
      district_name = row[:location].upcase
      data = initialize_new_key(district_name, data)
      year = row[:timeframe].to_i
      rate = row[:data].to_f
      subject = row[:score].to_sym.downcase
      year_hash = initialize_new_key(year, data.fetch(district_name))
      year_hash[year][subject] = Truncate.truncate_number(rate)
      data[district_name] = year_hash
      data
  end

  def subject_proficiency_by_ethnicity_row(data, row)
    scores_by_ethnicity = {}
    district_name = row[:location].upcase
    data = initialize_new_key(district_name, data)
    year = row[:timeframe].to_i
    rate = row[:data].to_f
    ethnicity = row[:race_ethnicity].gsub("Hawaiian/", "").gsub(" ", "_").to_sym.downcase
    ethnicity_hash = initialize_new_key(ethnicity, data.fetch(district_name))
    ethnicity_hash.fetch(ethnicity)[year] = Truncate.truncate_number(rate)
    data[district_name] = ethnicity_hash
    data
  end

  def participation_rates(data, row) # return participation_hash
      district_name = row[:location].upcase
      data = initialize_new_key(district_name, data)
      district_hashes = {}
        if row[:data] != "N/A"
          year = row[:timeframe].to_i
          rate = row[:data].to_f
          data.fetch(district_name)[year] = rate
        end
      cleaned_hashes = clean_bad_data(data)
      return cleaned_hashes
  end

  def clean_bad_data(hashes) #make test that makes sure bad data is out
    cleaned_hashes = {}

    hashes.each do |key, value| #only get districs that have good values
      if value.count != 0
        cleaned_hashes[key] = value #need to have west yuma in though
      end
    end

    cleaned_hashes
  end

  def initialize_new_key(key, data)
    if !data.has_key?(key)
        data[key] = {}
    end
    data
  end
end
