class OralQuestion < Question

  def initialize(content_type_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << answer_item_link
    ids.flatten.compact.uniq
  end

  def template
    'content_type_objects/object_pages/oral_question'
  end

  def search_result_partial
    'search/results/oral_question'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    questionText_t
    askingMember_ses askingMemberParty_ses tablingMember_ses tablingMemberParty_ses
    answeringMember_ses answeringMemberParty_ses
    answeringDept_ses
    contributionType_t
    pqStatus_t
    procedural_ses
    dateTabled_dt dateForAnswer_dt dateOfAnswer_dt
    type_ses subtype_ses
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    place_ses
    date_dt identifier_t legislature_ses
    ]
  end

  def object_name
    subtype_or_type
  end

  def answer_item_link
    get_first_id_from('answerFor_uri')
  end

  def prelim_partial
    return '/content_type_objects/preliminary_sentences/oral_question_withdrawn' if withdrawn?

    return '/content_type_objects/preliminary_sentences/oral_question_tabled' if tabled?

    return '/content_type_objects/preliminary_sentences/oral_question_answered' if answered?

    nil
  end

end