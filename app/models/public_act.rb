class PublicAct < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/public_act'
  end

  def object_name
    'public act'
  end

  def date_of_royal_ascent
    return if content_object_data['dateOfRoyalAssent_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateOfRoyalAssent_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end

  def bill
    # unsure about this - just grabbing first ID from legislation_ses
    legislation.first
  end

end