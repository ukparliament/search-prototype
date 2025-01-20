class ResearchMaterial < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/research_material'
  end

  def search_result_partial
    'search/results/research_material'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    type_ses subtype_ses
    date_dt identifier_t legislature_ses
    ]
  end
end