class EuropeanMaterial < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/european_material'
  end

  def search_result_partial
    'search/results/european_material'
  end

  def category
    get_first_from('category_ses')
  end

  def object_name
    # TODO: should include category?
    # (category_ses AND subtype_ses) OR category_ses OR subtype_ses OR type_ses
    subtype_or_type
  end

  def reference
    get_all_from('referenceNumber_t')
  end

  def rapporteur
    get_first_from('mep_ses')
  end

  def eu_parliament_committee
    get_first_from('epCommittee_t')
  end

  def related_items
    # We're including two additional fields for EU material

    doc_text = get_all_from('referencingDD_t')&.pluck(:value)
    doc_uri = get_all_from('referencingDD_uri')&.pluck(:value)
    relation_uris = get_all_from('relation_t')&.pluck(:value)
    combined = [doc_text, doc_uri, relation_uris].flatten.compact

    ObjectsFromUriList.new(combined).get_objects
  end

  def publisher
    get_first_from('publisher_t')
  end

  def published_date
    get_first_as_date_from('dateEntered_dt')
  end

  def commons_library_location
    get_first_from('commonsLocation_t')
  end

  def ec_documents
    get_first_from('ecDocuments_t')
  end
end