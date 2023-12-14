class WrittenQuestion < Question

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/written_question'
  end

  def holding?
    state && state[:value] == 'Holding'
  end

  def answered_was_holding?
    # There is no state string for this, it must be derived
    return false unless state && state[:value] == 'Answered'

    # the following correspond to the holding state and their presence allows us to determine that this answered
    # question formerly had the state 'holding':
    # 1. the question has received a holding answer:
    return false unless holding_answer? && holding_answer?[:value]

    # 2. the date this question received a holding answer:
    return false if date_of_holding_answer.blank?

    true
  end

  def prelim_partial
    return '/search/preliminary_sentences/written_question_tabled' if tabled?

    return '/search/preliminary_sentences/written_question_answered_was_holding' if answered_was_holding?

    return '/search/preliminary_sentences/written_question_holding' if holding?

    return '/search/preliminary_sentences/written_question_answered' if answered?

    return '/search/preliminary_sentences/written_question_withdrawn' if withdrawn?

    return '/search/preliminary_sentences/written_question_corrected' if corrected?

    nil
  end

  def uin
    # UIN with optional Hansard reference in same field
    get_all_from('identifier_t')
  end

  def holding_answer?
    get_first_as_boolean_from('holdingAnswer_b')
  end

  def prorogation_answer?
    #to show conditionally on answered states only (as determined by method)
    get_as_boolean_from('prorogationAnswer_b')
  end

  def date_of_holding_answer
    get_first_as_date_from('dateOfHoldingAnswer_dt')
  end

  def transferred?
    get_as_boolean_from('transferredQuestion_b')
  end

  def unstarred_question?
    get_as_boolean_from('unstarredQuestion_b')
  end

  def failed_oral?
    get_as_boolean_from('failedOral_b')
  end

  def grouped_for_answer?
    get_as_boolean_from('groupedAnswer_b')
  end

  def attachment
    # this is the title of the attachment, rather than a link to the resource
    # there can be multiple titles, all of which will be displayed

    return if content_object_data['attachmentTitle_t'].blank?

    content_object_data['attachmentTitle_t']
  end
end