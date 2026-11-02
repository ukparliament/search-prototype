class ResearchMaterial < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    date_dt
    identifier_t
    legislature_ses
    searcherNote_t
    title_t
    uri
    ]
  end
end