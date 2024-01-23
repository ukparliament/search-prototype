class StatutoryInstrument < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/statutory_instrument'
  end

  def object_name
    # differs from subtype_or_type as there can be multiple subtypes for SIs

    subtypes = get_all_from('subtype_ses')
    subtypes.blank? ? [type] : subtypes
  end

  def member_name
    get_first_from('memberPrinted_t')
  end

end