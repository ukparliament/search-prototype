class StatutoryInstrument < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/statutory_instrument'
  end

  def object_name
    subtypes = get_all_from('subtype_ses')
    subtypes.blank? ? [type] : subtypes
  end

  def coming_into_force
    get_first_from('comingIntoForceNotes_t')
  end

  def coming_into_force_date
    get_first_as_date_from('comingIntoForce_dt')
  end

  def date_laid
    get_first_as_date_from('dateLaid_dt')
  end

  def date_approved
    get_first_as_date_from('approvedDate_dt')
  end

  def date_made
    get_first_as_date_from('dateMade_dt')
  end

  def date_withdrawn
    get_first_as_date_from('dateWithdrawn_dt')
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
    get_last_from('subtype_ses')
  end

end