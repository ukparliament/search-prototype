class Question < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def associated_objects
    ids = super
    ids << correcting_item_link
    ids.flatten.compact.uniq
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
    # Prior to July 2014, correctedWmsMc_b flag + related links will contain a link to the correction
    # After July 2014, correctedWmsMc_b + correctingItem_uri OR correctingItem_t / s as a fallback

    # corrected 'written questions' are written questions with corrected answers, and will have a state
    # of 'answered'

    # If correcting item URI is present, it is considered corrected
    return true if correcting_item_link.present?

    # If corrected boolean is true, it is considered corrected
    corrected_boolean = get_first_as_boolean_from('correctedWmsMc_b')
    return false unless corrected_boolean && corrected_boolean[:value] == true

    true
  end

  def is_transferred
    get_first_as_boolean_from('transferredQuestion_b')
  end

  def correcting_item_link
    fallback(get_first_id_from('correctingItem_uri'), get_first_id_from('correctingItem_t'))
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

  def tabling_member_parties
    get_all_from('tablingMemberParty_ses')
  end

  def answer_text
    get_first_as_html_from('answerText_t')
  end

  def corrected_answer
    get_first_as_html_from('correctionText_t')
  end

  def question_text
    get_first_as_html_from('questionText_t')
  end

  def question_type
    get_first_from('wpqType_t')
  end

  def named_day?
    question_type && question_type[:value]&.downcase == 'named day'
  end

  def answering_department
    get_first_from('answeringDept_ses')
  end

  def answering_member_party
    get_first_from('answeringMemberParty_ses')
  end

  def answering_member_parties
    get_all_from('answeringMemberParty_ses')
  end

  def question?
    true
  end
end