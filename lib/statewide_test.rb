class StatewideTest

attr_accessor :name, :third_grade, :eighth_grade, :math, :reading, :writing

  def initialize(hash)
    @name = hash[:name]
    @third_grade = hash[:third_grade]
    @eighth_grade = hash[:eighth_grade]
    @math = hash[:math]
    @reading = hash[:reading]
    @writing = hash[:writing]
  end

  def proficient_by_grade(grade) #unkown data error with unknown grade. Method returns a hash grouped by year that points to subjects
    if grade == 3
      third_grade
    elsif grade == 8
      eighth_grade
    else
      raise ArgumentError
    end


  end

end
