class OralQuestion < Question

  def initialize(content_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << answer_item_link
    ids.flatten.compact.uniq
  end

  def template
    'search/objects/oral_question'
  end

  def search_result_partial
    'search/results/oral_question'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses askingMember_ses askingMemberParty_ses tablingMember_ses tablingMemberParty_ses
      answeringMember_ses answeringMemberParty_ses answeringDept_ses procedural_ses
      legislationTitle_ses subject_ses place_ses legislature_ses]
  end

  def object_name
    subtype_or_type
  end

  def answer_item_link
    get_first_id_from('answerFor_uri')
  end

  def prelim_partial
    return '/search/preliminary_sentences/oral_question_withdrawn' if withdrawn?

    return '/search/preliminary_sentences/oral_question_tabled' if tabled?

    return '/search/preliminary_sentences/oral_question_answered' if answered?

    nil
  end

end