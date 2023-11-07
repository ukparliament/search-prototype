class WrittenQuestion < Question

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/written_question'
  end

  def object_name
    'written question'
  end

  def holding?
    state == 'Holding'
  end

  def answered_was_holding?
    # There is no state string for this, it must be derived
    return false unless state == 'Answered'

    # the following correspond to the holding state and their presence allows us to determine that this answered
    # question formerly had the state 'holding':
    # 1. the question has received a holding answer:
    return false unless holding_answer?

    # 2. the date this question received a holding answer:
    return false if date_of_holding_answer.blank?

    true
  end

  def prelim_partial
    return '/search/preliminary_sentences/written_question_tabled' if tabled?

    return '/search/preliminary_sentences/written_question_answered' if answered?

    return '/search/preliminary_sentences/written_question_holding' if holding?

    return '/search/preliminary_sentences/written_question_answered_was_holding' if answered_was_holding?

    return '/search/preliminary_sentences/written_question_withdrawn' if withdrawn?

    return '/search/preliminary_sentences/written_question_corrected' if corrected?

    nil
  end

  def holding_answer?
    return if content_object_data['holdingAnswer_b'].blank?

    return true if content_object_data['holdingAnswer_b'] == 'true'

    false
  end

  def date_of_holding_answer
    return if content_object_data['dateOfHoldingAnswer_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateOfHoldingAnswer_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  def transferred?
    return if content_object_data['transferredQuestion_b'].blank?

    return true if content_object_data['transferredQuestion_b'] == 'true'

    false
  end

  def unstarred_question?
    return if content_object_data['unstarredQuestion_b'].blank?

    return true if content_object_data['unstarredQuestion_b'] == 'true'

    false
  end

  def failed_oral?
    return if content_object_data['failedOral_b'].blank?

    return true if content_object_data['failedOral_b'] == 'true'

    false
  end

  def grouped_for_answer?
    return if content_object_data['groupedAnswer_b'].blank?

    return true if content_object_data['groupedAnswer_b'] == 'true'

    false
  end

  def attachment
    # this is the title of the attachment, rather than a link to the resource
    # there can be multiple titles, all of which will be displayed

    return if content_object_data['attachmentTitle_t'].blank?

    content_object_data['attachmentTitle_t']
  end
end