class OralQuestionTimeIntervention < ContentObject

  def initialize(content_object_data)
    super
  end

  def object_name
    subtype_or_type
  end

  def search_result_partial
    'search/results/oral_question_time_intervention'
  end

  def search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    contributionText_t
    member_ses memberParty_ses
    type_ses subtype_ses
    procedural_ses
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    place_ses
    date_dt identifier_t legislature_ses
    ]
  end

  def template
    'search/objects/oral_question_time_intervention'
  end

end