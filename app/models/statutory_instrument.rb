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

  def member_name
    return if content_object_data['memberPrinted_t'].blank?

    content_object_data['memberPrinted_t'].first
  end

  def last_subtype
    # temporary method - need to clear up what this should show & how
    return if content_object_data['subtype_ses'].blank?

    content_object_data['subtype_ses'].last
  end

end