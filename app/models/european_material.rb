class EuropeanMaterial < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/european_material'
  end

  def category
    get_first_from('category_ses')
  end

  def object_name
    subtype_or_type
  end

  def reference
    get_first_from('referenceNumber_t')
  end

  def rapporteur
    get_first_from('mep_ses')
  end

  def eu_parliament_committee
    get_first_from('ep_committee_t')
  end

  def publisher
    get_first_from('publisher_t')
  end

  def published_date
    get_first_as_date_from('dateEntered_dt')
  end

end