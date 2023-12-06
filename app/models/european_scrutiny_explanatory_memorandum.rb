class EuropeanScrutinyExplanatoryMemorandum < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/european_scrutiny_explanatory_memorandum'
  end

  def object_name
    subtype_or_type
  end

  def regarding_link
    get_first_from('regardingDD_uri')
  end

  def regarding_title
    get_first_from('title_t')
  end

  def date_received
    get_first_as_date_from('dateReceived_dt')
  end
end