
module Truncate

  def self.truncate_number(value)
    (value * 1000).floor/1000.0
  end

end
