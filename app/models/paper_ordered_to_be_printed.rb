class PaperOrderedToBePrinted < Paper

  def initialize(content_object_data)
    super
  end

  def template
    'search/objects/paper_ordered_to_be_printed'
  end

  def search_result_partial
    'search/results/paper_ordered_to_be_printed'
  end

  def search_result_ses_fields
    %w[type_ses subtype_ses member_ses department_ses corporateAuthor_ses procedural_ses
       legislationTitle_ses subject_ses legislature_ses]
  end

  def object_name
    # only subtypes 528119 and 528127, otherwise show type
    valid_subtypes = subtypes&.select { |i| [528119, 528127].include?(i[:value]) }
    valid_subtypes.blank? ? type : valid_subtypes.first
  end

  def paper_type
    # subtype, but excluding 528119 and 528127
    valid_paper_types = super&.reject { |i| [528119, 528127].include?(i[:value]) }
    valid_paper_types.blank? ? nil : valid_paper_types
  end

  def display_link
    get_first_from('location_uri')
  end
end