class StatutoryInstrument < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/statutory_instrument'
  end

  def object_name
    last_subtype.blank? ? type : last_subtype
  end

  def coming_into_force
    return if content_object_data['comingIntoForceNotes_t'].blank?

    content_object_data['comingIntoForceNotes_t'].first
  end

  def date_laid
    return if content_object_data['dateLaid_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateLaid_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  def procedure
    return if content_object_data['procedure_t'].blank?

    content_object_data['procedure_t']
  end

  def referred_to
    return if content_object_data['referral_t'].blank?

    content_object_data['referral_t'].first
  end

  def reported_by_joint_committee?
    return if content_object_data['jointCommitteeOnStatutoryInstruments_b'].blank?

    return false unless content_object_data['jointCommitteeOnStatutoryInstruments_b'].first == 'true'

    true
  end

  def laying_authority
    return if content_object_data['authority_t'].blank?

    content_object_data['authority_t'].first
  end

  def contains_explanatory_memo?
    return if content_object_data['containsEM_b'].blank?

    return false unless content_object_data['containsEM_b'].first == 'true'

    true
  end

  def contains_impact_assessment?
    return if content_object_data['containsIA_b'].blank?

    return false unless content_object_data['containsIA_b'].first == 'true'

    true
  end

  def laid_in_draft?
    return if content_object_data['draft_b'].blank?

    return false unless content_object_data['draft_b'].first == 'true'

    true
  end

  def member_name
    return if content_object_data['memberPrinted_t'].blank?

    content_object_data['memberPrinted_t'].first
  end

  def isbn
    return if content_object_data['isbn_t'].blank?

    content_object_data['isbn_t'].first
  end

  def ec_documents
    return if content_object_data['ecDocument_t'].blank?

    content_object_data['ecDocument_t'].first
  end

  def last_subtype
    # temporary method - need to clear up what this should show & how
    return if content_object_data['subtype_ses'].blank?

    content_object_data['subtype_ses'].last
  end

end