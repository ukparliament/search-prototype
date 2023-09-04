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

    state = content_object_data['pqStatus_t']
  end

  def tabled?
    state == 'tabled'
  end

  def answered?
    state == 'answered'
  end

  def holding?
    state == 'holding'
  end

  def answered_was_holding?
    state == 'answered_was_holding'
  end

  def withdrawn?
    state == 'withdrawn'
  end

  def corrected?
    state == 'corrected'
  end

  def prelim_partial
    return 'app/views/search/fragments/_written_question_prelim_tabled.html.erb' if tabled?

    return 'app/views/search/fragments/_written_question_prelim_answered.html.erb' if answered?

    return 'app/views/search/fragments/_written_question_prelim_holding.html.erb' if holding?

    return 'app/views/search/fragments/_written_question_prelim_answered_was_holding.html.erb' if answered_was_holding?

    return 'app/views/search/fragments/_written_question_prelim_withdrawn.html.erb' if withdrawn?

    return 'app/views/search/fragments/_written_question_prelim_corrected.html.erb' if corrected?

    nil
  end

  def date_of_answer
    return if content_object_data['dateOfAnswer_dt'].blank?

    content_object_data['dateOfAnswer_dt'].first
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
end