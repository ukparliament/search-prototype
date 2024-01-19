class ChurchOfEnglandMeasure < ContentObject

  def initialize(content_object_data)
    super
  end

  def date_of_royal_assent
    get_first_as_date_from('dateOfRoyalAssent_dt')
  end

  def template
    'search/objects/church_of_england_measure'
  end
end