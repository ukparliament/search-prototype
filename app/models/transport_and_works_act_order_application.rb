class TransportAndWorksActOrderApplication < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/transport_and_works_act_order_application'
  end

  def depositing_agent
    preferred = get_first_from('agent_ses')
    return preferred unless preferred.blank?

    get_first_from('agent_t')
  end

  def depositing_applicant
    preferred = get_first_from('applicant_ses')
    return preferred unless preferred.blank?

    get_first_from('applicant_t')
  end

  def date_of_origin
    get_first_as_date_from('dateOfOrigin_dt')
  end

end