class GrandCommitteeProceeding < ParliamentaryProceeding

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    corporateAuthor_ses
    corporateAuthor_t
    ]
  end
end