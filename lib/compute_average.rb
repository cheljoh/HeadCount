
module ComputeAverage

  def self.average(values)
    filtered = values.reject{|value| value == "N/A"}
    if filtered.count == 0
      return "N/A"
    end
    filtered.inject(0) do |sum, value|
      sum + value
    end/(filtered.count)
  end

end
