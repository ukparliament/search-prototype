class EuropeanScrutinyExplanatoryMemorandum < EuropeanScrutiny

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/european_scrutiny_explanatory_memorandum'
  end

  def object_name
    subtype_or_type
  end

  def date_received
    get_first_as_date_from('dateReceived_dt')
  end
end