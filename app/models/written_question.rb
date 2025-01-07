class WrittenQuestion < Question

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/written_question'
  end

  def self.required_solr_fields
    %w[title_t uri type_ses subtype_ses questionText_t askingMember_ses askingMemberParty_ses tablingMember_ses tablingMemberParty_ses answeringMember_ses answeringMemberParty_ses departmentPrinted_t pqStatus_t askedToReplyAuthor_ses procedural_ses dateTabled_dt dateForAnswer_dt dateOfHoldingAnswer_dt dateOfAnswer_dt answerText_t correctingItem_uri correctingItem_t correctedWmsMc_b legislationTitle_ses legislationTitle_t subject_ses subject_t searcherNote_t legislature_ses identifier_t date_dt]
  end

  def search_result_partial
    'search/results/written_question'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses askingMember_ses askingMemberParty_ses tablingMember_ses tablingMemberParty_ses
       answeringMember_ses answeringMemberParty_ses askedToReplyAuthor_ses procedural_ses legislationTitle_ses
       subject_ses legislature_ses]
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
    return false unless has_holding_answer && has_holding_answer[:value]

    # 2. the date this question received a holding answer:
    return false if date_of_holding_answer.blank?

    true
  end

  def prelim_partial
    return '/search/preliminary_sentences/written_question_corrected' if corrected?

    return '/search/preliminary_sentences/written_question_answered_was_holding' if answered_was_holding?

    return '/search/preliminary_sentences/written_question_holding' if holding?

    return '/search/preliminary_sentences/written_question_tabled' if tabled?

    return '/search/preliminary_sentences/written_question_withdrawn' if withdrawn?

    return '/search/preliminary_sentences/written_question_answered' if answered?

    nil
  end

  def uin
    # UIN with optional Hansard reference in same field
    get_all_from('identifier_t')
  end

  def has_holding_answer
    get_first_as_boolean_from('holdingAnswer_b')
  end

  def date_of_holding_answer
    get_first_as_date_from('dateOfHoldingAnswer_dt')
  end

  def is_unstarred_question
    get_first_as_boolean_from('unstarredQuestion_b')
  end

  def has_failed_oral
    get_first_as_boolean_from('failedOral_b')
  end

  def is_grouped_for_answer
    get_first_as_boolean_from('groupedAnswer_b')
  end

  def answering_body
    get_first_from('departmentPrinted_t')
  end

  def attachment
    # this is the title of the attachment, rather than a link to the resource
    # there can be multiple titles, all of which will be displayed

    return if content_object_data['attachmentTitle_t'].blank?

    content_object_data['attachmentTitle_t']
  end
end