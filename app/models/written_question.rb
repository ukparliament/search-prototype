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

  # Note that with the exception of 'Answered' these are guesses until
  # the state names can be confirmed
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
    state == 'Answered was holding'
  end

  def withdrawn?
    state == 'Withdrawn'
  end

  def corrected?
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
    # TODO: establish whether there can be multiple attachments

    return if content_object_data['attachmentTitle_t'].blank?

    content_object_data['attachmentTitle_t'].first
  end
end