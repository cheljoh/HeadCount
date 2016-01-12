
class District

  attr_reader :name

def initialize(name)
  @name = name[:name].upcase
end

end

d = District.new({:name => "Academy 20"})
puts d.name
