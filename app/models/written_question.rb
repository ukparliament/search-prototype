class WrittenQuestion < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/written_question'
  end

  def object_name
    "written question"
  end

  def state
    return if content_object_data['pqStatus_t'].blank?

    content_object_data['pqStatus_t'].first
  end

  def tabled?
    state == 'Tabled'
  end

  def answered?
    state == 'Answered'
  end

  def holding?
    state == 'Holding'
  end

  def answered_was_holding?
    # There is no state string for this, it must be derived
    return false unless state == 'Answered'

    return false unless holding_answer?

    return false if date_of_holding_answer.blank?

    true
  end

  def withdrawn?
    state == 'Withdrawn'
  end

  def corrected?
    # There is no state string for this, it must be derived
    # This wasn't mentioned in Anya's email. Need to confirm whether it's been dropped.
    state == 'Corrected'
  end

  def prelim_partial
    return '/search/fragments/written_question_prelim_tabled' if tabled?

    return '/search/fragments/written_question_prelim_answered' if answered?

    return '/search/fragments/written_question_prelim_holding' if holding?

    return '/search/fragments/written_question_prelim_answered_was_holding' if answered_was_holding?

    return '/search/fragments/written_question_prelim_withdrawn' if withdrawn?

    return '/search/fragments/written_question_prelim_corrected' if corrected?

    nil
  end

  def uin
    # return if content_object_data['date_dt'].blank?
    nil
  end

  def holding_answer?
    return if content_object_data['holdingAnswer_b'].blank?

    return true if content_object_data['holdingAnswer_b'] == 'true'

    false
  end

  def date_of_question
    return if content_object_data['date_dt'].blank?

    valid_date_string = validate_date(content_object_data['date_dt'])
    return unless valid_date_string

    valid_date_string.to_date
  end

  def date_of_answer
    return if content_object_data['dateOfAnswer_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateOfAnswer_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  def date_of_holding_answer
    return if content_object_data['dateOfHoldingAnswer_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateOfHoldingAnswer_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  def tabling_member
    return if content_object_data['tablingMember_ses'].blank?

    content_object_data['tablingMember_ses'].first
  end

  def answering_member
    return if content_object_data['answeringMember_ses'].blank?

    content_object_data['answeringMember_ses'].first
  end

  def answer_text
    return if content_object_data['answerText_t'].blank?

    CGI::unescapeHTML(content_object_data['answerText_t'].first)
  end

  def question_text
    return if content_object_data['questionText_t'].blank?

    CGI::unescapeHTML(content_object_data['questionText_t'].first)
  end

  def transferred?
    return if content_object_data['transferredQuestion_b'].blank?

    return true if content_object_data['transferredQuestion_b'] == 'true'

    false
  end

  def attachment
    # this is the title of the attachment, rather than a link to the resource
    # there can be multiple titles, all of which will be displayed

    return if content_object_data['attachmentTitle_t'].blank?

    content_object_data['attachmentTitle_t']
  end
end