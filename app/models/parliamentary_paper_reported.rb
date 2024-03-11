class ParliamentaryPaperReported < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_paper_reported'
  end

  def object_name
    # subtype, but not if it's 91561, 81563, 51288
    # there will be multiple subtypes to look through, but we're using the first remaining one
    valid_subtypes = subtypes&.reject{ |i| [91561, 91563, 51288].include?(i[:value]) }
    valid_subtypes.blank? ? type : valid_subtypes.first
  end

  def paper_type
    # subtype, but only if it's 91561, 81563, 51288
    valid_paper_types = super&.select { |i| [91561, 91563, 51288].include?(i[:value]) }
    valid_paper_types.blank? ? nil : valid_paper_types
  end

  def display_link
    # externalLocation_t, location_t or location_uri (no preference indicated; return one only)
    return external_location_text unless external_location_text.blank?

    fallback(get_first_from('location_uri'), get_first_from('location_t'))
  end
end