class EuropeanScrutinyRecommendation < EuropeanScrutiny

  def initialize(content_object_data)
    super
  end

  def search_result_partial
    'search/results/european_scrutiny_recommendation'
  end

  def search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    type_ses subtype_ses
    reportDate_dt
    debateDate_dt
    date_dt identifier_t
    ]
  end

  def decision
    get_first_from('decisionType_t')
  end

  def assessment
    get_first_from('assessment_t')
  end

  def status
    get_first_from('scrutinyProgress_t')
  end

  def report_number
    get_first_from('reportTitle_t')
  end

  def is_cleared
    get_first_as_boolean_from('cleared_b')
  end

  def date_reported
    fallback(get_first_as_date_from('reportDate_dt'), get_first_as_date_from('date_dt'))
  end

  def date_debated
    get_first_as_date_from('debateDate_dt')
  end

  def debate_location
    get_first_from('debateLocation_t')
  end

  def template
    'search/objects/european_scrutiny_recommendation'
  end
end