class ChurchOfEnglandMeasure < ContentObject

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/church_of_england_measure'
  end

  def object_name
    'Church of England measure'
  end

  def date_of_royal_ascent
    return if content_object_data['dateOfRoyalAssent_dt'].blank?

    valid_date_string = validate_date(content_object_data['dateOfRoyalAssent_dt'].first)
    return unless valid_date_string

    valid_date_string.to_date
  end


end