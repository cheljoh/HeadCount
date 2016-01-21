require './lib/data_loader'
require_relative 'test_helper'

class DataLoaderTest < Minitest::Test

  def setup
    @data_loader = DataLoader.new
  end

  def test_can_it_load_kindergarten_data_and_convert_bad_data_to_na
    data = @data_loader.load_data(:participation, "./test/fixtures/Kindergartners in full-day program.csv")
    expected =
    {"COLORADO"=>{2007=>0.394, 2006=>0.336, 2005=>0.278,
    2004=>0.24, 2008=>0.535, 2009=>0.598, 2010=>0.64,
    2011=>0.672, 2012=>0.695, 2013=>0.702, 2014=>0.741},
    "ACADEMY 20"=>{2007=>0.391, 2006=>0.353, 2005=>0.267,
    2004=>0.302, 2008=>0.384, 2009=>0.39, 2010=>0.436,
    2011=>0.489, 2012=>0.478, 2013=>0.487, 2014=>0.49},
    "ADAMS COUNTY 14"=>{2007=>0.306, 2006=>0.293,
    2005=>0.3, 2004=>0.227, 2008=>0.673, 2009=>1.0,
    2010=>1.0, 2011=>1.0, 2012=>1.0, 2013=>0.998, 2014=>1.0},
    "COLORADO SPRINGS 11"=>{2006=>0.637, 2005=>0.509,
    2004=>0.069, 2008=>0.992, 2009=>1.0, 2010=>0.993,
    2012=>0.992, 2013=>0.989, 2014=>0.994},
    "COTOPAXI RE-3"=>{2004=>0.0, 2009=>1.0},
    "CREEDE CONSOLIDATED 1"=>{2004=>0.0, 2009=>1.0},
    "GUNNISON WATERSHED RE1J"=>{2004=>0.144},
    "WEST YUMA COUNTY RJ-1"=>{2008=>"N/A", 2009=>"N/A",
    2010=>"N/A", 2011=>"N/A", 2012=>"N/A", 2013=>"N/A",
    2014=>"N/A", 2007=>"N/A", 2006=>"N/A", 2005=>"N/A",
    2004=>"N/A"}}
    assert_equal expected, data
  end

  def test_can_it_load_third_grade_data_and_convert_bad_data_to_na
    data = @data_loader.load_data(:testing_by_grade, "./test/fixtures/3rd grade students scoring proficient or above on the CSAP_TCAP.csv")
    expected =
    {2008=>{:math=>"N/A", :reading=>"N/A", :writing=>0.278},
     2009=>{:math=>"N/A", :reading=>"N/A", :writing=>0.29},
     2010=>{:math=>"N/A", :reading=>"N/A", :writing=>"N/A"},
     2011=>{:math=>"N/A", :reading=>"N/A", :writing=>"N/A"},
     2012=>{:reading=>"N/A", :math=>"N/A", :writing=>"N/A"},
     2013=>{:math=>"N/A", :reading=>"N/A", :writing=>"N/A"},
     2014=>{:math=>"N/A", :reading=>"N/A", :writing=>"N/A"}}
    assert_equal expected, data["AGATE 300"]
  end

  def test_can_it_ethnicity_data_and_convert_bad_data_to_na
    data = @data_loader.load_data(:ethnicity, "./test/fixtures/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv")
    expected =
    {"COLORADO"=>{:all_students=>{2011=>0.68, 2012=>0.693, 2013=>0.695, 2014=>0.69},
    :asian=>{2011=>0.748, 2012=>0.757, 2013=>0.769, 2014=>0.769},
    :black=>{2011=>0.486, 2012=>0.515, 2013=>0.52, 2014=>0.516},
    :pacific_islander=>{2011=>0.658, 2012=>0.642, 2013=>0.681, 2014=>0.667},
    :hispanic=>{2011=>0.498, 2012=>0.515, 2013=>0.527, 2014=>0.519},
    :native_american=>{2011=>0.527, 2012=>0.549, 2013=>0.545, 2014=>0.523},
    :two_or_more=>{2011=>0.743, 2012=>0.76, 2013=>0.759, 2014=>0.751},
    :white=>{2011=>0.789, 2012=>0.802, 2013=>0.799, 2014=>0.798}},
    "ACADEMY 20"=>{:all_students=>{2011=>0.83, 2012=>0.845, 2013=>0.845, 2014=>0.841},
    :asian=>{2011=>0.897, 2012=>0.893, 2013=>0.901, 2014=>0.855},
    :black=>{2011=>0.662, 2012=>0.694, 2013=>0.669, 2014=>0.703},
    :pacific_islander=>{2011=>0.745, 2012=>0.833, 2013=>0.866, 2014=>0.931},
    :hispanic=>{2011=>0.748, 2012=>0.771, 2013=>0.772, 2014=>0.007},
    :native_american=>{2011=>0.816, 2012=>0.785, 2013=>0.813, 2014=>0.007},
    :two_or_more=>{2011=>0.841, 2012=>0.845, 2013=>0.855, 2014=>0.008},
    :white=>{2011=>0.851, 2012=>0.861, 2013=>0.86, 2014=>0.008}},
    "ADAMS COUNTY 14"=>{:all_students=>{2011=>0.44, 2012=>0.426, 2013=>0.448, 2014=>0.433},
    :asian=>{2011=>"N/A", 2012=>"N/A", 2013=>"N/A", 2014=>"N/A"},
    :black=>{2011=>0.333, 2012=>0.324, 2013=>0.39, 2014=>0.309},
    :pacific_islander=>{2011=>"N/A", 2012=>"N/A", 2013=>"N/A", 2014=>"N/A"},
    :hispanic=>{2011=>0.434, 2012=>0.418, 2013=>0.434, 2014=>0.004},
    :native_american=>{2011=>0.484, 2012=>0.538, 2013=>0.56, 2014=>0.004},
    :two_or_more=>{2011=>0.458, 2012=>0.478, 2013=>0.437, 2014=>0.005},
    :white=>{2011=>0.522, 2012=>0.485, 2013=>0.534, 2014=>0.005}},
    "ADAMS-ARAPAHOE 28J"=>{:all_students=>{2011=>0.47, 2012=>0.482, 2013=>0.483, 2014=>0.464},
    :asian=>{2011=>0.508, 2012=>0.509, 2013=>0.51, 2014=>0.46},
    :black=>{2011=>0.413, 2012=>0.447, 2013=>0.447, 2014=>0.43},
    :pacific_islander=>{2011=>0.352, 2012=>0.396, 2013=>0.451, 2014=>0.442},
    :hispanic=>{2011=>0.404, 2012=>0.419, 2013=>0.423, 2014=>0.004},
    :native_american=>{2011=>0.511, 2012=>0.518, 2013=>0.552, 2014=>0.004},
    :two_or_more=>{2011=>0.593, 2012=>0.598, 2013=>0.59, 2014=>0.005},
    :white=>{2011=>0.664, 2012=>0.682, 2013=>0.684, 2014=>0.006}},
    "AGUILAR REORGANIZED 6"=>{:all_students=>{2011=>0.5, 2012=>0.425, 2013=>0.465, 2014=>0.464},
    :asian=>{2011=>"N/A", 2012=>"N/A", 2013=>"N/A", 2014=>"N/A"},
    :black=>{2011=>"N/A", 2012=>"N/A", 2013=>"N/A", 2014=>"N/A"},
    :pacific_islander=>{2011=>"N/A", 2012=>"N/A", 2013=>"N/A", 2014=>"N/A"},
    :hispanic=>{2011=>0.541, 2012=>0.37, 2013=>0.28, 2014=>0.003},
    :native_american=>{2011=>"N/A", 2012=>"N/A", 2013=>"N/A", 2014=>"N/A"},
    :two_or_more=>{2011=>"N/A", 2012=>"N/A", 2013=>"N/A", 2014=>"N/A"},
    :white=>{2011=>0.454, 2012=>0.526, 2013=>0.687, 2014=>0.005}}}
    assert_equal expected, data
  end

end
