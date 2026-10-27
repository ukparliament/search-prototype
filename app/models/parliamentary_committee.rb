class ParliamentaryCommittee < ParliamentaryPaperReported

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    commonsLibraryLocation_t
    corporateAuthor_ses
    corporateAuthor_t
    date_dt
    identifier_t
    legislationTitle_ses
    legislationTitle_t
    legislature_ses
    lordsLibraryLocation_t
    searcherNote_t
    subject_ses
    subject_t
    title_t
    uri
    witness_ses
    witness_t
    ]
  end
end