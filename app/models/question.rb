class Question < ContentObject

  def initialize(content_object_data)
    super
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

    correcting_item_data = SolrQuery.new(object_uri: content_object_data['correctingItem_uri']).object_data
    ContentObject.generate(correcting_item_data)
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

  def tabling_member
    return if content_object_data['tablingMember_ses'].blank?

    content_object_data['tablingMember_ses'].first
  end

  def tabling_member_party
    return if content_object_data['tablingMemberParty_ses'].blank?

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

  def question_type
    return if content_object_data['wqType_t'].blank?

    content_object_data['wqType_t']
  end

  def procedure
    # no data on this currently
  end

  def answering_department
    return if content_object_data['answeringDept_ses'].blank?

    content_object_data['answeringDept_ses'].first
  end

  def answering_member_party
    return if content_object_data['answeringMemberParty_ses'].blank?

    content_object_data['answeringMemberParty_ses'].first
  end
end