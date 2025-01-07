class EuropeanScrutinyExplanatoryMemorandum < EuropeanScrutiny

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/european_scrutiny_explanatory_memorandum'
  end

  def search_result_partial
    'search/results/european_scrutiny_explanatory_memorandum'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses department_ses subject_ses legislature_ses]
  end

  def object_name
    subtype_or_type
  end

  def date_received
    get_first_as_date_from('dateReceived_dt')
  end
end