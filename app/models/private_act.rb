class PrivateAct < Act

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/private_act'
  end

  def search_result_partial
    'search/results/private_act'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses legislationTitle_ses subject_ses legislature_ses]
  end
end