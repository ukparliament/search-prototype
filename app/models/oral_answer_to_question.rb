class OralAnswerToQuestion < Question

  def initialize(content_type_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << question_id
    ids.flatten.compact.uniq
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    answerFor_uri
    answerText_t
    answeringDept_ses
    answeringMemberParty_ses
    answeringMember_ses
    askedToReplyAuthor_ses
    date_dt
    dateOfAnswer_dt
    department_ses
    identifier_t
    legislationTitle_ses
    legislationTitle_t
    legislature_ses
    place_ses
    procedural_ses
    searcherNote_t
    subject_ses
    subject_t
    title_t
    uri
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