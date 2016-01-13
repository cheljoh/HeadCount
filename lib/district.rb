
class District

  attr_reader :name

  def initialize(hash)
    @name = hash[:name].upcase
    #@enrollment = hash[:enrollment]
  end

end
