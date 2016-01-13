
class District

  attr_reader :name

def initialize(hash)
  @name = hash[:name].upcase
  #@enrollment = hash[:enrollment]
end

end

# d = District.new({:name => "Academy 20"})
# puts d.name
