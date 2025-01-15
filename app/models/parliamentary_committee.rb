class ParliamentaryCommittee < ParliamentaryPaperReported

  def initialize(content_object_data)
    super
  end

  def search_result_partial
    'search/results/parliamentary_committee'
  end

  def search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    type_ses subtype_ses
    corporateAuthor_ses corporateAuthor_t
    legislationTitle_ses legislationTitle_t
    witness_ses witness_t
    subject_ses subject_t
    searcherNote_t
    commonsLibraryLocation_t lordsLibraryLocation_t
    date_dt identifier_t legislature_ses
    ]
  end
end