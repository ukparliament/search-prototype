class FormalProceeding < Proceeding

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    abstract_t
    askedToReplyAuthor_ses
    date_dt
    department_ses
    department_t
    identifier_t
    leadMember_ses
    legislationTitle_ses
    legislationTitle_t
    legislativeStage_ses
    legislature_ses
    procedural_ses
    searcherNote_t
    subject_ses
    subject_t
    title_t
    uri
    ]
  end
end