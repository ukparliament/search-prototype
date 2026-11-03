class OralQuestion < Question

  def initialize(content_type_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << answer_item_link
    ids.flatten.compact.uniq
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    answerFor_uri
    answeringDept_ses
    answeringMemberParty_ses
    answeringMember_ses
    askedToReplyAuthor_ses
    askingMemberParty_ses
    askingMember_ses
    contributionType_t
    correctingItem_uri
    correctingItem_t
    correctedWmsMc_b
    dateForAnswer_dt
    dateOfAnswer_dt
    dateTabled_dt
    date_dt
    department_ses
    identifier_t
    legislationTitle_ses
    legislationTitle_t
    legislature_ses
    place_ses
    pqStatus_t
    procedural_ses
    questionText_t
    searcherNote_t
    subject_ses
    subject_t
    tablingMemberParty_ses
    tablingMember_ses
    title_t
    uri
    ]
  end

  def object_name
    subtype_or_type
  end

  def answer_item_link
    get_first_id_from('answerFor_uri')
  end

  def prelim_template
    return '/content_type_objects/preliminary_sentences/oral_question_withdrawn' if withdrawn?

    return '/content_type_objects/preliminary_sentences/oral_question_tabled' if tabled?

    return '/content_type_objects/preliminary_sentences/oral_question_answered' if answered?

    nil
  end

end