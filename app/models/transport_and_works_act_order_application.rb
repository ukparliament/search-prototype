class TransportAndWorksActOrderApplication < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/transport_and_works_act_order_application'
  end

  def search_result_partial
    'search/results/transport_and_works_act_order_application'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses applicant_ses
       legislationTitle_ses subject_ses legislature_ses]
  end

  def depositing_agent
    fallback(get_first_from('agent_ses'), get_first_from('agent_t'))
  end

  def depositing_applicant
    fallback(get_first_from('applicant_ses'), get_first_from('applicant_t'))
  end

  def date_originated
    get_first_as_date_from('dateOfOrigin_dt')
  end

  def display_link
    get_first_from('location_uri')
  end
end