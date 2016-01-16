
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
      scores_by_subject = {}
      district_name = row[:location].upcase
      data = check_if_new_district(district_name, data, row)
      year = row[:timeframe].to_i
      rate = row[:data].to_f
      subject = row[:score]
      scores_by_subject[subject] = rate
      data.fetch(district_name)[year] = scores_by_subject
      data
  end

  def subject_proficiency_by_ethnicity_row(data, row)
    scores_by_ethnicity = {}
    district_name = row[:location].upcase
    data = check_if_new_district(district_name, data, row)
    year = row[:timeframe].to_i
    rate = row[:data].to_f
    ethnicity = row[:race_ethnicity]
    scores_by_ethnicity[year] = rate
    data.fetch(district_name)[ethnicity] = scores_by_ethnicity
    data
  end

  def check_if_new_district(district_name, data, row)
    if !data.has_key?(district_name)
        data[district_name] = {}
    end
    data
  end
end
