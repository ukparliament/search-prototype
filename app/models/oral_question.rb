class OralQuestion < Question

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/oral_question'
  end

  def object_name
    "oral question"
  end

  def prelim_partial
    return '/search/preliminary_sentences/oral_question_tabled' if tabled?

    return '/search/preliminary_sentences/oral_question_withdrawn' if withdrawn?

    return '/search/preliminary_sentences/oral_question_answered' if answered?

    return '/search/preliminary_sentences/oral_question_lords_answered' if lords_answered?

    return '/search/preliminary_sentences/oral_question_corrected' if corrected?

    nil
  end

  def lords_answered?
    # placeholder
    state == 'Lords_Answered'
  end

end