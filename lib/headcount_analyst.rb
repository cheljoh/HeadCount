require_relative 'district_repository'
require_relative 'participation_analyst'
require_relative 'statewide_test_analyst'

class HeadcountAnalyst

  def initialize(district_repository)
    @district_repository = district_repository
    @pa = ParticipationAnalyst.new(@district_repository)
    @sta = StatewideTestAnalyst.new(@district_repository)
    @district_repository.load_data({
      :enrollment => {
        :kindergarten => "./data/Kindergartners in full-day program.csv",
        :high_school_graduation => "./data/High school graduation rates.csv",
      },
      :statewide_testing => {
        :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
        :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
        :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
        :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
      }
    })
  end

  def kindergarten_participation_rate_variation(district_name, hash)
    @pa.kindergarten_participation_rate_variation(district_name, hash)
  end

  def kindergarten_participation_rate_variation_trend(district_name, hash)
    @pa.kindergarten_participation_rate_variation_trend(district_name, hash)
  end

  def kindergarten_participation_against_high_school_graduation(name)
    @pa.kindergarten_participation_against_high_school_graduation(name)
  end

  def kindergarten_participation_correlates_with_high_school_graduation(hash)
    @pa.kindergarten_participation_correlates_with_high_school_graduation(hash)
  end

  def top_statewide_test_year_over_year_growth(hash)
    @sta.top_statewide_test_year_over_year_growth(hash)
  end

end
