class ResearchMaterial < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def template
    'content_type_objects/object_pages/research_material'
  end

  def search_result_partial
    'search/results/research_material'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    type_ses subtype_ses
    searcherNote_t
    date_dt identifier_t legislature_ses
    ]
  end
end