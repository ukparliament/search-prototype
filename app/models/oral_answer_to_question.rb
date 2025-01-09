class OralAnswerToQuestion < Question

  def initialize(content_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << question_id
    ids.flatten.compact.uniq
  end

  def template
    'search/objects/oral_answer_to_question'
  end

  def search_result_partial
    'search/results/oral_answer_to_question'
  end

  def search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    answerText_t
    answeringMember_ses answeringMemberParty_ses
    answeringDept_ses
    type_ses subtype_ses
    procedural_ses
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    place_ses
    date_dt identifier_t legislature_ses
    ]
  end

  def has_question?
    question_id.blank? ? false : true
  end

  def question_id
    get_first_id_from('answerFor_uri')
  end

  def question_url
    get_first_from('answerFor_uri')
  end
end