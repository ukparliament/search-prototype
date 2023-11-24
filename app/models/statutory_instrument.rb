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
    get_first_from('comingIntoForceNotes_t')
  end

  def date_laid
    get_first_as_date_from('dateLaid_dt')
  end

  def referred_to
    get_first_from('referral_t')
  end

  def reported_by_joint_committee?
    get_first_as_boolean_from('jointCommitteeOnStatutoryInstruments_b')
  end

  def laying_authority
    get_first_from('authority_t')
  end

  def contains_explanatory_memo?
    get_first_as_boolean_from('containsEM_b')
  end

  def contains_impact_assessment?
    get_first_as_boolean_from('containsIA_b')
  end

  def laid_in_draft?
    get_first_as_boolean_from('draft_b')
  end

  def member_name
    get_first_from('memberPrinted_t')
  end

  def isbn
    get_first_from('isbn_t')
  end

  def last_subtype
    # temporary method - need to clear up what this should show & how
    return if content_object_data['subtype_ses'].blank?

    content_object_data['subtype_ses'].last
  end

end