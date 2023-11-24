class TransportAndWorksActOrderApplication < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/transport_and_works_act_order_application'
  end

  def object_name
    'Transport and Works Act order application'
  end

  def depositing_agent
    get_first_from('agent_ses')
  end

  def depositing_applicant
    get_first_from('applicant_ses')
  end

end