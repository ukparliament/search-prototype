class OralQuestionTimeIntervention < Question

  def initialize(content_type_object_data)
    super
  end

  def object_name
    subtype_or_type
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    contributionText_t
    date_dt
    identifier_t
    legislationTitle_ses
    legislationTitle_t
    legislature_ses
    memberParty_ses
    member_ses
    place_ses
    procedural_ses
    searcherNote_t
    subject_ses
    subject_t
    title_t
    uri
    ]
  end
end