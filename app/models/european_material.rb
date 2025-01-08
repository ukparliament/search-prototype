class EuropeanMaterial < ContentObject

  def initialize(content_object_data)
    super
  end

  def associated_objects
    # TODO: consider moving related item IDs to subclasses, as its use varies

    ids = super
    ids << related_item_ids
    ids.flatten.compact.uniq
  end

  def template
    'search/objects/european_material'
  end

  def search_result_partial
    'search/results/european_material'
  end

  def search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    mep_ses
    category_ses
    type_ses subtype_ses
    corporateAuthor_ses corporateAuthor_t
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    date_dt identifier_t legislature_ses
    ]
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

  def related_item_ids
    doc_text = get_all_ids_from('referencingDD_t')
    doc_uri = get_all_ids_from('referencingDD_uri')
    relation_text_uris = get_all_ids_from('relation_t')
    relation_uris = get_all_ids_from('relation_uri')
    [doc_text, doc_uri, relation_text_uris, relation_uris].flatten.compact
  end
end