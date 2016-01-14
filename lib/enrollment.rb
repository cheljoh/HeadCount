require_relative 'truncate'

class Enrollment
    attr_accessor :name, :kindergarten_participation

  def initialize(hash)
    @name = hash[:name]
    @kindergarten_participation = hash[:kindergarten_participation]
  end

  def kindergarten_participation_by_year
    truncated_years = kindergarten_participation.map do |year, rate|
      [year, Truncate.truncate_number(rate)]
    end.to_h
    truncated_years
  end

  def kindergarten_participation_in_year(year)
    if kindergarten_participation.keys.include?(year)
      value = kindergarten_participation[year]
      final_value = Truncate.truncate_number(value)
    end
      final_value
  end

end
