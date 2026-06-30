class ResearchMaterial < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    title_t uri
    searcherNote_t
    date_dt identifier_t legislature_ses
    ]
  end
end