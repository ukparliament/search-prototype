class StatutoryInstrument < Paper

  def initialize(content_type_object_data)
    super
  end

  def template
    'content_type_objects/object_pages/statutory_instrument'
  end

  def search_result_partial
    'search/results/statutory_instrument'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    super << %w[
    title_t uri
    abstract_t
    memberPrinted_t
    department_ses department_t
    type_ses subtype_ses
    procedure_t
    dateLaid_dt dateWithdrawn_dt dateMade_dt dateApproved_dt
    comingIntoForceNotes_t comingIntoForce_dt
    legislationTitle_ses legislationTitle_t
    subject_ses subject_t
    searcherNote_t
    commonsLibraryLocation_t lordsLibraryLocation_t
    date_dt identifier_t legislature_ses
    ]
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