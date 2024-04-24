class StatutoryInstrument < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/statutory_instrument'
  end

  def search_result_partial
    'search/results/statutory_instrument'
  end

  def object_name
    # differs from subtype_or_type as there can be multiple subtypes for SIs

    subtypes = get_all_from('subtype_ses')
    subtypes.blank? ? [type] : subtypes
  end

  def member_name
    get_first_from('memberPrinted_t')
  end

  def is_withdrawn
    get_first_as_boolean_from('withdrawn_b')
  end

  def location_uri
    get_first_from('location_uri')
  end

  def display_link
    # For everything else, where there is no externalLocation, no Link, internalLocation is not surfaced in new Search
    location_uri.blank? ? nil : location_uri
  end
end