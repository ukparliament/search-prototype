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

  def search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    correspondingMinister_ses correspondingMinister_t
    department_ses department_t
    type_ses subtype_ses
    subject_ses subject_t
    date_dt identifier_t
    ]
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