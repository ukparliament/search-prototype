class ParliamentaryPaperReported < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/parliamentary_paper_reported'
  end

  def object_name
    filter_types(subtypes_or_type)
  end

  def paper_type
    filter_types(super)
  end

  def filter_types(subtype_or_type_ids)
    # Reported papers ignore subtype IDs of 91561, 81563 or 51288
    return subtype_or_type_ids unless subtype_or_type_ids.is_a?(Array)

    subtype_or_type_ids.reject do |i|
      puts "i: #{i}"
      [91561, 81563, 51288].include?(i[:value])
    end
  end

  def display_link
    # externalLocation_t, location_t or location_uri (no preference indicated; return one only)
    return external_location_text unless external_location_text.blank?

    fallback(get_first_from('location_uri'), get_first_from('location_t'))
  end
end