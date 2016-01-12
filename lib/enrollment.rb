class Enrollment
    attr_accessor :name, :kindergarten_participation

    # :kindergarten_participation, :dropout_rate, :online, :overall_rate, :enrollment_rates_by_race,
    # :high_school_graduation, :special_education, :district


  # def initialize(name = nil, kindergarten_participation = {})
  #   @name = name
  #   @kindergarten_participation = kindergarten_participation
  # end

  def initialize(hash)
    @name = hash[:name]
    @kindergarten_participation = hash[:kindergarten_participation]
  end

  def kindergarten_participation_by_year

  end

  def kindergarten_participation_in_year(year)

  end
end
