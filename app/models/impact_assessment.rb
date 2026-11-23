class ImpactAssessment < Paper

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    askedToReplyAuthor_ses
    commonsLibraryLocation_t
    corporateAuthor_ses
    corporateAuthor_t
    date_dt
    department_ses
    department_t
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
    ]
  end

  def paper_type
    get_all_from('subtype_ses')
  end
end