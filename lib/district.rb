
class District

  attr_reader :name, :enrollment

  def initialize(hash)
    @name = hash[:name].upcase
    @enrollment = hash[:enrollment]
  end

end
