class PaperOrderedToBePrinted < Paper

  def initialize(content_type_object_data)
    super
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    commonsLibraryLocation_t
    corporateAuthor_ses
    corporateAuthor_t
    dateLaid_dt
    dateOfOrderToPrint_dt
    dateWithdrawn_dt
    date_dt
    department_ses
    department_t
    identifier_t
    legislationTitle_ses
    legislationTitle_t
    legislature_ses
    lordsLibraryLocation_t
    member_ses
    procedural_ses
    searcherNote_t
    subject_ses
    subject_t
    title_t
    uri
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