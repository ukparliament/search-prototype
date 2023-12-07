class EuropeanScrutinyMinisterialCorrespondence < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/european_scrutiny_ministerial_correspondence'
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

  def date_originated
    get_first_as_date_from('dateOriginated_dt')
  end

  def corresponding_minister
    get_first_from('correspondingMinister_ses')
  end
end