class PaperSubmitted < Paper

  def initialize(content_type_object_data)
    super
  end

  def template
    'content_type_objects/object_pages/paper_submitted'
  end

  def search_result_partial
    'search/results/parliamentary_paper_laid'
  end

  def object_name
    # only subtypes 528119 and 528127, otherwise show type
    valid_subtypes = subtypes&.select { |i| [528129].include?(i[:value]) }
    valid_subtypes.blank? ? type : valid_subtypes.first
  end

  def paper_type
    # subtype, but excluding 528119 and 528127
    valid_paper_types = super&.reject { |i| [528129].include?(i[:value]) }
    valid_paper_types.blank? ? nil : valid_paper_types
  end

  def display_link
    get_first_from('location_uri')
  end
end