class EuropeanScrutinyMinisterialCorrespondence < EuropeanScrutiny

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/european_scrutiny_ministerial_correspondence'
  end

  def date_received
    get_first_as_date_from('dateReceived_dt')
  end

  def date_originated
    get_first_as_date_from('dateOriginated_dt')
  end

  def department
    fallback(get_first_from('department_ses'), get_first_from('department_t'))
  end

  def corresponding_minister
    fallback(get_first_from('correspondingMinister_ses'), get_first_from('correspondingMinister_t'))
  end
end