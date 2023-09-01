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

  def prelim_partial
    return if content_object_data['pqStatus_t'].blank?

    state = content_object_data['pqStatus_t']

    return 'app/views/search/fragments/_written_question_prelim_answered.html.erb' if state == 'answered'

    return 'app/views/search/fragments/_written_question_prelim_tabled.html.erb' if state == 'tabled'

    return 'app/views/search/fragments/_written_question_prelim_holding.html.erb' if state == 'holding'

    return 'app/views/search/fragments/_written_question_prelim_answered_was_holding.html.erb' if state == 'answered_was_holding'

    return 'app/views/search/fragments/_written_question_prelim_withdrawn.html.erb' if state == 'withdrawn'

    return 'app/views/search/fragments/_written_question_prelim_corrected.html.erb' if state == 'corrected'

    nil
  end

end