class Paper < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def coming_into_force
    get_first_from('comingIntoForceNotes_t')
  end

  def coming_into_force_date
    get_first_as_date_from('comingIntoForce_dt')
  end

  def date_laid
    fallback(get_first_as_date_from('dateLaid_dt'), get_first_as_date_from('date_dt'))
  end

  def date_approved
    get_first_as_date_from('dateApproved_dt')
  end

  def date_made
    get_first_as_date_from('dateMade_dt')
  end

  def date_withdrawn
    get_first_as_date_from('dateWithdrawn_dt')
  end

  def date_of_order_to_print
    get_first_as_date_from('dateOfOrderToPrint_dt')
  end

  def referred_to
    get_first_from('referral_t')
  end

  def is_reported_by_joint_committee
    get_first_as_boolean_from('jointCommitteeOnStatutoryInstruments_b')
  end

  def is_laid_in_draft
    get_first_as_boolean_from('draft_b')
  end

  def laying_authority
    get_first_from('authority_t')
  end

  def member_name
    get_first_from('memberPrinted_t')
  end

  def paper_procedure
    get_first_from('procedure_t')
  end

  def paper_type
    get_all_from('subtype_ses')
  end
end