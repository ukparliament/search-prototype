class PublicAct < Act

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/public_act'
  end

  def search_result_partial
    'search/results/public_act'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses legislationTitle_ses subject_ses legislature_ses]
  end
end