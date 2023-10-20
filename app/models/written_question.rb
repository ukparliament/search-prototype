class WrittenQuestion < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/written_question'
  end

  def ses_lookup_ids
    [
      type,
      subtype,
      answering_member,
      answering_member_party,
      tabling_member,
      tabling_member_party,
      subjects,
      legislation,
      legislature,
      department
    ]
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

    # the following correspond to the holding state and their presence allows us to determine that this answered
    # question formerly had the state 'holding':
    # 1. the question has received a holding answer:
    return false unless holding_answer?

    # 2. the date this question received a holding answer:
    return false if date_of_holding_answer.blank?

    true
  end

  def withdrawn?
    state == 'Withdrawn'
  end

  def corrected?
    # There is no state string for this, it must be derived
    # Prior to July 2014, correctedWmsMc_b flag + related links will contain a link to the correction
    # After July 2014, correctedWmsMc_b + correctingItem_uri OR correctingItem_t / s as a fallback

    # corrected 'written questions' are written questions with corrected answers, and will have a state
    # of 'answered'

    return false unless content_object_data['correctedWmsMc_b'] == 'true'

    true
  end

  def correcting_object
    # Note - this is experimental and sets up correcting_object as a written question in its own right.
    #
    # In the view, we can then call object.correcting_object.department, object.correcting_object.date_of_question and
    # object.correcting_object.correcting_member to get the information we need regarding the correction.
    #
    # This only applies to corrections before July 2014, and for corrected written questions after this date
    # this method should return nil as content_object_data['correctingItem_uri'] will be blank. We can therefore
    # check correcting_object is not nil to determine whether or not we attempt to show its data in the view.

    return unless corrected?

    return if content_object_data['correctingItem_uri'].blank?

    correcting_item_data = ApiCall.new(object_uri: content_object_data['correctingItem_uri']).object_data
    ContentObject.generate(correcting_item_data)
  end

  def written_question_type
    return if content_object_data['wpqType_t'].blank?

    content_object_data['wpqType_t']
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

  def uin
    # UIN with optional Hansard reference in same field
    return if content_object_data['identifier_t'].blank?

    content_object_data['identifier_t']
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

  def date_for_answer
    # will be missing for Lords questions 2005-2014
    return if content_object_data['dateForAnswer_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateForAnswer_dt'].first)
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

  def tabling_member_party
    return if content_object_data['tablingMemberParty_ses'].blank?

    content_object_data['tablingMemberParty_ses'].first
  end

  def answering_member
    return if content_object_data['answeringMember_ses'].blank?

    content_object_data['answeringMember_ses'].first
  end

  def answering_member_party
    return if content_object_data['answeringMemberParty_ses'].blank?

    content_object_data['tablingMemberParty_ses'].first
  end

  def answer_text
    return if content_object_data['answerText_t'].blank?

    CGI::unescapeHTML(content_object_data['answerText_t'].first)
  end

  def corrected_answer
    # TODO: data for this not currently determined
    nil
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

  def procedure
    # no data on this currently
  end
end