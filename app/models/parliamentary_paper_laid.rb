class ParliamentaryPaperLaid < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_paper_laid'
  end

  def object_name
    # for 92347 - unsure about other types
    subtype_or_type
  end

  def is_withdrawn
    get_first_as_boolean_from('withdrawn_b')
  end

  def paper_type
    # show subtypes, excluding 92347
    super&.reject { |a| a[:value].to_i == 92347 }
  end

  def reference
    return if type.blank? || type[:value] == 352261

    return get_all_from('reference_t') if type[:value] == 51288

    super
  end

  def is_considered_by_eu_si_committee
    get_first_as_date_from('consideredByESICDate_dt')
  end

  def is_considered_by_secondary_legislation_committee
    get_first_as_date_from('consideredBySLSCDate_dt')
  end

  def display_link
    location_uri = get_first_from('location_uri')
    return location_uri unless location_uri.blank?

    location_t = get_first_from('location_t')
    external_location_t = get_first_from('externalLocation_t')
    fallback(location_t, external_location_t)
  end

  def dual_type?
    # used to show both type and subtype with equal importance in related items partial
    return false if type.blank? || subtype.blank?

    type[:value] == 91561 && subtype[:value] == 91563
  end
end