class EuropeanScrutiny < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << regarding_object_ids
    ids.flatten.compact.uniq
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    title_t uri
    department_ses department_t
    type_ses subtype_ses
    subject_ses subject_t
    searcherNote_t
    date_dt identifier_t legislature_ses
    ]
  end

  def department
    fallback(get_first_from('department_ses'), get_first_from('department_t'))
  end

  def regarding_object_ids
    combine_fields(get_all_ids_from('regardingDD_uri'), get_all_ids_from('regardingDD_t'))
  end
end