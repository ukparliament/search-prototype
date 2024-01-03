class Question < ContentObject

  def initialize(content_object_data)
    super
  end

  def state
    get_first_from('pqStatus_t')
  end

  def tabled?
    state && state[:value] == 'Tabled'
  end

  def answered?
    state && state[:value] == 'Answered'
  end

  def withdrawn?
    state && state[:value] == 'Withdrawn'
  end

  def corrected?
    # TODO: There is no state string for this, it must be derived
    # Prior to July 2014, correctedWmsMc_b flag + related links will contain a link to the correction
    # After July 2014, correctedWmsMc_b + correctingItem_uri OR correctingItem_t / s as a fallback

    # corrected 'written questions' are written questions with corrected answers, and will have a state
    # of 'answered'

    # Some items appear to have a correcting_item_link but this boolean is missing; need to clarify the
    # conditions for corrections.

    corrected_boolean = get_first_as_boolean_from('correctedWmsMc_b')
    return false unless corrected_boolean && corrected_boolean[:value] == true

    true
  end

  def correcting_object
    # This only applies to corrections before July 2014, and for corrected written questions after this date
    # this method should return nil as content_object_data['correctingItem_uri'] will be blank. We can therefore
    # check correcting_object is not nil to determine whether or not we attempt to show its data in the view.

    return unless corrected?

    return if correcting_item_link.blank?

    correcting_item_data = SolrQuery.new(object_uri: correcting_item_link).object_data
    ContentObject.generate(correcting_item_data)
  end

  def transferred?
    get_as_boolean_from('transferredQuestion_b')
  end

  def correcting_item_link
    get_first_from('correctingItem_uri')
  end

  def date_of_question
    date
  end

  def date_of_answer
    get_first_as_date_from('dateOfAnswer_dt')
  end

  def date_for_answer
    # will be missing for Lords questions 2005-2014
    get_first_as_date_from('dateForAnswer_dt')
  end

  def tabling_member
    get_first_from('tablingMember_ses')
  end

  def tabling_member_party
    get_first_from('tablingMemberParty_ses')
  end

  def answer_text
    get_first_from('answerText_t')
  end

  def corrected_answer
    # TODO: data for this not currently determined
    nil
  end

  def question_text
    get_first_as_html_from('questionText_t')
  end

  def question_type
    get_all_from('wqType_t')
  end

  def answering_department
    get_first_from('answeringDept_ses')
  end

  def answering_member_party
    get_first_from('answeringMemberParty_ses')
  end
end