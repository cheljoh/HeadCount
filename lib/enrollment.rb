class Enrollment
    attr_accessor :name, :kindergarten_participation

  def initialize(hash)
    @name = hash[:name]
    @kindergarten_participation = hash[:kindergarten_participation]
  end

  def kindergarten_participation_by_year
    truncated_years = kindergarten_participation.map do |year, rate|
      [year, truncate_number(rate)]
    end.to_h
    truncated_years
  end

  def kindergarten_participation_in_year(year)
    if kindergarten_participation.keys.include?(year)
      value = kindergarten_participation[year]
      final_value = truncate_number(value)
    end
      final_value
  end

  def truncate_number(value)
    (value * 1000).floor/1000.0
  end

end
