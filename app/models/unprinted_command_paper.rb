class UnprintedCommandPaper < ParliamentaryPaperLaid

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    askedToReplyAuthor_ses
    comingIntoForceNotes_t
    comingIntoForce_dt
    commonsLibraryLocation_t
    corporateAuthor_ses
    corporateAuthor_t
    dateApproved_dt
    dateLaid_dt
    dateMade_dt
    dateWithdrawn_dt
    date_dt
    department_ses
    department_t
    identifier_t
    legislationTitle_ses
    legislationTitle_t
    legislature_ses
    lordsLibraryLocation_t
    memberPrinted_t
    searcherNote_t
    subject_ses
    subject_t
    title_t
    uri
    withdrawn_b
    ]
  end
end