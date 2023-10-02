class OralQuestion < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/oral_question'
  end

  def object_name
    "Oral question"
  end

  def prelim_partial
    return '/search/preliminary_sentences/oral_question_tabled' if tabled?

    return '/search/preliminary_sentences/oral_question_withdrawn' if withdrawn?

    return '/search/preliminary_sentences/oral_question_answered' if answered?

    return '/search/preliminary_sentences/oral_question_lords_answered' if lords_answered?

    return '/search/preliminary_sentences/oral_question_corrected' if corrected?

    nil
  end

  def state
    return if content_object_data['pqStatus_t'].blank?

    content_object_data['pqStatus_t'].first
  end

  def tabled?
    state == 'Tabled'
  end

  def withdrawn?
    state == 'Withdrawn'
  end

  def answered?
    state == 'Answered'
  end

  def lords_answered?
    # placeholder
    state == 'Lords_Answered'
  end

  def corrected?
    # Copied from written question
    # placeholder
    return false unless content_object_data['correctedWmsMc_b'] == 'true'

    true
  end

end