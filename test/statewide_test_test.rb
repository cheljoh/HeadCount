require './lib/statewide_test'
require_relative 'test_helper'

class StatewideTestTest < Minitest::Test

  def setup
    @statewide_test = StatewideTest.new(
    {:third_grade =>
      {2008=>{"Math"=>0.857, "Reading"=>0.866, "Writing"=>0.671},
       2009=>{"Math"=>0.824, "Reading"=>0.862, "Writing"=>0.706},
       2010=>{"Math"=>0.849, "Reading"=>0.864, "Writing"=>0.662},
       2011=>{"Math"=>0.819, "Reading"=>0.867, "Writing"=>0.678},
       2012=>{"Reading"=>0.87, "Math"=>0.83, "Writing"=>0.655},
       2013=>{"Math"=>0.855, "Reading"=>0.859, "Writing"=>0.668},
       2014=>{"Math"=>0.834, "Reading"=>0.831, "Writing"=>0.639}},
    :eighth_grade =>
      {2008=>{"Math"=>0.64, "Reading"=>0.843, "Writing"=>0.734},
       2009=>{"Math"=>0.656, "Reading"=>0.825, "Writing"=>0.701},
       2010=>{"Math"=>0.672, "Reading"=>0.863, "Writing"=>0.754},
       2011=>{"Reading"=>0.832, "Math"=>0.653, "Writing"=>0.745},
       2012=>{"Math"=>0.681, "Writing"=>0.738, "Reading"=>0.833},
       2013=>{"Math"=>0.661, "Reading"=>0.852, "Writing"=>0.750},
       2014=>{"Math"=>0.684, "Reading"=>0.827, "Writing"=>0.747}},
    :math =>
      {"All Students"=>{2014=>0.699},
      "Asian"=>{2014=>0.8},
      "Black"=>{2014=>0.420},
      "Hawaiian/Pacific Islander"=>{2014=>0.681},
      "Hispanic"=>{2014=>0.604},
      "Native American"=>{2014=>0.543},
      "Two or more"=>{2014=>0.693},
      "White"=>{2014=>0.723}},
    :reading =>
      {"All Students"=>{2014=>0.841},
       "Asian"=>{2014=>0.855},
       "Black"=>{2014=>0.703},
       "Hawaiian/Pacific Islander"=>{2014=>0.931},
       "Hispanic"=>{2014=>0.007},
       "Native American"=>{2014=>0.007},
       "Two or more"=>{2014=>0.008},
       "White"=>{2014=>0.008}},
    :writing =>
      {"All Students"=>{2014=>0.715},
      "Asian"=>{2014=>0.789},
      "Black"=>{2014=>0.519},
      "Hawaiian/Pacific Islander"=>{2014=>0.727},
      "Hispanic"=>{2014=>0.624},
      "Native American"=>{2014=>0.62},
      "Two or more"=>{2014=>0.731},
      "White"=>{2014=>0.734}}})
  end

  def test_proficient_by_grade_for_third_grade
    expected =
    {2008=>{"Math"=>0.857, "Reading"=>0.866, "Writing"=>0.671},
     2009=>{"Math"=>0.824, "Reading"=>0.862, "Writing"=>0.706},
     2010=>{"Math"=>0.849, "Reading"=>0.864, "Writing"=>0.662},
     2011=>{"Math"=>0.819, "Reading"=>0.867, "Writing"=>0.678},
     2012=>{"Reading"=>0.87, "Math"=>0.83, "Writing"=>0.655},
     2013=>{"Math"=>0.855, "Reading"=>0.859, "Writing"=>0.668},
     2014=>{"Math"=>0.834, "Reading"=>0.831, "Writing"=>0.639}}
     assert_equal expected, @statewide_test.proficient_by_grade(3)
  end

  def test_proficient_by_grade_for_eighth_grade
    expected =
    {2008=>{"Math"=>0.64, "Reading"=>0.843, "Writing"=>0.734},
     2009=>{"Math"=>0.656, "Reading"=>0.825, "Writing"=>0.701},
     2010=>{"Math"=>0.672, "Reading"=>0.863, "Writing"=>0.754},
     2011=>{"Reading"=>0.832, "Math"=>0.653, "Writing"=>0.745},
     2012=>{"Math"=>0.681, "Writing"=>0.738, "Reading"=>0.833},
     2013=>{"Math"=>0.661, "Reading"=>0.852, "Writing"=>0.750},
     2014=>{"Math"=>0.684, "Reading"=>0.827, "Writing"=>0.747}}
    #  require 'pry'
    #  binding.pry
     assert_equal expected, @statewide_test.proficient_by_grade(8)
  end

  def test_proficient_by_grade_for_unknown_grade
    assert_raises ArgumentError do #needs to be UnknownDataError?
      @statewide_test.proficient_by_grade(1)
    end
  end
end
