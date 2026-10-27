class CommandPaper < ParliamentaryPaperLaid

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    member_ses
    dateApproved_dt
    dateMade_dt
    comingIntoForceNotes_t
    comingIntoForce_dt
    witness_ses witness_t
    ]
  end
end