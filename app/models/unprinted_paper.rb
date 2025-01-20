class UnprintedPaper < ParliamentaryPaperLaid

  def initialize(content_object_data)
    super
  end

  def reference
    get_all_from('reference_t')
  end

  def search_result_partial
    'search/results/unprinted_paper'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    abstract_t
    memberPrinted_t
    department_ses department_t
    type_ses subtype_ses
    corporateAuthor_ses corporateAuthor_t
    procedure_t
    dateLaid_dt dateWithdrawn_dt dateMade_dt dateApproved_dt
    comingIntoForceNotes_t comingIntoForce_dt
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    commonsLibraryLocation_t lordsLibraryLocation_t
    date_dt identifier_t legislature_ses
    ]
  end
end