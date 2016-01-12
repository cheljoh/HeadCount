class Enrollment
    attr_accessor :name, :kindergarten_participation

  def initialize(hash)
    @name = hash[:name]
    @kindergarten_participation = hash[:kindergarten_participation]
  end

  def kindergarten_participation_by_year #needs to return value
    truncated_years = kindergarten_participation.map do |key, value|
      [key, truncate_number(value)]
    end.to_h
    truncated_years
  end

  def kindergarten_participation_in_year(year) #year is fixnum, should return nil given unknown year
    final_value = nil
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
e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})

#puts e.kindergarten_participation_in_year(2005)
#puts e.kindergarten_participation_by_year.values
