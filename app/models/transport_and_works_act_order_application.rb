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
    return if content_object_data['agent_ses'].blank?

    content_object_data['agent_ses'].first
  end

  def depositing_applicant
    return if content_object_data['applicant_ses'].blank?

    content_object_data['applicant_ses'].first
  end

end