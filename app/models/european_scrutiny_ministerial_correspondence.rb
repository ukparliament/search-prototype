class EuropeanScrutinyMinisterialCorrespondence < EuropeanScrutiny

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/european_scrutiny_ministerial_correspondence'
  end

  def search_result_partial
    'search/results/european_scrutiny_ministerial_correspondence'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses correspondingMinister_ses department_ses subject_ses]
  end

  def date_received
    get_first_as_date_from('dateReceived_dt')
  end

  def date_originated
    get_first_as_date_from('dateOriginated_dt')
  end

  def corresponding_minister
    fallback(get_first_from('correspondingMinister_ses'), get_first_from('correspondingMinister_t'))
  end
end