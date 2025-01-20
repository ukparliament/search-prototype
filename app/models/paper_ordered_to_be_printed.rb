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

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[
    title_t uri
    member_ses
    department_ses department_t
    type_ses subtype_ses
    corporateAuthor_ses corporateAuthor_t
    procedural_ses
    dateLaid_dt dateOfOrderToPrint_dt dateWithdrawn_dt
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    commonsLibraryLocation_t lordsLibraryLocation_t
    date_dt identifier_t legislature_ses
    ]
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