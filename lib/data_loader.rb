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
    if category == :third_grade || category == :eighth_grade
      data = testing_by_grade_row(data, row)
    else
      data = subject_proficiency_by_ethnicity_row(data, row)
    end
  end

  def testing_by_grade_row(data, row)
      district_name = row[:location].upcase
      data = initialize_new_key(district_name, data)
      year = row[:timeframe].to_i
      rate = row[:data].to_f
      subject = row[:score]
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
    ethnicity = row[:race_ethnicity]
    scores_by_ethnicity[year] = Truncate.truncate_number(rate)
    data.fetch(district_name)[ethnicity] = scores_by_ethnicity
    data
  end

  def initialize_new_key(key, data)
    if !data.has_key?(key)
        data[key] = {}
    end
    data
  end
end
