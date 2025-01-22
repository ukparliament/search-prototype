class Bill < ContentTypeObject

  def initialize(content_type_object_data)
    super
  end

  def template
    'content_type_objects/object_pages/bill'
  end

  def search_result_partial
    'search/results/bill'
  end

  def self.search_result_solr_fields
    # fields requested in Solr search for search results page
    %w[title_t uri member_ses memberParty_ses department_ses department_t type_ses
      subtype_ses corporateAuthor_ses corporateAuthor_t legislationTitle_ses
      legislationTitle_t witness_ses witness_t subject_ses subject_t topic_ses searcherNote_t
      commonsLibraryLocation_t lordsLibraryLocation_t date_dt identifier_t legislature_ses]
  end

  def object_name
    subtype_or_type
  end

  def associated_objects
    ids = super
    ids << previous_version_id
    ids.flatten.compact.uniq
  end

  def date_of_order
    get_first_as_date_from('dateOfOrderToPrint_dt')
  end

  def previous_version_id
    get_first_id_from('isVersionOf_t')
  end

  def version_title
    title[:value]
  end

  def title
    get_as_string_from('title_t')
  end

  def location_uri
    get_first_from('location_uri')
  end

  def display_link
    # For everything else, where there is no externalLocation, no Link, internalLocation is not surfaced in new Search
    location_uri.blank? ? nil : location_uri
  end
end